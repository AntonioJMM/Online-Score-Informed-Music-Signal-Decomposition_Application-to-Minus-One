function [p,q,D,sc] = dpfast_var_offline_min(M,C,T,G)
% [p,q,D,sc] = dpfast(M,C,T,G)
%    Use dynamic programming to find a min-cost path through matrix M.
%    Return state sequence in p,q; full min cost matrix as D and
%    local costs along best path in sc.
%    This version gives the same results as dp.m, but uses dpcore.mex
%    to run ~200x faster.
%    C is a step matrix, with rows (i step, j step, cost factor)
%    Default is [1 1 1.0;0 1 1.0;1 0 1.0];
%    Another good one is [1 1 1;1 0 1;0 1 1;1 2 2;2 1 2]
%    T selects traceback origin: 0 is to any edge; 1 is top right (default);
%    T > 1 finds path to min of anti-diagonal T points away from top-right.
%    Optional G defines length of 'gulleys' for T=0 mode; default 0.5
%    (i.e. accept path to only 50% of edge nearest top-right)
% 2003-04-04,2005-04-04 dpwe@ee.columbia.edu $Header: /Users/dpwe/projects/dtw/RCS/dpfast.m,v 1.6 2008/03/14 14:40:50 dpwe Exp $

% Copyright (c) 2003 Dan Ellis <dpwe@ee.columbia.edu>
% released under GPL - see file COPYRIGHT

if nargin < 2
    % Default step / cost matrix
    C = [1 1 1.0;0 1 1.0;1 0 1.0];
end
if nargin < 3
    % Default: path to top-right
    T = 1;
end
if nargin < 4
    % how big are gulleys?
    G = 0.5;  % half the extent
end
if sum(isnan(M(:)))>0
    error('dpwe:dpfast:NAN','Error: Cost matrix includes NaNs');
end
if min(M(:)) < 0
    disp('Warning: cost matrix includes negative values; results may not be what you expect');
end

[r,c] = size(M);

% Core cumulative cost calculation coded as mex
[D,phi] = dpcore_var_min(M,C);

% Cambio distancia por velocidad
p = [];
q = [];
v = [];

%% Traceback from top left
if T == 0
    % Traceback from lowest cost "to edge" (gulleys)
    TE = D(r,:);
    RE = D(:,c);
    TE(:)=max(RE);
    
    if (min(TE) < min(RE))
        i = r;
        j = max(find(TE==min(TE)));
    else
        i = max(find(RE==min(RE)));
        j = c;
    end
else
    % Traceback from min of antidiagonal
    i = r;
    j = c;
end

p=i;
q=j;
sc=0;

while i > 1 && j >= 1
    tb = phi(i,j);
    i = i - C(tb,1);
    j = j - C(tb,2);
    if C(tb,2)>1
        for k=1:C(tb,2)-1
            p = [p(1),p];
            q = [q(1),q];
        end
    end
    p = [i,p];
    q = [j,q];
end

return
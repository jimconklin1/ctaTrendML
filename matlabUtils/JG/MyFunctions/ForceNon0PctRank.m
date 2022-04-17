function Y = ForceNon0PctRank(X, Factor)
%__________________________________________________________________________
% TSPercentileRank gives 0 for minimum
% Sometimes, we need a minimum higher than 0
% Works with column vector and return a column vector
%__________________________________________________________________________
%
    if size(X,1)==1, X=X'; end % transpose if row vector
    pctrank = X; % give col vector
    nonzero = nnz(pctrank); % find nb of non-zero elements
    nbnan = find(isnan(pctrank));% find nb of nan
    nbarg = nonzero-nbnan;% compute nb of non zero and non nan
    tmp = pctrank; tmp(tmp==0) = Inf; % temp to find lowest element higher than 0
    minarray = min(tmp);% lowest element
    n=size(tmp,1);
    tmp = tmp - (minarray/Factor)/nbarg * ones(n,1);
    tmp(tmp==0) = minarray/Factor; % assign mimi value/Factor to Inf
    pctrank = tmp;
    Y = pctrank;
    
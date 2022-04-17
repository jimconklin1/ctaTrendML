function H =  weighted_hist(vals, weights, min_val)
% weighted_hist(vals, weights, min_val, max_val)
%
% Builds a histogram by binning the elements of val into containers, one
% for each unique value of val.  Each element of val is weighted by the
% value in the corresponding column of weights.
%
% Input:
% vals = a 1xn matrix of positive integer values.  
% The (weighted) frequency of these values will be made into the output
% histogram.
% weights = a 1xn matrix of weights (default is ones(1,n))
% min_val = the minimum integer bin to be included on the output histogram
% (default is 0)
%
% Output:
% H = a row vector of weighted counts, such that H(x) is the weighted
% number of times min_val+(x-1) appears in vals 

if ~exist('weights','var')
	weights = ones(1, size(vals,2));
end
if exist('min_val','var')
	vals = vals - min_val+1;
end

H = (accumarray(vals', weights))';

end
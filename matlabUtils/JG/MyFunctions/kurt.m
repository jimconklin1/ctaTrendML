function y = kurt(x,LookbackPeriod)
%__________________________________________________________________________
% The function computes the Kurtosis
%
% Higher kurtosis means more of the variance is the result of infrequent 
% extreme deviations, as opposed to frequent modestly sized deviations. 
% It is common practice to use an adjusted version of Pearson's kurtosis, 
% the excess kurtosis, to provide a comparison of the shape of a given 
% distribution to that of the normal distribution. Distributions with 
% negative or positive excess kurtosis are called platykurtic distributions
% or leptokurtic distributions respectively.
%
% Distributions with negative or positive excess kurtosis are called 
% platykurtic distributions or leptokurtic distributions respectively.
%
% Kurtosis = E[ (X - mu)^4] / E[(X - mu)^2]^2 - 3
%
% INPUT: x = variable x of interest
%        LookbackPeriod = rolling window over which the Kurtosis is computed
%__________________________________________________________________________
%
%
% -- Prelocate & Dimensions --
y = zeros(size(x));
[nbsteps,nbcols]=size(y);
% -- Compute Kurtosis --
for j=1:nbcols
    % find the first cell to start the code
    start_date = zeros(1,1);
    for i=1:nbsteps
        if ~isnan(x(i,j))
            start_date(1,1)=i;
        break
        end
    end
    % Compute
    for k = start_date(1,1) + LookbackPeriod - 1 : nbsteps
        y(k,j) = kurtosis(x(k-LookbackPeriod+1:k,j));
    end
end


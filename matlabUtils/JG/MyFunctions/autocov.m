function y = autocov(x, lookback, lag)
%
%__________________________________________________________________________
%
% The function autocorr computes the auto-covariance in a time-series for
% over a given period anf for a given lag.
%
% INPUTS:
% X        = a 'n observations * m assets' matrix
% lookback = the period over which the auto-correlation is computed
% lag      = the lag between the variables
% OUTPUT
% y = auto-correlatiom
%__________________________________________________________________________
%
% -- Dimensions & Pre-locate matrices --
y = zeros(size(x));
[nbsteps,nbcols]=size(x);
%
% -- Compute auto-correlation --
for j=1:nbcols
    % Find the first cell to start the code
    for i=1:nbsteps
        if ~isnan(x(i,j))
            start_date=i;
        break
        end
    end
    % Auto-correlation
    for i = start_date + lookback + lag : nbsteps
        mycov = cov(x(i-lookback+1:i,j),x(i-lookback+1-lag:i-lag,j));
        y(i,j)= mycov(2,1);
    end
end
y(isnan(y)) = 0; % Replace NaN with 0

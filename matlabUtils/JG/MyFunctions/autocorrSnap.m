function y = autocorrSnap(t, x, lookback, lag)
%
%__________________________________________________________________________
%
% The function autocorr computes the auto-correlation in a time-series for
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
[nbsteps,nbcols]=size(x);
y = zeros(1,nbcols);
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
    y(1,j)=corr(x(t-lookback+1:t,j),x(t-lookback+1-lag:t-lag,j));
end
y(isnan(y)) = 0; % Replace NaN with 0

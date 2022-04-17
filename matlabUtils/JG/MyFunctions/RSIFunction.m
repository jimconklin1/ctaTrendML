function[rsi, rsis, rsin] = RSIFunction(X,nbd,smooth_per,lookback_norm)
%
%__________________________________________________________________________
%
%The function frsi computes the RSI
% nbd is the period over which the rsi is computed (usually, 14 days)
% smooth_per is the average of the rsi over a given period (5 for instance)
%__________________________________________________________________________
%
% -- Dimensions & Parameters & Prelocate Matrices --
[NbSteps,NbCols] = size(X); 
% Define the period over which the RSI is computed
start = nbd;
if nargin>=3
    smooth_start = smooth_per;
else
    smooth_start=0;
end
advances = zeros(size(X));      declines = zeros(size(X));
average_gains = zeros(size(X)); average_losses = zeros(size(X));
smoothed_rs = zeros(size(X));   rsi = zeros(size(X));   smoothed_rsi = zeros(size(X));
%
% -- Compute Advances & Declines --
for j=1:NbCols
    for i=2:NbSteps
        if ~isnan(X(i,j)) && ~isnan(X(i-1,j))
            if X(i,j) > X(i-1,j)
                advances(i,j) = X(i,j) - X(i-1,j);
            else
                declines(i,j) = X(i-1,j) - X(i,j);
            end
        end
    end
end
% -- Averages --         
average_gains(start+1,:) = mean(advances(2:start+1,:));
average_losses(start+1,:) = mean(declines(2:start+1,:));
% -- Average Loss & Gains & Ratio --
for j=1:NbCols
    for i=start+2:NbSteps
        if ~isnan(average_gains(i-1,j)) && ~isnan(average_losses(i-1,j)) && ...
                ~isnan(advances(i,j)) && ~isnan(declines(i,j))   
            average_gains(i,j) = ((start-1) * average_gains(i-1,j) + advances(i,j)) / start;
            average_losses(i,j) = ((start-1) * average_losses(i-1,j) + declines(i,j)) / start;
        end
    end
end       
for j=1:NbCols
    for i=start+1:NbSteps
        if average_losses(i,j) ~=0 && ~isnan(average_losses(i,j)) && ...
                ~isnan(average_gains(i,j))
            smoothed_rs(i,j) = average_gains(i,j) / average_losses(i,j);
        end
    end
end
% -- Compute RSI --
for j=1:NbCols
    for i=start+1:NbSteps
        if ~isnan(smoothed_rs(i,j))
            rsi(i,j) = 100 * (1 - 1 / (1+smoothed_rs(i,j)));
        end
    end
end
% -- Smoothed RSI --
if nargin>=3
    for i=start+smooth_start:NbSteps
        smoothed_rsi(i,:) = mean(rsi(i-smooth_start-1:i,:)); 
    end
    rsis=smoothed_rsi;
end
% -- Normalised RSI --
if nargin==4
    rsiv=VolatilityFunction(rsi,'simple volatility',lookback_norm,20,1);
    rsin=rsi./rsiv;
end

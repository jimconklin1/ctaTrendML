function [probe,probf] = logitmodel(x, y, lookback, lag)
%lookback_period=30;
%y=cdif;
%__________________________________________________________________________
%
% This function uses a logit regression model to make forecast.
% Two matlab fnctions are used
%
% INPUTS:
% - 'lookback_period' is the rolling window over which the logit is
% estimated
% - 'lag' is the lag used for estimation and thus for the lag-days
% forward forecast
%
%_________________________________________________________________________


% -- Define Parameters --
nsteps = size(x,1);  
probe = zeros(nsteps,2);    % smoothing, estimation
probf = zeros(nsteps,2);    % forecast

% Find the first cell to start the code
start_date = zeros(1,1);
for i=1:nsteps
    if ~isnan(x(i))  && x(i)~=0 
        start_date(1,1) = i;
    break
    end
end
    
for i=start_date(1,1)+lookback+1:nsteps
    % Use 1-day lag to forecast next day
    snap_x_lag = x(i-lookback+1-lag:i-lag,:); 
    % Use total sample for smoothing
    snap_x = x(i-lookback+1:i,:);              
    % Snap data for y
    snap_y = y(i-lookback+1:i,1);              
    % Regress for estimating / smoothing
        b = mnrfit(snap_x,snap_y);  
        prob = mnrval(b,snap_x);
        probe(i,:)=prob(length(prob),:);    
    % Regress for forecast (estimate with 1 day lag, forecast with current)
        b = mnrfit(snap_x_lag,snap_y);  
        prob = mnrval(b,snap_x);  
        probf(i,:)=prob(length(prob),:);
end

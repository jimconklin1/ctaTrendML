function xest = RollingLowess(x, lookback, f)
%
%__________________________________________________________________________
%
% This function compute the LOWESS regression on a rolling basis
% INPUT
% x = matrix of data
% f = parameter
%__________________________________________________________________________
%

[nsteps,ncols] = size(x);
xest = zeros(size(x));
xtime = (1:1:lookback)';

for j=1:ncols
    
    for i=lookback:nsteps
        y = x(i-lookback+1:i,j);
        datain = [xtime , y];
        wantplot = 1;
        %xdata = x;
        [dataout, ~, ~, ~] = lowess(datain,f,0);
        xest(i,j) = dataout(length(dataout),3);
    end
    
end

% xxtime = (1:1:nsteps)';
% plot(dataout(:,1),dataout(:,3), '-black', xxtime , x, '--red');  grid on;

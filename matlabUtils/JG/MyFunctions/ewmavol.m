function [xstd, xvar] = ewmavol(x, method, parameters)
%__________________________________________________________________________
%
% The function computes the exponential weighted moving average standard 
% deviation.
% Instead of puting lambda as a parameter,I find more intuitive to put the
% number of days over which we compute the moving average (for instance,
% using Risk Metrics lambda=94%, lambda^N = 0.5, so N = 11.2;
%
% -- INPUT --
% x = series of close price
% method = levle, difference or level
% parameters is a structure of two inputs if the time series x isgiven in
% level, the first input being the period over which the user computes the
% rate of return.
%__________________________________________________________________________
%
% -- Dimension & Prelocate matrices --
[nsteps,ncols] = size(x); 
xvar = zeros(size(x));

switch method
    case {'level','lev', 'Level', 'l', 'L'}
        if nargin == 2
            lookback = 1;
            lambda = 94/100;
            N = floor(log(0.5)/log(lambda));
            x = Delta(x, 'roc',lookback);
        end
        if nargin ==3 && size(parameters,2)==2
            lookback = parameters(1,1);
            N = parameters(1,2);
            lambda = 0.5^(1/N);
            x = Delta(x, 'roc',lookback);
        end       
    case {'return', 'ret', 'roc', 'r', 'ROC', 'R', 'Ret', 'Return'}
        lookback = 1;
        if nargin == 2
            lambda = 94/100;
            N = floor(log(0.5)/log(lambda));
        elseif nargin == 3
            N = parameters(1,1);
            lambda = 0.5^(1/N);
        end
        
end
% Exponential smoothing moving average of variance
for j=1:ncols
    xSnap = x(:,j);
    tsStart = StartFinder(xSnap, 'znan');
    if tsStart > lookback
        for i = tsStart + lookback:nsteps
            xvar(i,j) = lambda * xvar(i-1,j) + (1-lambda) * x(i,j)^2;
        end
        xvar(1:tsStart+2*N,j) = zeros(tsStart+2*N,1); % erase first elements
    end
end

% Standard deviation
xstd = sqrt(xvar);
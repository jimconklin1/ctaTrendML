function [y, cv ] = UnitRoot(x, Lookback, Drift, Lag, method)
%
%__________________________________________________________________________
%
% This Function estimates the Augmented Dickey-Fuller test and makes used
% of the function 'adf' form spatial econometrics 
% (http://spatial-econometrics.com)
%
% The ADF test is based on the following linear model:
% Delta[Y(t)] = Lambda * Y(t-1) + mu + Beta * t + alpha_1*Delat[Y(t-1)[ + ...
%               alpha_k*Delta[Y(t-k)[ + epsilon(t).
%               The ADF test whether Lambda = 0. 
% If the hypothesis Lambda = 0 is rejected (therefore is the observed ADF 
% is higher in absolute terms than the critical ADF given by the structure
% 'variable_name.crit', then the next move Delta(y(t)) depends on the 
% current level Y(t-1), and therefore the the series is not a random walk 
% but mean reverting.
% If the ADF is lower (in absolute value) than the critical value, we
% cannot reject that Lambda = 0, and therefore we cannot accept the
% hypothesis that the process is mean reverting.
% If we cannot reject Lambda=0 and if Lambda > 0, the series is trending

% In ptractice, for simplicity, we assume the drift term Beta = 0 and the
% lag = 1.
% adf(x,p,nlag), where: x = a time-series vector
% p = order of time polynomial in the null-hypothesis
% p = -1, no deterministic part
% p = 0, for constant term
% p = 1, for constant plus time-trend
% p > 1, for higher order polynomial
% nlags = # of lagged changes of x included
%RETURNS: results structure
%results.meth = 'cadf'
%results.alpha = autoregressive parameter estimate
%results.adf = ADF t-statistic
%results.crit = (6 x 1) vector of critical values
%[1% 5% 10% 90% 95% 99%] quintiles
%results.nvar = cols(x)
%results.nlag = nlag
%
% INPUT:
% - Matrix of Close 
% - Drift: see equation, usually Drift = 0;
% - Lag: see equation, usually Lag = 1
% - Lookback: Lookback period for N (Exp de ATR)
% - method: 'fixed', if estimaton since the start of the time series
%           'rolling' if use a rolling window
% Typical set up: y = UnitRoot(c, 55, 0, 1, 'rolling')
%                 unroot = adf(x_v, 0, 1);
% OUTPUT:
% adf (unit root test)
% spread betwwen absolute value of adf and absolute value of critical value
%__________________________________________________________________________
%
% -- Prelocate the matrix --
y = zeros(size(x));
[nsteps,ncols]=size(x);
cv = zeros(nsteps,ncols,3);
%cvd = zeros(nsteps,ncols,3);

for j=1:ncols
    
    % Find the first cell to start the code
    for i=1:nsteps
        if ~isnan(x(i,j)), start_date=i;
        break
        end
    end
    
    switch method
    
        case 'rolling'
            % Rolling ADF
            for i = start_date + Lookback : nsteps
                % Compute Rolling regression
                x_v = x(i- Lookback + 1:i,j); 
                unroot = adf(x_v, Drift, Lag);  
                % Half Life
                if size(unroot.adf,1)==1 && size(unroot.adf,2)==1  
                    y(i,j) = unroot.adf;
                    if size(unroot.crit,1) == 6
                        for uuu=1:3
                            cv(i,j,uuu) = unroot.crit(uuu);
                            %cvd(i,j,u) = abs(y(i,j)) - abs(cv(i,j,uuu));
                        end 
                    end
                else
                    y(i,j) = y(i-1,j);
                    for uuu=1:3
                        cv(i,j,uuu) = cv(i-1,j,uuu);
                        %cvd(i,j,uuu) = cvd(i-1,j,uuu);
                    end                     
                end
            end
            
        case 'fixed'
            % Fixed ADF
            for i = start_date + Lookback : nsteps
                % Compute Rolling regression
                x_v = x(start_date + Lookback:i,j); 
                unroot = adf(x_v, Drift, Lag);  
                % Half Life
                if size(unroot.adf,1)==1 && size(unroot.adf,2)==1  
                    y(i,j) = unroot.adf;
                else
                    y(i,j) = y(i-1,j);
                end
            end     
            
    end
end


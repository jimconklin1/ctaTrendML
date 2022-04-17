function [ye,yf] = ForecastLinearModel(x, y, Transform_y, ARProcess, Intercept, TimeDrift, Lag, lookback, method)
%__________________________________________________________________________
%
% This function compute a rolling linerar forecast model
% The function makes use of the function "MatrixLagStructure".
% The user can chose the (i)   lag structure,
%                        (ii)  intercept or no intercept,
%                        (iii) time-drift or no time-drift, 
%                        (iv)  presence of exogenous of variables
%                        (v)   their lag as well
%                        (vi)  the estimation method:
%                              'regress' or 'robustfit'
% 
% -- INPUT ----------------------------------------------------------------
%
% x = matrix of exogenous predictors n obervations (in rows) and m columns 
%    If the model, does not have any, put 0
% y = is the endogenous variable
% Transform_y is a structure allows to transform y
% Transform_y      = 0 : no transformation
% Transform_y(1,1) = 1 : compute the rate of change
%                        with length Transform_y(1,2)
% Transform_y(1,1) = 2 : compute the difference 
%                        with length Transform_y(1,2)
% ARProcess is a parameter bewteen 0 and k
% If ARProcess      = 0, then the model does not include a lag value of
%                        the endogenous variable
% If ARProcess       >= 1 then the model include a lag value of the 
%                        endogenous variable. 
% Intercept:          0 if no Intercetp, 1 if intercept
% TimeDrift:          0 if no time drift, 1 if time drift
% Lag:  the lag ot the exogenous variables    
% Lookback: Period over which model is estimated.
% -- OUTPUT----------------------------------------------------------------
% ye: the equilibirum theoretical value
% yf: the forecast theoretical value
%
% Typical set up (No exogenous variable, no trandormation, for a model such
% as y(t) = a*y(t-1), regression over a 3-day rolling window
% [ye, yf] = ForecastLinearModel(0, c, 0, 1, 0, 0, 0, 3, 'regress');
%
% Watch out the difference in writting the functions 'regress' and
% 'robustfit'
% -- Regress method --
% b = regress(y,X) (responses in y on the predictors in X)
% When computing statistics, X should include a column of 1s so that the
% model contains a constant 
% -- Robustfit method --
% b  = robustfit(X,y) (response in y on the predictors in X)
% By default, robustfit adds a first column of 1s to X, corresponding to a 
% constant term in the model. Do not enter a column of 1s directly into X.
%
% Exemple: mo exogenous variable, no transformation, lag 1, no intercept,
% no time drift
% yf = ForecastLinearModel(0, y, 0, 1, 0, 0, 100, 'regress')
% Joel Guglietta - June 2014
%
%__________________________________________________________________________

% -- Dimension & Prelocate matrix --
nsteps = size(y,1);
ye = zeros(nsteps,1); % equilibrium
yf = zeros(nsteps,1); % forecast

% Create matrix of lagged variables
if ARProcess >= 1
    lag_endog = MatrixLagStruct(y,ARProcess);
    if ARProcess == 1
        lag_endog_forecast = y;
    elseif ARProcess >= 2
        lag_endog_forecast = [y, MatrixLagStruct(y,ARProcess-1)];
    end
end
% Intercept
if Intercept == 1, int = ones(lookback,1); end
% Time drift
if TimeDrift == 1, tdrift = (1:1:lookback)';end

% Transform y
if Transform_y == 0 
    y=y;
elseif size(Transform_y,2) == 2
    if Transform_y(1,1) == 1
        y = Delta(y,'roc', Transform_y(1,2));
    elseif Transform_y(1,1) == 2
        y = Delta(y,'dif', Transform_y(1,2));
    end
end
    
% Find the first cell to start the code
start_date = zeros(1,1);
for i=1:nsteps
    if ~isnan(x(i)) &&  ~isnan(y(i)) %&& x(i)~=0 && y(i)~=0
        start_date(1,1) = i + Lag;
    break
    end
end

switch method
  case 'regress'    
        for i=start_date(1,1)+lookback:nsteps
            if size(x,1) == nsteps % Exogenous variables 
                if ARProcess >= 1  % Lagged Endogenous variable
                    if Intercept == 1 && TimeDrift == 1 
                        snap_x = [int, tdrift, lag_endog(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [int, tdrift, lag_endog_forecast(i-lookback+1:i,:), x(i-lookback+1:i,:)];
                    elseif Intercept == 1 && TimeDrift == 0
                        snap_x = [int, lag_endog(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)]; 
                        snap_x_forecast = [int, lag_endog_forecast(i-lookback+1:i,:), x(i-lookback+1:i,:)]; 
                    elseif Intercept == 0 && TimeDrift == 1
                        snap_x = [tdrift, lag_endog(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [tdrift, lag_endog_forecast(i-lookback+1:i,:), x(i-lookback+1:i,:)];
                    elseif Intercept == 0 && TimeDrift == 0
                        snap_x = [lag_endog(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)]; 
                        snap_x_forecast = [lag_endog_forecast(i-lookback+1:i,:), x(i-lookback+1:i,:)]; 
                    end
                elseif ARProcess == 0 % Exogenous variables And NO Lagged Endogenous
                    if Intercept == 1 && TimeDrift == 1 
                        snap_x = [int, tdrift, x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [int, tdrift, x(i-lookback+1:i,:)];
                    elseif Intercept == 1 && TimeDrift == 0
                        snap_x = [int, x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [int, x(i-lookback+1:i,:)];
                    elseif Intercept == 0 && TimeDrift == 1
                        snap_x = [tdrift, x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [tdrift, x(i-lookback+1:i,:)];
                    elseif Intercept == 0 && TimeDrift == 0
                        snap_x = x(i-lookback+1-Lag:i-Lag,:);
                        snap_x_forecast = x(i-lookback+1:i,:);
                    end
                end
            elseif size(x,1) == 1 % NO Exogenous variable
                if ARProcess >= 1 % Lagged Endogeneous variable
                    if Intercept == 1 && TimeDrift == 1 
                        snap_x = [int, tdrift, lag_endog(i-lookback+1:i,:)];
                        snap_x_forecast = [int, tdrift, lag_endog_forecast(i-lookback+1:i,:)];
                    elseif Intercept == 1 && TimeDrift == 0
                       snap_x = [int, lag_endog(i-lookback+1:i,:)];
                       snap_x_forecast = [int, lag_endog_forecast(i-lookback+1:i,:)];
                    elseif Intercept == 0 && TimeDrift == 1
                        snap_x = [tdrift, lag_endog(i-lookback+1:i,:)];
                        snap_x_forecast = [tdrift, lag_endog_forecast(i-lookback+1:i,:)];
                    elseif Intercept == 0 && TimeDrift == 0
                        snap_x = lag_endog(i-lookback+1:i,:);
                        snap_x_forecast = lag_endog_forecast(i-lookback+1:i,:);
                    end  
                elseif ARProcess == 0 % NO Lagged Endogeneous variable
                    if Intercept == 1 && TimeDrift == 1 
                        snap_x = [int, tdrift];
                    elseif Intercept == 1 && TimeDrift == 0
                        snap_x = int;    
                    elseif Intercept == 0 && TimeDrift == 1
                        snap_x = tdrift;  
                    %elseif Intercept == 0 && TimeDrift == 0
                    %    x_model = lag_endog; 
                    end         
                end
            end            
            % Snap data for y
            snap_y = y(i-lookback+1:i);              
            % Regress
            results = regress(snap_y, snap_x);  
            % Assign (size conditions deal with mistake)
            %if size(results,1)  == size(x_model,2)
            %    b(i) = results(intercept + 1 , 1); % constant is put in 1st column              
            %else
            %    b(i) = b(i-1);
            %end
            % Compute equilbrium & Allocate (the last value of time_x=lookback_period
            if size(results,1) == size(snap_x,2)
                ye(i) = results' * snap_x(size(snap_x,1),:)';
            else
                ye(i) = yf(i-1);
            end
            % Compute forecast & Allocate (the last value of time_x=lookback_period
            if size(results,1) == size(snap_x_forecast,2)
                yf(i) = results' * snap_x_forecast(size(snap_x_forecast,1),:)';
            else
                yf(i) = yf(i-1);
            end            
        end
  case 'robustfit'    
        for i=start_date(1,1)+lookback:nsteps
            % Snap data for x
            snap_x = x(i-lookback+1:i);  
            if size(x,1) == nsteps
                if ARProcess >= 1
                    if Intercept == 1 && TimeDrift == 1 
                        snap_x = [tdrift, lag_endog(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [tdrift, lag_endog_forecast(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)];
                    elseif Intercept == 1 && TimeDrift == 0
                        snap_x = [lag_endog(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)];
                        snap__forecastx = [lag_endog_forecast(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)];    
                    elseif Intercept == 0 && TimeDrift == 1
                        snap_x = [tdrift, lag_endog(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [tdrift, lag_endog_forecast(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)];
                    elseif Intercept == 0 && TimeDrift == 0
                        snap_x = [lag_endog(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)]; 
                        snap_x_forecast = [lag_endog_forecast(i-lookback+1:i,:), x(i-lookback+1-Lag:i-Lag,:)]; 
                    end
                elseif ARProcess == 0
                    if Intercept == 1 && TimeDrift == 1 
                        snap_x = [tdrift, x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [tdrift, x(i-lookback+1-Lag:i-Lag,:)];
                    elseif Intercept == 1 && TimeDrift == 0
                        snap_x = x(i-lookback+1:i,:);
                        snap_x_forecast = x(i-lookback+1:i,:);
                    elseif Intercept == 0 && TimeDrift == 1
                        snap_x = [tdrift, x(i-lookback+1-Lag:i-Lag,:)];
                        snap_x_forecast = [tdrift, x(i-lookback+1-Lag:i-Lag,:)];
                    elseif Intercept == 0 && TimeDrift == 0
                        snap_x = x(i-lookback+1:i,:);
                        snap_x_forecast = x(i-lookback+1:i,:);
                    end
                end
            elseif size(x,1) == 1 % NO Exogeneous variables
                if ARProcess >= 1
                    if Intercept == 1 && TimeDrift == 1 
                        snap_x = [tdrift, lag_endog_forecast(i-lookback+1:i,:)];
                        snap_x_forecast = [tdrift, lag_endog(i-lookback+1:i,:)];
                    elseif Intercept == 1 && TimeDrift == 0
                        snap_x = [lag_endog(i-lookback+1:i,:)];
                        snap_x_forecast = [lag_endog_forecast(i-lookback+1:i,:)];
                    elseif Intercept == 0 && TimeDrift == 1
                        snap_x = [tdrift, lag_endog(i-lookback+1:i,:)];
                        snap_x_forecast = [tdrift, lag_endog_forecast(i-lookback+1:i,:)];
                    elseif Intercept == 0 && TimeDrift == 0
                        snap_x = lag_endog(i-lookback+1:i,:); 
                        snap_x_forecast = lag_endog_forecast(i-lookback+1:i,:); 
                    end 
                end
            end             
            % Snap data for y
            snap_y = y(i-lookback+1:i);              
            % Compute 
            results = robustfit(snap_x, snap_y);  
            % Assign
            %if size(results,1) == size(x_model,2)
            %    b(i) = results(2,1); %!!!!(2,1) as 1st col is constant!!
            %else
            %    b(i) = b(i-1);
            %end
            % Allocate (the last value of time_x=lookback_period
            if size(results,1) == size(x_model,2)
                yf(i) = results' * snap_x(size(snap_x,1),:)';
            else
                yf(i) = yf(i-1);
            end
        end        
end

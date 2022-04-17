function [b,yf] = RollingOLS(x, y, parameters, method)

%__________________________________________________________________________
%
% Compute the Estimated & Slope for two variable x & y
%
% INPUTS:
%
% - Method can use robustfit or regress (more on this below in notes)
% - parameters: a structure of 1 row and 2 columns or 1 column
%       . parameters(1) is always the lookback period for the rolling
%       regression
%       . parameters(2) is 1 (or ommited by default) if you want to put a
%       constant in the model regress
% - Use x as the regressor (the predictor) and y as the regresand
% (predicted)
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
%__________________________________________________________________________

%if size(x,1) ~= size(y,1)
%    error('Wrong number of input arguments')
%end

% -- Define Parameters --
nsteps = size(x,1);    b = zeros(nsteps,1);  
yf = zeros(nsteps,1);
if size(parameters,2) == 1
    lookback_period = parameters(1,1);  
    intercept = 0;
elseif size(parameters,2) == 2
    lookback_period=parameters(1,1); 
    intercept = 1;
    ct_x = ones(lookback_period,1);  
end
% Find the first cell to start the code
start_date = zeros(1,1);
for i=1:nsteps
    if ~isnan(y(i))% &&  ~isnan(x(i)) %&& x(i)~=0 && y(i)~=0
        start_date(1,1) = i;
    break
    end
end

switch method
  case 'regress'    
        for i=start_date(1,1)+lookback_period:nsteps
            % Snap data for x
            snap_x = x(i-lookback_period+1:i,:);  
            if intercept == 1
                snap_x = [ct_x, snap_x];
            elseif intercept == 0
                snap_x = snap_x;
            end            
            % Snap data for y
            snap_y = y(i-lookback_period+1:i);              
            % Regress
            results = regress(snap_y, snap_x);  
            % Assign
            if size(results,1) == intercept + 1
                b(i) = results(intercept + 1 , 1); % constant is put in 1st column              
            else
                b(i) = b(i-1);
            end
            % Allocate (the last value of time_x=lookback_period
            if size(results,1) == intercept + 1
                yf(i) = results' * snap_x(size(snap_x,1),:)';
            else
                yf(i) = yf(i-1);
            end
        end
  case 'robustfit'    
        for i=start_date(1,1)+lookback_period:nsteps
            % Snap data for x
            snap_x = x(i-lookback_period+1:i,:);          
            % Snap data for y
            snap_y = y(i-lookback_period+1:i);              
            % Compute 
            results = robustfit(snap_x, snap_y);  
            % Assign
            if size(results,1) == intercept + 1
                b(i) = results(2,1); %!!!!(2,1) as 1st col is constant!!
            else
                b(i) = b(i-1);
            end
            % Allocate (the last value of time_x=lookback_period
            if size(results,1) == size(snap_x,2) + 1
                yf(i) = results' * [1;snap_x(size(snap_x,1),:)'];
            else
                yf(i) = yf(i-1);
            end
        end        
end
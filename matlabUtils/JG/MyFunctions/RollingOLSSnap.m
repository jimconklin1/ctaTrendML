function [intcpt, b,yf] = RollingOLSSnap(t, x, y, parameters, method)

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
[nsteps, ncols] = size(y); 

b = zeros(1, ncols);  
intcpt = zeros(1, ncols);  
yf = zeros(1, ncols); 

if size(parameters,2) == 1
    lookback_period = parameters(1,1);  
    intercept = 0;
elseif size(parameters,2) == 2
    lookback_period=parameters(1,1); 
    intercept = 1;
    ct_x = ones(lookback_period,1);  
end
% % Find the first cell to start the code
% start_date = zeros(1,1);
% for i=1:nsteps
%     if ~isnan(y(i))% &&  ~isnan(x(i)) %&& x(i)~=0 && y(i)~=0
%         start_date(1,1) = i;
%     break
%     end
% end

switch method
  case 'regress'    
        snap_x = x(t-lookback_period+1:t,:);  
        if intercept == 1
            snap_x = [ct_x, snap_x];
        elseif intercept == 0
            snap_x = snap_x;
        end   
        for j=1:ncols
            % Snap data for y
            snap_y = y(t-lookback_period+1:t, j);              
            % Regress
            results = regress(snap_y, snap_x);  
            % Assign
            if size(results,1) == intercept + 1
                intcpt(1,j) = results(intercept , 1); % return intercept                    
                b(1,j) = results(intercept + 1 , 1);     % return slope
            end
            % Allocate (the last value of time_x=lookback_period
            if size(results,1) == intercept + 1
                yf(1,j) = results' * snap_x(size(snap_x,1),:)';
            end
        end
  case 'robustfit'    
        % Snap data for x
        snap_x = x(t-lookback_period+1:t,:); 
        for j=1:ncols            
            % Snap data for y
            snap_y = y(t-lookback_period+1:t,j);              
            % Compute 
            results = robustfit(snap_x, snap_y);  
            % Assign
            if size(results,1) == intercept + 1
                intcpt(1,j) = results(1, 1); % return intercept
                b(1,j) = results(2,1); %!!!!(2,1) as 1st row is constant!!
            end
            % Allocate (the last value of time_x=lookback_period
            if size(results,1) == size(snap_x,2) + 1
                yf(1,j) = results' * [1;snap_x(size(snap_x,1),:)'];
            end
        end
end
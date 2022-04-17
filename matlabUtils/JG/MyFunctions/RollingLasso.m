function [b,yf] = RollingLasso(x, y, parameters)

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


% -- Define Parameters --
nsteps = size(x,1); 
bmat = zeros(size(x));  
yf = zeros(nsteps,1);

lookback = parameters(1,1);  
lag = parameters(1,2); 
start_date= parameters(1,3); 

% Find the first cell to start the code
%start_date = zeros(1,1);
%for i=1:nsteps
%    if ~isnan(x(i)) &&  ~isnan(y(i)) && x(i)~=0 && y(i)~=0
%        start_date(1,1) = i;
%    break
%    end
%end

 
for i=start_date+lookback:nsteps
    % Snap data for x
    snap_x = x(i-lookback+1-lag:i-lag,:);        
    % Snap data for y
    snap_y = y(i-lookback+1:i);              
    % Regress
    [b fitinfo] = lasso(snap_x,snap_y,'Alpha',0.5, 'NumLambda',100); 
    b=b';
    if size(b,2)==size(snap_x,2)
        b=mean(b,1);
        bmat(i,:)=b;
    end
end

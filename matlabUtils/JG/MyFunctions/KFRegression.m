function [yhat, e, beta, Q, R, P, K] = KFRegression(x,y, DeltaInit, VeInit)

%__________________________________________________________________________
%
% This model runs  Kalman-Filter regression
% Input
% x = regressor
% y = regressee
% DeltaInit = initialisation value for delta
% note: delta=1 gives fastest change in beta, 
%               delta=0.000....1 allows no change (like traditional linear regression).
% VeInit
% Output
% beta = state prediction. 
% R =state covariance prediction. 
% yhat = measurement prediction. 
% Q = measurement variance prediction. 
% e =  measurement prediction error
% K =  Kalman gain 
% P = State covariance update. 
% Joel Guglietta - September 2013
%
%__________________________________________________________________________

    % Augment x with ones to  accomodate possible offset in the regression
    % between y vs x.
    nsteps = size(x,1);
    x=[x ones(nsteps,1)];    % the vector column of ones allows to compute the average spread, very useful then to extract signal
    delta=DeltaInit;        % speed adjustment for beta
    yhat=NaN(size(y));      % measurement prediction
    e=NaN(size(y));         % measurement prediction error
    Q=NaN(size(y));         % measurement prediction error variance
    % -- For clarity, denote R(t|t) by P(t) - Initialize R, P and beta. --
    R=zeros(2);
    P=zeros(2);
    beta=NaN(2, size(x, 1));
    Vw=delta/(1-delta)*eye(2);
    Ve=VeInit;
    % -- Initialize beta(:, 1) to zero --
    beta(:, 1)=0;
    % -- Given initial beta and R (and P) --
    for t=1:length(y)
        if (t > 1)
            beta(:, t)=beta(:, t-1);  % state prediction. 
            R=P+Vw;                   % state covariance prediction. 
        end
        yhat(t)=x(t, :)*beta(:, t);   % measurement prediction. 
        Q(t)=x(t, :)*R*x(t, :)'+Ve;   % measurement variance prediction. 
        % Observe y(t)
        e(t)=y(t)-yhat(t);            % measurement prediction error
        K=R*x(t, :)'/Q(t);            % Kalman gain
        beta(:, t)=beta(:, t)+K*e(t); % State update. 
        P=R-K*x(t, :)*R;              % State covariance update.    
    end

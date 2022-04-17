function z = RollingLogit(c, X, LagDiff, LagStructure, Lookback_Period)

%__________________________________________________________________________
%
% Rolling rogit
% INPUT
% c = time series of close on which we compute the change
% X = set of explaining variables
% LagDiff = the lag for the momentum.
%           note: one want to forecast the direction of the move, for e.g.
%           a weekly move on a daily time series, LagDiff = 5;
% LagStructure = the lag-structure for the factors
%           note: for instance if you think that there is a lag of 20-day
%           between the explaining variables and the direction of the
%           momentun, you write LagStructure = 20;
% Lookback_Period = Period over which you estimate the Rolling Logistic
% Regression
%
% note: Understanding the Logistic regression
% 1. in a Bayes network, you usually consider a supervised learning
% algorithm problem in which we wish to approximate an unknown target
% function. If Y is a boolean-valued random variable and X is a vector
% containing n boolean attributes so that X = <X1, X2, ..., Xn>, 
% applying Bayes:
% P(Y=y(i) | X=x(k)) = [P(X=x(k) | Y = y(i)) * P(Y=y(i)] / ...
%                      Sum_j[P(X=x(k) | Y=y(i)) * P(Y=y(j))]
% So in learning classifiers based on Bayes rule, one way to learn P(Y | X)
% is to use the training data to estimate P(X | Y) and P(Y).
% 2. Logistic regression is a function approximation algorithm that uses
% training data to directly estimate P(Y|X).
% More precisely, if X is the epxlaining data, A a matrix of coefficient, 
% the algorithm computes ln(P(Y|X) / 1-P(Y|X)) = AX + B, i.e. regress the
% natural log of the odd ratio on X (we do this in order to cap P(Y|X)).
%
% Joel Guglietta - January 2014
%
%__________________________________________________________________________

% -- Dimension & Prelocate amtrix --
[nsteps, ncols] = size(c);
z = zeros(size(c));

% -- Compute Difference over LagDiff --
cdiff = zeros(size(c));
for i=LagDiff+1:nsteps
    cdiff(i,:) = c(i,:) - c(i-LagDiff,:);
end
cdiff = cdiff > 0;

% -- Compute Rollling Logit regression --
for j=1:ncols
    for i = Lookback_Period + LagStructure : nsteps
        % Use a logistic regression to try to classify "up" and "downn".
        % The glmfit function fits a "generalized" linear model that allows
        % for linking functions such as the logistic function.
        % By specifying 'binomial', the distribution uses the binomial 
        % distribution and the logit function as the linking function.
        X_snap = X(i-Lookback_Period+1-LagStructure:i-LagStructure,j);
        cdiff_snap = cdiff(i-Lookback_Period+1:i,j);
        model = glmfit(X_snap, cdiff_snap, 'binomial');
        % The glmval function evaluates a given model for a set of data with a
        % given linking function
        y_hat = glmval(model, X_snap, 'logit');
        % From the model predictions,figure out the best classification
        % given this model by thresholding y_hat at 0.5. This means that we
        % assign values with a probability greater than 0.5 into the "up"
        % category.
        class = y_hat > 0.5;
        % Assign
        z(i,j) = class(length(class),1);
    end
end
% -- Reclassifiy
z(find(z<1)) = -1;
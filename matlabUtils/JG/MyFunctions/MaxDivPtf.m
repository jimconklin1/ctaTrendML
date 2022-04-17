%
%__________________________________________________________________________
% Maximum Risk Diversification
%
% Inout
%__________________________________________________________________________
%

global SigmaMDPtf 
global DiagSigmaMDPtf

x = rand(200,4);

[N,M]=size(x);
l=1;
% Covariance shringake estimator (this estimator is a weighted average of
% the sample covariance matrix and a "prior" or "shrinkage target")
shrinkcoeff = .5;
[SigmaMDPtf , shrinkage] = shrinkcov(x, shrinkcoeff);
DiagSigmaMDPtf = diag(SigmaMDPtf);
Aeq = ones(M,1)';
beq = 1;            % the right hand side of the equality constraint
lb = zeros(M,1);    % the lower bound
ub = lb + Inf;      % the upper bound
x0 = lb + 1/(M);    % the initial value of the iterations
wgt = fmincon(@DP, x0, [], [], Aeq, beq, lb, ub);
% minimises fun subject to the linear equalities Aeq * x = beq and A * x > b
% if no inequalities exist, set A = [] and b = [].
% DP-function
% the DP-function is the objective function in the maximisation problem in
% the MD portfolio. It gets as input the weights vector (x), the
% variance-covariance matrix (sigma) and its diagonal (d). The output is
% the value f computed as below

 
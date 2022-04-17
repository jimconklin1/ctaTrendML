% Inputs:
%    ddCtrl = drawdown control parameter vector = [A,alpha,lambda,mu,sigma]
% 		  A = risk aversion factor, typically between 10 and 30
%     alpha = 1 - max allowed decayed drawdown limit (i.e., 1-15% = 0.85)
%    lambda = decay rate (approx 5% / yr)
%        mu = expected mean of excess return process
%     sigma = expected stdev of return of process
% 
%         u = 1 - current drawdown

function ddRisk = ddScale(params, u)

[ddRisk, ~] = calcDDrisk(params, u); 

end % fn
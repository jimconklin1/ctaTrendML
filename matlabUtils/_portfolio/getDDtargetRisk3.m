function [targetRisk, currScale] = getDDtargetRisk3(ddParam,decayedDrawdown,timeUnit) 
% get the target risk for a given trade date due to the drawdown 
% target risk is in monthly unit, i.e. 0.039 means we want to take a mnthly
% risk of 3.9%. 
%
% ddParam = [A, alpha, lambda, mu, sigma] 
%         = [coeffRiskAversion, 1-maxDD, decayRate, expectedReturn, expectedVol]
if nargin < 3
   timeUnit = 'daily';
   timeScale = sqrt(260);
end 
switch timeUnit
    case 'daily'
       timeScale = sqrt(260);
    case 'monthly'
       timeScale = sqrt(12);
    case 'annual'
       timeScale = 1;
    case 'yearly'
       timeScale = 1;
end 
u = 1 - decayedDrawdown; 
ddcParam = [ddParam(1:3),ddParam(4)/ddParam(5), 1.0]; % [A, alpha, lambda, SR, 1]
currScale = ddScale(ddcParam, u); 
targetRisk = currScale/ddcParam(1)*ddcParam(4)/timeScale; 
end % fn 

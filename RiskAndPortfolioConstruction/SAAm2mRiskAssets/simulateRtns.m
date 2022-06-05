function o = simulateRtns(sr,sig,corr,T,per)
% call: 
% simulateRtns([0.5,0.75],[.05,.1],[[1,.25];[.25,1]],10,'monthly')
% Units ALWAYS annual
% sr = row vector of Sharpe ratios (1 per series)
% sig = row vector of vols
% corr = correlation matrix
% T = number of periods
if nargin < 5 || isempty(per)
   per = 'annual';
end 
mu = sr.*sig;
switch per
    case 'quarterly'
        T = round(T*4,0);
        mu = mu/4;
        sig = sig/sqrt(4);
    case 'monthly'
        T = round(T*12,0);
        mu = mu/12;
        sig = sig/sqrt(12);
    case 'weekly'
        T = round(T*52,0);
        mu = mu/52;
        sig = sig/sqrt(52);
    case 'daily'
        T = round(T*260,0);
        mu = mu/260;
        sig = sig/sqrt(260);
end
% portsim(ExpReturn,ExpCovariance,NumObs,RetIntervals,NumSim,Method)
N = length(mu);
if N > 1
    temp = repmat(sig,[N,1]);
    sigma = temp.*corr.*temp';
else 
    sigma = sig^2;
end 
o=portsim(mu,sigma,T,1,1,'Expected');
end
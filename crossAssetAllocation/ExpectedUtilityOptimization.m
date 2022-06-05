function w = ExpectedUtilityOptimization(utilityFunction,param,shrinkageRP,ers,covar,coskew,cokurt,periods,longOnly,assetLiq,assetRBC,assetIC,assetIlliquid,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,capCons)

if ~exist('capCons','var')||isempty(capCons)
   capCons.opt = false;
end

rpw = 0.5*EqualRiskContribution(covar,longOnly)+...
      0.5*RiskParity(covar,longOnly); 
rpwVar = rpw'*covar*rpw;
% we relax sum(wts) = 1 here and make var(wts) = targetVariance, since wts will be imposed in optimization 
rpw = rpw*sqrt(varianceTarget)/sqrt(rpwVar); % varianceTarget is monthly units at this level in the program (as are E[rts], covar)

% Prior specs:
% rpw =  0.67*EqualRiskContribution(covar,longOnly,varianceTarget)+...
%        0.33*RiskParity(covar,longOnly,varianceTarget);
% rpw = EqualRiskContribution(covar,longOnly,varianceTarget);
% rpw = RiskParity(covar,longOnly,'simple',varianceTarget);

% if varianceTarget > 0
%    rpw = EqualRiskContribution(covar,longOnly,varianceTarget);
% else
%    rpw = RiskParity(covar,longOnly);
% end

% For evaluation:
% xx = [4*rpw'*ers,sqrt(4*rpw'*covar*rpw),4*rpw'*ers/sqrt(4*rpw'*covar*rpw),rpw'*assetLiq,rpw'*assetRBC,rpw']; disp(xx)

if utilityFunction == "Power"
    objFun =@(w)-PowerUtility(param,ers,covar,coskew,cokurt,periods,w)+shrinkageRP*vecnorm(w-rpw);
elseif utilityFunction == "Log"
    objFun =@(w)-LogUtility(ers,covar,coskew,cokurt,periods,w)+shrinkageRP*vecnorm(w-rpw);
elseif utilityFunction == "Exponential"
    objFun =@(w)-ExponentialUtility(param,ers,covar,coskew,cokurt,periods,w)+shrinkageRP*vecnorm(w-rpw);
elseif utilityFunction == "MeanVariance"
    objFun =@(w)-MeanVarianceUtility(param,ers,covar,periods,w)+shrinkageRP*vecnorm(w-rpw);
elseif utilityFunction == "Linear"
    objFun =@(w)-LinearUtility(param,ers,covar,periods,w)+shrinkageRP*vecnorm(w-rpw);
elseif utilityFunction == "Quadratic"
    objFun =@(w)-QuadraticUtility(param,ers,covar,periods,w)+shrinkageRP*vecnorm(w-rpw);
elseif utilityFunction == "InfoRatio"
    objFun =@(w)-InfoRatio(param,ers,covar,periods,w)+shrinkageRP*vecnorm(w-rpw);
end

nAssets = size(covar,2);
lb=zeros(nAssets,1);
ub=ones(nAssets,1);
Aeq=ones(1,nAssets);
beq=ones(1,1);

nLinearInequalities = (liquidationLimit > 0) + (RBCLimit > 0) + (ICLimit > 0) + (illiquidLimit > 0);
A=ones(nLinearInequalities,nAssets);
b=ones(nLinearInequalities,1);
nLIC = 1;
if liquidationLimit > 0
    A(nLIC,:) = assetLiq';
    b(nLIC,1) = liquidationLimit;
    nLIC = nLIC +1;
end
if RBCLimit> 0
    A(nLIC,:) = assetRBC';
    b(nLIC,1) = RBCLimit;
    nLIC = nLIC +1;
end
if ICLimit > 0
    A(nLIC,:) = assetIC';
    b(nLIC,1) = ICLimit;
    nLIC = nLIC +1;
end
if illiquidLimit > 0
    A(nLIC,:) = assetIlliquid';
    b(nLIC,1) = illiquidLimit;
    nLIC = nLIC + 1; %#ok<NASGU>
end

if longOnly == false
    lb = [];
    ub =[];
end

if capCons.opt
   ub = capCons.ub;
   lb = capCons.lb;
end

nonlcon = [];
riskMeasure = "";
if varianceTarget > 0 
   riskMeasure = "Variance";
   riskLimit = varianceTarget*(12/periods); % Inconsistency in handling of time units w/in contraints; must adjust "riskLimit" to have annual units
end

if riskMeasure == "VaR"
    nonlcon =@(w)VaRConstraint(w,ers,covar,coskew,cokurt,periods,riskLimit);
elseif riskMeasure == "ExpectedShortfall"
    nonlcon =@(w)ESConstraint(w,ers,covar,coskew,cokurt,periods,riskLimit);
elseif riskMeasure == "Variance"
    nonlcon =@(w)VarianceConstraint(w,covar,periods,riskLimit);
elseif riskMeasure == "ExpectedMaxDrawdown"
    nonlcon =@(w)EMDDConstraint(w,ers,covar,periods,riskLimit);
end

w0 = ones(nAssets,1)/nAssets;
[w,fw,exitflag]=fmincon(objFun,w0,A,b,Aeq,beq,lb,ub,nonlcon); %#ok<ASGLU>
if exitflag == -2
    uiwait(warndlg("No optimal portfolio been found under the constraints"));
end
end

function [c,ceq] = VarianceConstraint(w,covar,periods,riskLimit)
varp = (w'*covar*w)*(12/periods);

c=varp-riskLimit;
ceq=[];

end

function [c,ceq] = VaRConstraint(w,ers,covar,coskew,cokurt,periods,riskLimit)
mup = (ers'*w)*(12/periods);
varp = (w'*covar*w)*(12/periods);
skewp = PortfolioSkewness(coskew,w)*(12/periods);
kurtp = PortfolioKurtosis(cokurt,w)*(12/periods)+3*(12/periods)*((12/periods)-1)*(w'*covar*w)^2;

c = ValueAtRisk(mup,sqrt(varp),skewp,kurtp,0.05)-riskLimit;
ceq=[];

end

function [c,ceq] = ESConstraint(w,ers,covar,coskew,cokurt,periods,riskLimit)
mup = (ers'*w)*(12/periods);
varp = (w'*covar*w)*(12/periods);
skewp = PortfolioSkewness(coskew,w)*(12/periods);
kurtp = PortfolioKurtosis(cokurt,w)*(12/periods)+3*(12/periods)*((12/periods)-1)*(w'*covar*w)^2;

c = ExpectedShortfall(mup,sqrt(varp),skewp,kurtp,0.05)-riskLimit;
ceq = [];

end

function [c,ceq] = EMDDConstraint(w,ers,covar,periods,riskLimit)
mup = ers'*w;
varp = w'*covar*w;

c = ExpectedMaxDrawdown(mup,sqrt(varp),(12/periods))-riskLimit;
ceq = [];

end

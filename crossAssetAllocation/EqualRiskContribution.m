function w = EqualRiskContribution(covar,longOnly,targetVar)

m = size(covar,1);
w = ones(m,1)*1/m;
%Apply least squares with postivity constraint
fun = @(x)RiskContributionDeviation(covar,x);
lb = [];
if longOnly
  lb = zeros(1,m);
end
if nargin >= 3 && ~(isempty(targetVar) || isnan(targetVar))
   nonlcon = @(x)VarianceConstraint(covar,x,targetVar);
   A = ones(1,m);
   b = ones(1,1);
   [w,fval,exitflag] = fmincon(fun,w,A,b,[],[],lb,[],nonlcon);
else
   Aeq = ones(1,m);
   beq = ones(1,1);
   [w,fval,exitflag] = fmincon(fun,w,[],[],Aeq,beq,lb,[],[]);
end 
if exitflag == -2
    uiwait(warndlg("No feasible ERC portfolio been found under the constraints"));
end
end

function totalDev = RiskContributionDeviation(covar,w)
rc = w.*(covar*w);
varp =w'*covar*w;
num = mean(rc);
m = size(rc,1);
temp = (rc/varp - repmat(num/varp,[m,1])).^2;
%[rc/varp,repmat(num/varp,[m,1]),rc/varp-repmat(num/varp,[m,1]),temp]
totalDev = sum(temp);
end

function [c,ceq] = VarianceConstraint(covar,w,targetVar)
c=[];
ceq=w'*covar*w - targetVar;
end
function w = RiskParity(covar,longOnly,rpDefn,targetVar)

if nargin < 3 || isempty(rpDefn)
   rpDefn = 'simple';
end

if strcmpi(rpDefn,'simple')
    w = 1./sqrt(diag(covar));
    w = (1/nansum(w))*w;
else % marginal contribution to risk defn
    m = size(covar,1);
    w = ones(m,1)*1/m;
    
    %Apply least squares with postivity constraint
    fun = @(x)RiskContributionDeviation(covar,x);
    Aeq = ones(1,m);
    beq = ones(1,1);
    lb=[];
    if longOnly
        lb = zeros(1,m);
    end
    w = fmincon(fun,w,[],[],Aeq,beq,lb,[]);
end

if nargin > 3 
   var = w'*covar*w;
   mult = sqrt(targetVar)/sqrt(var);
   w = mult*w;
end

end

function totalDev = RiskContributionDeviation(covar,w)
rc = w.*(covar*w);
varp =w'*covar*w;
m = size(rc,1);
totalDev = 0.0;
for i=1:m
    totalDev = totalDev + (rc(i,1)/varp-1/m)^2;
end
end


function [alpha, beta,error] = EstimateFactorExposure(y, factors,selectFactor)

n = size(y,1);
nFactors = size(factors,2);

X=ones(n,nFactors+1);
X(:,2:nFactors+1) = factors;

if selectFactor == false
b= (X'*X)\(X'*y);
alpha = b(1);
beta = b(2:nFactors+1,1);
error = y-alpha-factors*beta;
else
whichstats={'beta','tstat'};
stats = regstats(y,factors,'Linear',whichstats);
b=stats.beta;
alpha = b(1);
beta = b(2:nFactors+1,1);
tstat = stats.tstat;

for i=2:nFactors+1
    if tstat.pval(i,1)>0.25
        beta(i-1,1) = 0;
    elseif tstat.pval(i,1)>0.1
        beta(i-1,1) = beta(i-1,1)/2;
    end
end

error = y-alpha-factors*beta;
merr = mean(error,1);
error = error - merr;
alpha = alpha + merr;

end

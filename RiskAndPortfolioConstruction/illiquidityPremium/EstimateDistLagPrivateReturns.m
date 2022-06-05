%@brief De-smooth private asset returns
%@param dates The date vector
%@param privateReturns The smooth private asset returns
%@param publicReturns The returns of a public benchmark
%@param L The max lag
%@return Unsmooth true economic returns
function p = EstimateDistLagPrivateReturns(dates, privateReturns, publicReturns,riskFreeReturns, L)

n = size(dates,1);

[dates,indexes] = sort(dates);
privateReturns = privateReturns(indexes);
publicReturns =  publicReturns(indexes);
riskFreeReturns = riskFreeReturns(indexes);
origPrivateReturns = privateReturns;
quarterly = sum(isnan(privateReturns)) > 2*n/3-2;
if quarterly
    indexes = ~isnan(privateReturns);
    privateReturns = privateReturns(indexes);
    for i= 1:n
        if indexes(i)
            publicReturns(i) = (1+publicReturns(i-2))*(1+publicReturns(i-1))*(1+publicReturns(i))-1;
            riskFreeReturns(i) = (1+riskFreeReturns(i-2))*(1+riskFreeReturns(i-1))*(1+riskFreeReturns(i))-1;
        end
    end
    publicReturns = publicReturns(indexes);
    riskFreeReturns = riskFreeReturns(indexes);
    n=size(publicReturns,1);
end

alpha = 0.0;
beta = 1.0;
phi = ones(1,L+1)/(L+1.0);
params = zeros(1,L+3);
params(1) = alpha;
params(2) = beta;
params(3:L+3) = phi;

lb=zeros(1,L+3);
lb(1) = -100.0;
lb(2) = -1.0;
ub=ones(1,L+3);
ub(1) = 100.0;
ub(2) = 1.0;

fun = @(x)PrivateReturnObjective(privateReturns,publicReturns,riskFreeReturns,x);
Aeq = ones(1,L+3);
Aeq(1) = 0;
Aeq(2) = 0;
beq = ones(1,1);
params = fmincon(fun,params,[],[],Aeq,beq,lb,ub);
phi = params(3:L+3);

%check validity
ars=abs(roots(fliplr(phi)));
if min(ars) < 1.0
    params = fmincon(fun,params,[],[],Aeq,beq,lb,ub,@PACFConstraint);
    phi = params(3:L+3);
end

p.alpha = params(1);
p.beta = params(2);
p.phi = phi;
end % fn

function wse = PrivateReturnObjective(privRets, pubRets, rfRets,params)

nParams = size(params,2);
alpha = params(1);
beta = params(2);
phi = params(3:nParams);
L = size(phi,2)-1;

nData = size(privRets,1);
n = nData-L;
err = zeros(n,1);

%Compute error vector
for i = 0 : n-1
    t = nData-i;
    err(n-i)=privRets(t)-alpha;
    for j=0:L
        err(n-i) = err(n-i)-phi(j+1)*beta*(pubRets(t-j)+(1-beta)*rfRets(t-j));
    end
end

%Compute covariance matrix
C = zeros(n,n);
for i= 1:n
    for j=0:L
        if i+j <= n
            for k=0:L-j
                C(i,i+j)=C(i,i+j)+phi(1+k)*phi(1+k+j);
            end
        end
        if j>0 && i-j>0
            for k=j:L
                C(i,i-j)=C(i,i-j)+phi(1+k)*phi(1+k-j);
            end
        end
    end
end

wse = err'*C*err;
end % fn

function [nonlincon,ceq] = RootsConstraint(params)
nParams = size(params,2);
phi = params(3:nParams);
r = roots(fliplr(phi));
nonlincon = 1- abs(r);
ceq = [];
end % fn

function [nonlincon,ceq] = PACFConstraint(params)
nParams = size(params,2);
phi = params(3:nParams);
phi = phi/phi(1);
L = size(phi,2)-1;
pacf = zeros(L,L);
pacf(L,:) = phi(2:L+1);
nonlincon = zeros(L,1);
nonlincon(L) = abs(pacf(L,L))-1;
for k = L-1:1
    for j=1:k
        pacf(k,j) = (pacf(k+1,k+1)*pacf(k+1,k+1-j)+pacf(k+1,j))/sqrt(1-pacf(k+1,k+1)^2);
    end
    nonlincon(k) = abs(pacf(k,k))-1;
end
ceq = [];
end % fn

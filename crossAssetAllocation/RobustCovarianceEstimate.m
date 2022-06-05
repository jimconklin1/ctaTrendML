function C = RobustCovarianceEstimate(historicalData,factorData,robustMethod,factorVols)

n = size(historicalData, 1);
C = cov(historicalData);

if robustMethod == "RMT"
    C = RobustCovarianceRMT(n,C);
elseif robustMethod == "Shrinkage"
    C = RobustCovarianceShrinkage(n,C);
elseif robustMethod == "Factor"
    C = RobustCovarianceFactor(historicalData,factorData);
elseif robustMethod == "FactorView"
    C = RobustCovarianceFactorView(historicalData,factorData,factorVols);
end

end


% argument: C is a covariance matrix
% Warning: the dimension p cannot be too small
function robustC = RobustCovarianceRMT(n,C)
p = size(C,1);
S = eye(p);
for i=1:p
    S(i,i) = sqrt(C(i,i));
end
CR = S^-1*C*S^-1;
[V,D] = eig(CR);
evs = diag(D);
[Q,s] = FitMarcenkoPastur(n,p,evs);
lambdap = s*s*(1+sqrt(1/Q))*(1+sqrt(1/Q));

indexes = evs <= lambdap;
lambdaavg = sum(evs(indexes))/sum(indexes);
evs(indexes) = lambdaavg;
CR = V*diag(evs)*V';
CR(logical(eye(p))) = 1.0;
robustC = S*CR*CR;
end


% argument: C is a covariance matrix
function robustC = RobustCovarianceShrinkage(n,C)

p=size(C);
alpha1 = 0.0;
alpha = 0.5;
robustC = (1-alpha)*C+alpha*trace(C)/p*eye(p);

while abs(alpha-alpha1) > 1.0E-6
    alpha1 = alpha;
    alpha = min(((1-2/p)*trace(robustC*C)+trace(robustC)^2)/((n+1-2/p)*trace(robustC*C)+(1-n/p)*trace(robustC)^2),1);
    robustC = (1-alpha)*C+alpha*trace(C)/p*eye(p);
end

end

% argument: historicalData is historical observatioins for the RVs
%            factoData is a contemporary observations for factors
function robustC = RobustCovarianceFactor(historicalData,factorData)

%Estimate factor models
nData = size(historicalData,2);
nFactors = size(factorData,2);
B= zeros(nData,nFactors);
errors = historicalData;

for i=1:nData
    [alpha,beta,errors(:,i)] = EstimateFactorExposure(historicalData(:,i),factorData,true);
    B(i,1:nFactors) =beta';
end

%Estimate covariance
Ce = cov(errors);
%Force independent errors
for i=1:nData
    for j=1:nData
        if i ~= j
            Ce(i,j) = 0;
        end
    end
end
            
Cf = cov(factorData);

robustC = B*Cf*B'+Ce;
end

% argument: historicalData is historical observatioins for the RVs
%           factorData is a contemporary observations for factors
%           factorsVols is a vector of forward looking vols factor data are
%              believed to have
function robustC = RobustCovarianceFactorView(historicalData,factorData,factorVolView)

%Estimate factor models
nData = size(historicalData,2);
nFactors = size(factorData,2);
B= zeros(nData,nFactors);
errors = historicalData;

for i=1:nData
    [alpha,beta,errors(:,i)] = EstimateFactorExposure(historicalData(:,i),factorData,true);
    B(i,1:nFactors) =beta';
end

%Estimate covariance
Ce = cov(errors);
%Force independent errors
for i=1:nData
    for j=1:nData
        if i ~= j
            Ce(i,j) = 0;
        end
    end
end

Ccorr = corrcoef(factorData); 
Cf = repmat(factorVolView,[1,nFactors]).*Ccorr.*repmat(factorVolView',[nFactors,1]); 

robustC = B*Cf*B'+Ce;
end


%Apply ML estimate
function [Q,s] = FitMarcenkoPastur(n, p, x)
Q = n/p;
maxs = sqrt(max(x))/(1+sqrt(1/Q));
mins = sqrt(min(x))/(1-sqrt(1/Q));

LF = @(y)-MarcenkoPasturLikelihood(y,x);
lb = [0, mins];
ub = [100,maxs];
y = zeros(2,1);
y(1) = Q;
y(2) = (maxs+mins)/2;
y = fmincon(LF,y,[],[],[],[],lb,ub);
Q = y(1);
s = y(2);
end

function LL = MarcenkoPasturLikelihood(y,x)
Q = y(1);
s = y(2);
LL = 0.0;
p = size(x,1);
sqrtq= sqrt(1/Q);
for i=1:p
    lambdap = s*s*(1+sqrtq)*(1+sqrtq);
    lambdam = s*s*(1-sqrtq)*(1-sqrtq);
    LL = LL + ln(1-x(i)/lambdap)+ln(x(i)/lambdam-1);
end
end
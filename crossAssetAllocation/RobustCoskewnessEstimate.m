function coskew = RobustCoskewnessEstimate(historicalData,factorData,robustMethod)

if robustMethod == "Homogeneous"
    coskew = RobustCoskewEstimateHomogeneous(historicalData);
elseif robustMethod == "Factor"
    coskew = RobustCoskewEstimateFactor(historicalData,factorData);
end

end

% argument: historicalData is historical observatioins for the RVs
%            factoData is a contemporary observations for factors
function coskew = RobustCoskewEstimateFactor(historicalData,factorData)

%Estimate factor models
nData = size(historicalData,2);
nFactors = size(factorData,2);
B= zeros(nData,nFactors);
errors = historicalData;

for i=1:nData
    [alpha,beta,errors(:,i)] = EstimateFactorExposure(historicalData(:,i),factorData,true);
    B(i,1:nFactors)=beta';
end

%Estimate coskewness
Se = SampleCoskewness(errors);
%Force independent errors
for i=1:nData
    for j=1:nData
        for k=1:nData
            if ~(i==j && j==k)
                Se(j,nData*(i-1)+k) = 0.0;
            end
        end
    end
end

Sf = SampleCoskewness(factorData);

coskew = B*Sf*Kronecker(B',B')+Se;
end


% argument: historicalData is historical observatioins for the RVs
% Mostly follow the paper by Martellini and Ziemann (2009) "Improved Estimates of
% Higher-Order Comoments and Implications for Portfolio Selection"
function coskew = RobustCoskewEstimateHomogeneous(historicalData)

cdata = historicalData - mean(historicalData,2);
N = size(cdata,1);
mu2 = zeros(N,1);
mu4 = zeros(N,1);
for i =1:N
    mu2(i) = mean(cdata(:,i).^2);
    mu4(i) = mean(cdata(:,i).^4);
end

%Estimate sample coskewness
S = SampleCoskewness(cdata);

%Average cross terms
sum_r2 = 0.0;
for i=1:N
    for j=i+1:N
        sum_r2 = sum_r2 + mean(cdata(:,i).*cdata(:,i).*cdata(:,j))/sqrt(mu4(i)*mu2(j));
        sum_r2 = sum_r2 + mean(cdata(:,j).*cdata(:,j).*cdata(:,i))/sqrt(mu4(j)*mu2(i));
    end
end
avg_r2 = sum_r2/(N*(N-1));

sum_r5 = 0.0;
for i=1:N
    for j=i+1:N
        sum_r5 = sum_r5 + mean((cdata(:,i).^2).*(cdata(:,j).^2))/sqrt(mu4(i)*mu4(j));
    end
end
avg_r5 = sum_r5/(N*(N-1))*2;

sum_r4 = 0.0;
for i=1:N
    for j=i+1:N
        for k=j+1:N
            sum_r4 = sum_r4 + mean(cdata(:,i).*cdata(:,j).*cdata(:,k))/sqrt(mu2(i)*sqrt(mu4(j)*mu4(k))*avg_r5);
            sum_r4 = sum_r4 + mean(cdata(:,i).*cdata(:,j).*cdata(:,k))/sqrt(mu2(j)*sqrt(mu4(i)*mu4(k))*avg_r5);
            sum_r4 = sum_r4 + mean(cdata(:,i).*cdata(:,j).*cdata(:,k))/sqrt(mu2(k)*sqrt(mu4(i)*mu4(j))*avg_r5);
        end
    end
end
avg_r4 = sum_r4/(N*(N-1)*(N-2))*2;

%Replace cross terms
for i=1:N
    for j=1:N
        for k=1:N
            if i==j && j~=k
                S(j,nData*(i-1)+k) = avg_r2*sqrt(mu4(i)*mu2(k));
            elseif i==k && j~=k
                S(j,nData*(i-1)+k) = avg_r2*sqrt(mu4(i)*mu2(j));
            elseif j==k && i~=k
                S(j,nData*(i-1)+k) = avg_r2*sqrt(mu4(j)*mu2(i)); 
            elseif i~=j && j~=k && i~=k
                S(j,nData*(i-1)+k) = avg_r4*(sqrt(mu2(i)*sqrt(mu4(j)*mu4(k))*avg_r5)+sqrt(mu2(j)*sqrt(mu4(i)*mu4(k))*avg_r5)+sqrt(mu2(k)*sqrt(mu4(i)*mu4(j))*avg_r5))/3; 
            end
        end
    end
end

coskew = S;
end


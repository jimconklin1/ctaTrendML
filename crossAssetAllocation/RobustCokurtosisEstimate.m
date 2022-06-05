function cokurt = RobustCokurtosisEstimate(historicalData,factorData,robustMethod)

if robustMethod == "Homogeneous"
    cokurt = RobustCokurtosisEstimateHomogeneous(historicalData);
elseif robustMethod == "Factor"
    cokurt = RobustCokurtosisEstimateFactor(historicalData,factorData);
end

end

% argument: historicalData is historical observatioins for the RVs
%            factoData is a contemporary observations for factors
function cokurt = RobustCokurtosisEstimateFactor(historicalData,factorData)

%Estimate factor models
nData = size(historicalData,2);
nFactors = size(factorData,2);
B= zeros(nData,nFactors);
errors = historicalData;

for i=1:nData
    [alpha,beta,errors(:,i)] = EstimateFactorExposure(historicalData(:,i),factorData,true);
    B(i,1:nFactors)=beta';
end

%Estimate cokurtness
Ke = SampleCokurtosis(errors);
%Force independent errors
for i=1:nData
    for j=1:nData
        for k=1:nData
            for l=1:nData
                if ~((i==j && j==k && k==l) || (i==j && k==l) || (i==k && j==l) || (i==l && j==k))
                    Ke(k,(nData*(i-1)+j-1)*nData+l) = 0.0;
                end
            end
        end
    end
end

Kf = SampleCokurtosis(factorData);

cokurt = B*Kf*Kronecker(B',Kronecker(B',B'))+Ke;
end

% argument: historicalData is historical observatioins for the RVs
function cokurt = RobustCokurtosisEstimateHomogeneous(historicalData)

cdata = historicalData - mean(historicalData,2);
N = size(cdata,1);
mu2 = zeros(N,1);
mu4 = zeros(N,1);
mu6 = zeros(N,1);
for i =1:N
    mu2(i) = mean(cdata(:,i).^2);
    mu4(i) = mean(cdata(:,i).^4);
    mu6(i) = mean(cdata(:,i).^6);
end

%Estimate sample coskewness
K = SampleCokurtosis(cdata);

%Average cross terms
sum_r3 = 0.0;
for i=1:N
    for j=i+1:N
        sum_r3 = sum_r3 + mean((cdata(:,i).^3).*cdata(:,j))/sqrt(mu6(i)*mu2(j));
        sum_r3 = sum_r3 + mean((cdata(:,j).^3).*cdata(:,i))/sqrt(mu6(j)*mu2(i));
    end
end
avg_r3 = sum_r3/(N*(N-1));

sum_r5 = 0.0;
for i=1:N
    for j=i+1:N
        sum_r5 = sum_r5 + mean((cdata(:,i).^2).*(cdata(:,j).^2))/sqrt(mu4(i)*mu4(j));
    end
end
avg_r5 = sum_r5/(N*(N-1))*2;

sum_r6 = 0.0;
for i=1:N
    for j=i+1:N
        for k=j+1:N
            sum_r6 = sum_r6 + mean(cdata(:,i).*cdata(:,i).*cdata(:,j).*cdata(:,k))/sqrt(mu4(i)*sqrt(mu4(j)*mu4(k))*avg_r5);
            sum_r6 = sum_r6 + mean(cdata(:,i).*cdata(:,j).*cdata(:,j).*cdata(:,k))/sqrt(mu4(j)*sqrt(mu4(i)*mu4(k))*avg_r5);
            sum_r6 = sum_r6 + mean(cdata(:,i).*cdata(:,j).*cdata(:,k).*cdata(:,k))/sqrt(mu4(k)*sqrt(mu4(i)*mu4(j))*avg_r5);
        end
    end
end
avg_r6 = sum_r6/(N*(N-1)*(N-2))*2;

sum_r7 = 0.0;
for i=1:N
    for j=i+1:N
        for k=j+1:N
            for l=k+1:N
                sum_r7 = sum_r7 + mean(cdata(:,i).*cdata(:,j).*cdata(:,k).*cdata(:,l))/sqrt(sqrt(mu4(i)*mu4(j))*avg_r5*sqrt(mu4(k)*mu4(l))*avg_r5);
            end
        end
    end
end
avg_r7 = sum_r7/(N*(N-1)*(N-2)*N(-3))*24;

%Replace cross terms
for i=1:N
    for j=1:N
        for k=1:N
            for l=1:N
                if i==j && j==k && k ~=l
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r3*sqrt(mu6(i)*mu2(l));
                elseif i==j && j==l && k ~=l
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r3*sqrt(mu6(i)*mu2(k));
                elseif i==k && k==l && l ~=j
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r3*sqrt(mu6(i)*mu2(j));
                elseif j==k && k==l && l ~=i
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r3*sqrt(mu6(j)*mu2(i));         
                elseif i==j && k==l && j~=k
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r5*sqrt(mu4(i)*mu4(k));
                elseif i==k && j==l && j~=k
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r5*sqrt(mu4(i)*mu4(j));                    
                elseif i==l && j==k && i~=k
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r5*sqrt(mu4(i)*mu4(j));
                elseif i==j && j~=k && j~=l && k ~=l
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r6*sqrt(mu4(i)*avg_r5*sqrt(mu4(k),mu4(l)));     
                elseif i==k && j~=k && j~=l && k ~=l
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r6*sqrt(mu4(i)*avg_r5*sqrt(mu4(j),mu4(l)));
                elseif i==l && j~=k && j~=l && k ~=l
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r6*sqrt(mu4(i)*avg_r5*sqrt(mu4(j),mu4(k)));
                elseif j==k && i~=k && i~=l && k ~=l
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r6*sqrt(mu4(j)*avg_r5*sqrt(mu4(i),mu4(l)));
                elseif j==l && i~=k && i~=l && k ~=l
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r6*sqrt(mu4(j)*avg_r5*sqrt(mu4(i),mu4(k)));
                elseif k==l && i~=k && i~=j && k ~=j
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r6*sqrt(mu4(k)*avg_r5*sqrt(mu4(i),mu4(j)));                    
                elseif i~=j && j~=k && i~=k && k ~= l
                    K(k,(nData*(i-1)+j-1)*nData+l) = avg_r7*(sqrt(sqrt(mu4(i)*mu4(j))*avg_r5*sqrt(mu4(k)*mu4(l))*avg_r5)); 
                end
            end
        end
    end
end

cokurt = K;
end

%@brief De-smooth private asset returns
%@param dates The date vector
%@param privateReturns The smooth private asset returns
%@param publicReturns The returns of a public benchmark
%@param L The max lag
%@return Unsmooth true economic returns
function trueReturns = DesmoothPrivateReturns2(dates, privateReturns, params) %publicReturns,riskFreeReturns, L)

n = size(dates,1);
phi = params.phi;

[dates,indexes] = sort(dates);
privateReturns = privateReturns(indexes);
origPrivateReturns = privateReturns;
quarterly = sum(isnan(privateReturns)) > 2*n/3-2;

trueReturns = privateReturns;
for i =1:n
    for k=1:L
        if i-k>0
            trueReturns(i) = trueReturns(i) - phi(1+k)*trueReturns(i-k);
        end
    end
    trueReturns(i) = trueReturns(i)/phi(1);
end

if quarterly
    origPrivateReturns(indexes) = trueReturns;
    trueReturns = origPrivateReturns;
end


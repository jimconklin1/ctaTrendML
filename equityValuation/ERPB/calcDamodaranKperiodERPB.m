function erpb = calcDamodaranKperiodERPB(dataFrame,K)
% dataFrame is T x 5; its six columns are: 
% date, price, riskFreeRate, CF*, g_1, g_2
%    where: 
%    riskFreeRate is US Govt 10-yr or 30-yr
%    CF* is the filtered net cash flow 
%    g_1 is the short term growth rate of net cashflow pay-outs (first K periods)
%    g_2 is the long term nominal growth rate of net cashflow pay-outs

T = size(dataFrame,1); 
intRate = dataFrame(:,3);
lrGrowthRate = dataFrame(:,end);
erpb = lrGrowthRate - intRate + 0.01; % discount factor must be > growth factor in steady state
% note; in the logic below r represents the zero coupon rate at each
% maturity -- using the same rate at each maturity
CF = ones(1,K+1); 
for t = 1:T
    r = repmat(dataFrame(t,3),[1,K+1]); 
    currentPrice = dataFrame(t,2); 
    cf = repmat(dataFrame(t,4),[1,K+1]); 
    g = [repmat(dataFrame(t,5),[1,K]),dataFrame(t,6)]; % note: K+1-th 
    CF = cf(1,1:K).*((1 + g(1,1:K)).^(1:K)); 
    CF(1,K+1) = CF(1,K)*(1+g(end)); 
    fun = @calcPrice; 
    x0 = erpb(t); 
    options = optimset('Display', 'off'); 
    xx = fsolve(fun, x0, options); 
    erpb(t) = xx; 
end 

function price = calcPrice(x)
    DF = ((1 + x + r).^-(1:length(r))); 
    price = -1 * currentPrice + sum(CF(1,1:K).*DF(1,1:K)) + DF(1,K)*CF(end)/(r(end)+x-g(end));
end

end
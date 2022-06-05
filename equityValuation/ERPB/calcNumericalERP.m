function erp = calcNumericalERP(calcDates,px,dataFrame,zeroCurves,K1,K2)
% This equity risk premium calculator has the following inputs: 

%  calcDates: an array of ML numerical dates, can be daily, weekly, monthly, or quarterly, and are the days
%             at which the ERP is computed; 1 x T; calcDates(1) must be > dataFrame.date(1)
%         px: price of index or ETF; 1 x T
%  dataFrame: quarterly in periodicity; its six columns are: 
%             date (quarter end), 
%             price, 
%             realized CF (div+bb), 
%             CF* or filtered CF, 
%             g_1 or near term CF growth rate, and 
%             g_2 or long term CF growth rate
% zeroCurves: the matrix is T x 120 (30 years x 4 quarters), where each row
%             is the vector for calcDate(t) and each column is the k-th
%             maturity zero-rate
%         K1: the last quarter through with the short-term growth rate g_1 applies
%         K2: the final quarter through which future flows are projected;
%             min value is 120, it can be longer (30-yr zero rate gets
%             extrapolated out)

% Output: 
% 
T = size(calcDates,1); 
CF = ones(1,K2); 
erp = zeros(T,1); 
% note; in the logic below r represents the zero coupon rate at each
% maturity -- using the same rate at each maturity
% YOU ARE HERE:
for t = 1:T
   tt = find(dataFrame.date < calcDates(t),1,'last'); 
   cfVec = ones(1,K2);
   k_1 = 1+(1:K1)/4;
   k_2 = 1+(K1+1:K2)/4;
   cfVec(1,1:K1) = dataFrame.CFfilt(tt).*(1+dataFrame.g_1(tt)).^k_1;
   cfVec(1,K1+1:K2) = dataFrame.CFfilt(tt).*(1+dataFrame.g_2(tt)).^k_2;
   r = zeroCurves(t,:);
   erp0 = dataFrame.g_2(tt) - r(end) + 0.01; % discount factor must be > growth factor in steady state

%    r = repmat(dataFrame(t,3),[1,K+1]); 
    currentPrice = px(t); 
%     cf = repmat(dataFrame(t,4),[1,K+1]); 
%     g = [repmat(dataFrame(t,5),[1,K]),dataFrame(t,6)]; % note: K+1-th 
%     CF = cf(1,1:K).*((1 + g(1,1:K)).^(1:K)); 
%     CF(1,K+1) = CF(1,K)*(1+g(end)); 
    fun = @calcPrice; 
    x0 = erpb(t); 
    options = optimset('Display', 'off'); 
    xx = fsolve(fun, x0, options); 
    erp(t) = xx; 
end 

function price = calcPrice(x)
    DF = ((1 + x + r).^-(1:length(r))); 
    price = -1 * currentPrice + sum(CF(1,1:K).*DF(1,1:K)) + DF(1,K)*CF(end)/(r(end)+x-g(end));
end

end
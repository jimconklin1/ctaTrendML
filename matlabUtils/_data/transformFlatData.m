function newData = transformFlatData(assetHeader,dates,levels,transformCode) 
T = length(dates); 
N = length(assetHeader); 
newData = zeros(T,N); 
for n = 1:N
    switch transformCode(1,n)
        case 1 % futures, total return series, XXXUSD ccys:
           newData(:,n) = calcRtn(levels(:,n)); % handles NaNs, Infs in price series 
        case 2 % interest rate swaps
           tempDiff = zeros(size(levels(:,n))); 
           tempDiff(2:end,:) = levels(2:end,n) - levels(1:end-1,n);
           newData(:,n) = 100*tempDiff; % convert changes into bps from diff in percent
        case 3 % aussie bond contracts, XM1, YM1 
           nn = 20; 
           cc = 3; 
           priceXM = levels(:,n); 
           intRate = (100 - priceXM)/200;
           tempXM = (1./(1+intRate)).^nn; 
           valueXM = 1000*((cc*(1-tempXM)./intRate)+100*tempXM); 
           tempRtn = zeros(size(priceXM)); 
           tempRtn(2:end,:) = valueXM(2:end,:)./valueXM(1:end-1,:)-1;
           newData(:,n) = tempRtn; 
        case 4 % Eurodollars 
           tempDiff = zeros(size(levels(:,n))); 
           tempDiff(2:end,:) = (100-levels(2:end,n)) - (100-levels(1:end-1,n)); 
           newData(2:end,n) = 100*tempDiff(2:end,:); % convert changes into bps from diff in percent
        case 5 % USDXXX convention FX pairs 
           tempRtn = -calcRtn(levels(:,n)); % handles NaNs, Infs in price series 
           newData(:,n) = tempRtn;
    end % switch 
end % for 
%newData = [dates,newData]; 
end % fn 
 
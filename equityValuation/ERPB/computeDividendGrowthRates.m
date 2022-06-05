function growthRateTable = computeDividendGrowthRates(fundData,freq)

genCoeffs = false;
researchMode = false;

earnings = fundData.Earnings;
totalPayout = fundData.Dividends + fundData.Buybacks - fundData.Stock_Issuance;
totalPayoutRatio = totalPayout./earnings;
netPayout = fundData.Dividends;
netPayoutRatio = netPayout./earnings;

if strcmpi(freq,'quarterly')
   totalPayoutRatio = replaceOutliers(totalPayoutRatio,20,'rolling',4);
   totalPayoutRatio = min([totalPayoutRatio,ones(size(totalPayoutRatio))],[],2); 
   totalPayoutRatio = max([totalPayoutRatio,zeros(size(totalPayoutRatio))],[],2); 
   avgTotalPayoutRatio = movmean(totalPayoutRatio, [11 0]);
   netPayoutRatio = replaceOutliers(netPayoutRatio,20,'rolling',8);  
   netPayoutRatio = min([netPayoutRatio,ones(size(totalPayoutRatio))],[],2); 
   netPayoutRatio = max([netPayoutRatio,zeros(size(totalPayoutRatio))],[],2); %#ok<NASGU>
   growthRateLT = fundData.CBO_GDPgrwth/4;
   avgROE32 = movmean(fundData.ROE, [31 0]); % ROE already in quarterly units
   earningsGrowth = zeros(length(earnings), 1);
   for i = 32 : length(earnings)
      earningsGrowth(i) = (earnings(i) / earnings(i - 31));
   end
   earningsGrowth = max([earningsGrowth,repmat(0.1,size(earningsGrowth))],[],2);
   earningsGrowth(32:end,:) = earningsGrowth(32:end,:).^(1/31) - 1;
   earningsGrowth(1:31,:) = earningsGrowth(32);
   avgEarningsGrowth = movmean(earningsGrowth, [7 0]);
   netPayoutGrowth = zeros(length(netPayout), 1);
   payoutGrowthRawMean = (netPayout(end)/netPayout(1))^(1/(length(netPayout)-1))-1;
   for i = 32 : length(netPayout)
      netPayoutGrowth(i) = (netPayout(i) / netPayout(i - 31));
   end
   netPayoutGrowth = max([netPayoutGrowth,repmat(0.5,size(netPayoutGrowth))],[],2);
   netPayoutGrowth(32:end,:) = netPayoutGrowth(32:end,:).^(1/31) - 1;
   netPayoutGrowth(1:31,:) = netPayoutGrowth(32);
   netPayoutGrowth = max([netPayoutGrowth,zeros(size(netPayoutGrowth))],[],2);   
   netPayoutGrowth = (payoutGrowthRawMean/mean(netPayoutGrowth))*netPayoutGrowth;
   avgNetPayoutGrowth = movmean(netPayoutGrowth, [7 0]);
   estimateGrowth = (fundData.epsEst_FQ8 ./ fundData.epsEst_FQ1) .^ (1 / 7) - 1; % quarterly growth units
   estimateGrowth7 = (fundData.epsEst_FQ7 ./ fundData.epsEst_FQ1) .^ (1 / 6) - 1; 
   estimateGrowth(isnan(estimateGrowth)) = estimateGrowth7(isnan(estimateGrowth)); 
   smEstimateGrowth = movmean(estimateGrowth, [3 0]);
else
   totalPayoutRatio = replaceOutliers(totalPayoutRatio,5,'rolling',4); 
   totalPayoutRatio = min([totalPayoutRatio,ones(size(totalPayoutRatio))],[],2); 
   totalPayoutRatio = max([totalPayoutRatio,zeros(size(totalPayoutRatio))],[],2);
   avgTotalPayoutRatio = movmean(totalPayoutRatio, [4 0]);
   netPayoutRatio = replaceOutliers(netPayoutRatio,5,'rolling',8); 
   netPayoutRatio = min([netPayoutRatio,ones(size(totalPayoutRatio))],[],2); 
   netPayoutRatio = max([netPayoutRatio,zeros(size(totalPayoutRatio))],[],2); %#ok<NASGU>
   growthRateLT = fundData.CBO_GDPgrwth;
   avgROE10 = movmean(fundData.ROE, [9 0]);
   earningsGrowth = zeros(length(earnings), 1);
   for i = 10 : length(earnings)
      earningsGrowth(i) = (earnings(i) / earnings(i - 9));
   end
   earningsGrowth = max([earningsGrowth,repmat(0.1,size(earningsGrowth))],[],2);
   earningsGrowth(10:end,:) = earningsGrowth(10:end,:).^(1/9) - 1; 
   earningsGrowth(1:9,:) = earningsGrowth(10);
   avgEarningsGrowth = movmean(earningsGrowth, [1 0]);
   netPayoutGrowth = zeros(length(netPayout), 1);
   payoutGrowthRawMean = (netPayout(end)/netPayout(1))^(1/(length(netPayout)-1))-1;
   for i = 10 : length(netPayout)
      netPayoutGrowth(i) = (netPayout(i) / netPayout(i - 9));
   end
   netPayoutGrowth = max([netPayoutGrowth,repmat(0.5,size(netPayoutGrowth))],[],2);
   netPayoutGrowth(10:end,:) = netPayoutGrowth(10:end,:).^(1/9) - 1;
   netPayoutGrowth(1:9,:) = netPayoutGrowth(10);
   netPayoutGrowth = max([netPayoutGrowth,zeros(size(netPayoutGrowth))],[],2);   
   netPayoutGrowth = (payoutGrowthRawMean/mean(netPayoutGrowth))*netPayoutGrowth;
   avgNetPayoutGrowth = movmean(netPayoutGrowth, [1 0]);
   estimateGrowth = (fundData.epsEst_FQ8 ./ fundData.epsEst_FQ1) .^ (4 / 7) - 1; % annual growth units
   estimateGrowth7 = (fundData.epsEst_FQ7 ./ fundData.epsEst_FQ1) .^ (4 / 6) - 1;
   estimateGrowth(isnan(estimateGrowth)) = estimateGrowth7(isnan(estimateGrowth));
   smEstimateGrowth = movmean(estimateGrowth, [1 0]);
end 

if researchMode
   y = fundData.Buybacks - fundData.Stock_Issuance; %#ok<UNRCH>
   y = [y, [0; y(2:end,:)./y(1:end-1)-1], [0;0; (y(3:end,:)./y(1:end-2)).^(1/2)-1], ...
       [0;0;0; (y(4:end,:)./y(1:end-3)).^(1/3)-1], [0;0;0;0; (y(5:end,:)./y(1:end-4)).^(1/4)-1], ...
       [0;0;0;0;0; (y(6:end,:)./y(1:end-5)).^(1/5)-1], [0;0;0;0;0;0; (y(7:end,:)./y(1:end-6)).^(1/6)-1]]; 
   y(y==0)=NaN;
   y0mean = y - nanmean(y); 
   CFgrowth = [0;fundData.FCF(2:end,:)./fundData.FCF(1:end-1,:)-1]; 
   CapexGrowth = [0;fundData.Capex(2:end,:)./fundData.Capex(1:end-1,:)-1]; 
   X = [growthRateLT, earningsGrowth, estimateGrowth, CFgrowth, CapexGrowth];
   X(X==0)=NaN;
   X0mean = X - nanmean(X); 
   coeffs = regstats(y0mean(3:end,2),X0mean(2:end-1,[2,5]),'linear',{'yhat','rsquare','tstat','fstat','dwstat'}); 
   coeffs1 = regstats(y(3:end,2),X(2:end-1,[2,4:5]),'linear',{'yhat','rsquare','tstat','fstat','dwstat'}); 
end 

if genCoeffs
   % estimate a new set of growth forecasts and catenate to dataset
end 

if strcmpi(freq,'quarterly')
   xx = [avgROE32.*(1 - avgTotalPayoutRatio), avgNetPayoutGrowth, avgEarningsGrowth, growthRateLT];
   compositeGrowth = xx*[0.3,0.2,0.2,0.3]'; 
   growthData = [fundData.Date, fundData.ROE, fundData.ROE.*(1 - totalPayoutRatio), avgROE32.*(1 - totalPayoutRatio), avgEarningsGrowth, smEstimateGrowth, compositeGrowth, growthRateLT];
else
   xx = [avgROE10.*(1 - avgTotalPayoutRatio), avgNetPayoutGrowth, avgEarningsGrowth, growthRateLT]; 
   compositeGrowth = xx*[0.3,0.2,0.2,0.3]'; 
   growthData = [fundData.Date, fundData.ROE, fundData.ROE.*(1 - totalPayoutRatio), avgROE10.*(1 - totalPayoutRatio), avgEarningsGrowth, smEstimateGrowth, compositeGrowth, growthRateLT];
end 

growthRateTable = array2table(growthData, 'VariableNames', {'Date', 'ROE', 'FC', 'FA', 'H', 'BU','CompGrowth','CBO_GDPgrwth'});
end
 
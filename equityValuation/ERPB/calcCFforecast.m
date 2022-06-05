function [forecastCF, filteredBBs, filteredDivs, growthRateBBs, growthRateDivs, fundData] = calcCFforecast(fundData, p)

payoutOptionBBs = p.payoutOptionBBs; 
payoutOptionDivs = p.payoutOptionDivs; 
growthOptionBBs = p.growthOptionBBs;
growthOptionDivs = p.growthOptionDivs;
freq =  p.payoutDataFrequency;
runMode = p.runMode;  %#ok<NASGU>
K = p.K;

if strcmpi(p.dataOption,'bbgHardCopy') && strcmpi(freq,'quarterly')
%  xx1 = fundData.('netPayout'); 
  xx1 = fundData.('payoutYld')/4; 
  xx2 = repmat((1+0.04/4).^(0:21),[size(xx1,1),1]);
  xx3 = fundData.('Market_Value'); 
%  forecast = [fundData.('Date'), repmat(xx1,[1,size(xx2,2)]).*xx2, repmat(0.04/4,[size(xx1,1),1])]; 
  forecast = [fundData.('Date'), repmat(xx1.*xx3,[1,size(xx2,2)]).*xx2, repmat(0.04/4,[size(xx1,1),1])]; 
  forecastCF = array2table(forecast, 'VariableNames', {'Year', 'Q0','Q1','Q2','Q3','Q4','Q5','Q6','Q7','Q8','Q9','Q10',...
                                                       'Q11','Q12','Q13','Q14','Q15','Q16','Q17','Q18','Q19','Q20','Q21','G'}); 
  filteredBBs = [fundData.('Date'), fundData.('Market_Value').*fundData.('netBBackYld')/4]; 
  filteredDivs = [fundData.('Date'), fundData.('Market_Value').*fundData.('divYld')/4]; 
  growthRateBBs = repmat(0.04/4,[size(xx1,1),size(xx2,2)]);
  growthRateDivs = growthRateBBs;
elseif strcmpi(freq,'quarterly')
   %[filteredCF, fundData] = computeFilteredPayouts(fundData,freq);
   [filteredBBs, fundData] = computeFilteredBuybacks(fundData,freq);
   [filteredDivs, fundData] = computeFilteredDividends(fundData,freq);
   growthRateBBs = computeBuybackGrowthRates(fundData,freq);
   growthRateDivs = computeDividendGrowthRates(fundData,freq);
  growthRateSTbb = (growthRateBBs.(growthOptionBBs) + 1) .^ (1 : K);
  growthRateSTdiv = (growthRateDivs.(growthOptionDivs) + 1) .^ (1 : K);
  growthRateLTbb = growthRateBBs.CBO_GDPgrwth;
  growthRateLTdiv = growthRateDivs.CBO_GDPgrwth; 
  forecastB = [filteredBBs.Date, filteredBBs.(payoutOptionBBs), filteredBBs.(payoutOptionBBs).* growthRateSTbb, filteredBBs.(payoutOptionBBs) .* growthRateSTbb(:, end) .* (1 + growthRateLTbb), growthRateLTbb];
  forecastD = [filteredDivs.Date, filteredDivs.(payoutOptionDivs), filteredDivs.(payoutOptionDivs).* growthRateSTdiv, filteredDivs.(payoutOptionDivs) .* growthRateSTdiv(:, end) .* (1 + growthRateLTdiv),growthRateLTdiv];
  forecast = [forecastD(:,1), (forecastB(:,2:end-1)+forecastD(:,2:end-1)),0.5*(forecastB(:,end)+forecastD(:,end))]; 
  forecastCF = array2table(forecast, 'VariableNames', {'Year', 'Q0','Q1','Q2','Q3','Q4','Q5','Q6','Q7','Q8','Q9','Q10',...
                                                       'Q11','Q12','Q13','Q14','Q15','Q16','Q17','Q18','Q19','Q20','Q21','G'});
else
   %[filteredCF, fundData] = computeFilteredPayouts(fundData,freq);
   [filteredBBs, fundData] = computeFilteredBuybacks(fundData,freq);
   [filteredDivs, fundData] = computeFilteredDividends(fundData,freq);
   growthRateBBs = computeBuybackGrowthRates(fundData,freq);
   growthRateDivs = computeDividendGrowthRates(fundData,freq);
  growthRateSTbb = (growthRateBBs.(growthOptionBBs) + 1) .^ (1 : K);
  growthRateSTdiv = (growthRateDivs.(growthOptionDivs) + 1) .^ (1 : K);
  growthRateLTbb = growthRateBBs.CBO_GDPgrwth;
  growthRateLTdiv = growthRateDivs.CBO_GDPgrwth; 
  forecastB = [filteredBBs.Date, filteredBBs.(payoutOptionBBs), filteredBBs.(payoutOptionBBs).* growthRateSTbb, filteredBBs.(payoutOptionBBs) .* growthRateSTbb(:, end) .* (1 + growthRateLTbb), growthRateLTbb];
  forecastD = [filteredDivs.Date, filteredDivs.(payoutOptionDivs), filteredDivs.(payoutOptionDivs).* growthRateSTdiv, filteredDivs.(payoutOptionDivs) .* growthRateSTdiv(:, end) .* (1 + growthRateLTdiv), growthRateLTdiv];
  forecast = [forecastD(:,1), (forecastB(:,2:end-1)+forecastD(:,2:end-1)),0.5*(forecastB(:,end)+forecastD(:,end))]; 
  forecastCF = array2table(forecast, 'VariableNames', {'Year', 'Y0', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'G'});
end

end

% if strcmp(runMode,'research')
% %                           Div nCF netBuybacks
% cashFlows = fundData(:,[1,2,4,  8,  35]);  
% dates = cashFlows.Date; 
% T = size(dates,1);  
% y = cashFlows.Net_Cash_to_Equity; 
% X0 = forecastCF.Y0; 
% X0((X0==0))= NaN; 
% figure(1); plot(dates,[y, X0]); datetick('x','yyyy'); grid; 
% 
% y = cashFlows.Net_Buybacks; 
% X0 = forecastB(:,2); 
% X0((X0==0))= NaN; 
% figure(2); plot(dates,[y, X0]); datetick('x','yyyy'); grid; 
% 
% y = cashFlows.Dividends; 
% X0 = forecastD(:,2); 
% X0((X0==0))= NaN; 
% figure(3); plot(dates,[y, X0]); datetick('x','yyyy'); grid; 

%     dates = fundData.Date; %#ok<UNRCH>
%     
%     Z0 = [fundData.FCF, -fundData.Capex];
%     y0 = fundData.Net_Buybacks;
%     X0 = [filteredBBs.NA5,filteredBBs.NA10,filteredBBs.NP5,filteredBBs.NP10,filteredBBs.NNORM,(.67*filteredBBs.NA5+.33*filteredBBs.NNORM)];
%     X0((X0==0))= NaN;
%     figure(1); plot(dates,[y0,X0(:,[1,6]),Z0(:,1)]); datetick('x','yyyy'); grid;
%     X1 = X0(1:26,:).*(1.09^5);
%     y1 = repmat(y0(6:31,:),[1,6]); 
%     mse = mean(((X1-y1)./y1).^2);
%     
%     y2 = fundData.Dividends;
%     X2 = [filteredDivs.NA5,filteredDivs.NA10,filteredDivs.NP5,filteredDivs.NP10,filteredDivs.NNORM,(.4*filteredDivs.NP5+.6*filteredDivs.NNORM)];
%     X2((X2==0))= NaN;
%     figure(2); plot(dates,[y2,X2(:,[3,5,6])]); datetick('x','yyyy'); grid;
%     X3 = X2(1:26,:).*(1.09^5);    
%     y3 = repmat(y2(6:31,:),[1,6]); 
%     mse = mean(((X3-y3)./y3).^2);
% end


function [filteredBBs, fundData] = computeFilteredBuybacks(fundData,freq)
% this function takes a smoothed filter of buy-backs 

T = length(fundData.('Date')); 
inflationAdj = cumprod(1 + flip(fundData.('Inflation_Rate')));
fundData.('Inflation_Adjusted_Earnings') = fundData.Earnings .* flip([1; inflationAdj(1:end-1)]);
fundData.('Buyback_Ratio') = (fundData.Buybacks) ./ fundData.Earnings;
fundData.('Net_Buybacks') = (fundData.Buybacks - fundData.('Stock_Issuance'));
temp1 = movmean(fundData.('Net_Buybacks'), [3 0],'omitnan'); 
temp1 = max(temp1,zeros(T,1)); 
temp2 = movmean(fundData.Earnings, [3 0],'omitnan'); 
fundData.('Net_Buyback_Ratio') = temp1./temp2;
fundData.('Net_Buyback_Yield') = fundData.Net_Buybacks./fundData.Market_Value;
tempY = max(fundData.('Net_Buyback_Yield'),zeros(T,1));

filteredBBs = array2table(fundData.Date,'VariableNames', {'Date'});

if strcmpi(freq,'quarterly')
   avgPayout8 = movmean(tempY, [7 0],'omitnan');
   fundData.('Net_Buyback_Yield_8Q_MA') = avgPayout8;
   avgPayout16 = movmean(tempY, [15 0],'omitnan');
   fundData.('Net_Buyback_Yield_16Q_MA') = avgPayout16;
   avgPayout32 = movmean(tempY, [31 0],'omitnan');
   fundData.('Net_Buyback_Yield_32Q_MA') = avgPayout32;
   
   avgAdjPayout32 = movmean(fundData.('Inflation_Adjusted_Earnings'), [31 0],'omitnan');
   avgAdjPayout32 = avgAdjPayout32 .* fundData.CPI / fundData.CPI(end);
   fundData.('Adjusted_Earnings_32Q_MA') = avgAdjPayout32;
   avgPayoutRatio32 = movmean(fundData.('Net_Buyback_Ratio'), [31 0],'omitnan');
   fundData.('Net_Buyback_Ratio_32Q_MA') = avgPayoutRatio32;

   avgPayoutRatio12 = movmean(fundData.('Net_Buyback_Ratio'), [11 0],'omitnan');
   fundData.('Net_Buyback_Ratio_12Q_MA') = avgPayoutRatio12;
   avgPayoutRatio24 = movmean(fundData.('Net_Buyback_Ratio'), [23 0],'omitnan');
   fundData.('Net_Buyback_Ratio_24Q_MA') = avgPayoutRatio24;
   
   filteredBBs.('CURRVAL') = fundData.('Buybacks') - fundData.('Stock_Issuance');
   filteredBBs.('NA8') = fundData.('Market_Value') .* fundData.('Net_Buyback_Yield_8Q_MA');
   filteredBBs.('NA16') = fundData.('Market_Value') .* fundData.('Net_Buyback_Yield_16Q_MA');
   filteredBBs.('NA32') = fundData.('Market_Value') .* fundData.('Net_Buyback_Yield_32Q_MA');
   filteredBBs.('NP12') = fundData.('Earnings') .* fundData.('Net_Buyback_Ratio_12Q_MA');
   filteredBBs.('NP24') = fundData.('Earnings') .* fundData.('Net_Buyback_Ratio_24Q_MA');
   filteredBBs.('NNORM') = fundData.('Net_Buyback_Ratio_32Q_MA') .* fundData.('Adjusted_Earnings_32Q_MA');
   filteredBBs.('OPT_AVG') = (0.67*filteredBBs.NA32 + 0.33*filteredBBs.NNORM);
else
   avgPayout5 = movmean(tempY, [4 0],'omitnan');
   fundData.('Net_Buyback_Yield_5Y_MA') = avgPayout5;
   avgPayout10 = movmean(tempY, [9 0],'omitnan');
   fundData.('Net_Buyback_Yield_10Y_MA') = avgPayout10;
   
   avgAdjPayout10 = movmean(fundData.('Inflation_Adjusted_Earnings'), [9 0],'omitnan');
   avgAdjPayout10 = avgAdjPayout10 .* fundData.CPI / fundData.CPI(end);
   fundData.('Adjusted_Earnings_10Y_MA') = avgAdjPayout10;
   
   avgPayoutRatio5 = movmean(fundData.('Net_Buyback_Ratio'), [4 0],'omitnan');
   %avgPayoutRatio5(1 : 4) = 0;
   fundData.('Net_Buyback_Ratio_5Y_MA') = avgPayoutRatio5;
   avgPayoutRatio10 = movmean(fundData.('Net_Buyback_Ratio'), [9 0],'omitnan');
   %avgPayoutRatio10(1 : 9) = 0;
   fundData.('Net_Buyback_Ratio_10Y_MA') = avgPayoutRatio10;
   
   filteredBBs.('CURRVAL') = fundData.('Buybacks') - fundData.('Stock_Issuance');
   filteredBBs.('NA10') = fundData.('Market_Value') .* fundData.('Net_Buyback_Yield_10Y_MA');
   filteredBBs.('NA5') = fundData.('Market_Value') .* fundData.('Net_Buyback_Yield_5Y_MA');
   filteredBBs.('NP10') = fundData.('Earnings') .* fundData.('Net_Buyback_Ratio_10Y_MA');
   filteredBBs.('NP5') = fundData.('Earnings') .* fundData.('Net_Buyback_Ratio_5Y_MA');
   filteredBBs.('NNORM') = fundData.('Net_Buyback_Ratio_10Y_MA') .* fundData.('Adjusted_Earnings_10Y_MA');
   filteredBBs.('OPT_AVG') = (0.67*filteredBBs.NA5 + 0.33*filteredBBs.NNORM);
end

end 

% %                           Div nCF netBuybacks
% cashFlows = fundData(:,[1,2,4,  8,  35]);  
% dates = cashFlows.Date; 
% T = size(dates,1);  
% y = cashFlows.Net_Buybacks; 
% X0 = [filteredBBs.NA8, filteredBBs.NA16,filteredBBs.NA32]; %[filteredBBs.NP5,filteredBBs.NP10] [filteredBBs.NA5, filteredBBs.NA10] filteredBBs.NNORM
% X0((X0==0))= NaN; 
% figure(2); plot(dates,[y, X0]); datetick('x','yyyy'); grid; 
% 
% X0 = [fundData.Net_Buyback_Yield, avgPayout8, avgPayout16, avgPayout32]; 
% X0((X0==0))= NaN; 
% figure(4); plot(dates,X0); datetick('x','yyyy'); grid; 
% 
% X0 = fundData.Net_Buyback_Ratio;
% figure(5); plot(dates,X0); datetick('x','yyyy'); grid; 
% 
% X0 = [filteredBBs.OPT_AVG]; % [filteredBBs.NA16, filteredBBs.NP24, filteredBBs.NNORM];
% X0((X0==0))= NaN; 
% figure(5); plot(dates,[y,X0]); datetick('x','yyyy'); grid; 

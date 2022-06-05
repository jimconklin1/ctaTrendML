function [filteredCF, fundData] = computeFilteredPayouts(fundData,freq)
% this function takes a smoothed filter of the sum of buybacks+dividends

inflationAdj = cumprod(1 + flip(fundData.('Inflation_Rate')));
fundData.('Inflation_Adjusted_Earnings') = fundData.Earnings .* flip([1; inflationAdj(1:end-1)]);
fundData.('Payout_Ratio') = (fundData.Dividends + fundData.Buybacks) ./ fundData.Earnings;
fundData.('Net_Payout_Ratio') = (fundData.Dividends + fundData.Buybacks - fundData.('Stock_Issuance')) ./ fundData.Earnings;

avgPayout10 = movmean(fundData.('Net_Cash_Yield'), [9 0]);
avgPayout10(1 : 9) = 0;
fundData.('Payout_Yield_10Y_MA') = avgPayout10;
avgPayout5 = movmean(fundData.('Net_Cash_Yield'), [4 0]);
avgPayout5(1 : 4) = 0;
fundData.('Payout_Yield_5Y_MA') = avgPayout5;
avgAdjPayout10 = movmean(fundData.('Inflation_Adjusted_Earnings'), [9 0]);
avgAdjPayout10 = avgAdjPayout10 .* fundData.CPI / fundData.CPI(end);
avgAdjPayout10(1 : 9) = 0;
fundData.('Adjusted_Earnings_10Y_MA') = avgAdjPayout10;
avgPayoutRatio10 = movmean(fundData.('Net_Payout_Ratio'), [9 0]);
avgPayoutRatio10(1 : 9) = 0;
fundData.('Payout_Ratio_10Y_MA') = avgPayoutRatio10;
avgPayoutRatio5 = movmean(fundData.('Net_Payout_Ratio'), [4 0]);
avgPayoutRatio5(1 : 4) = 0;
fundData.('Payout_Ratio_5Y_MA') = avgPayoutRatio5;

filteredCF = array2table(fundData.Date,'VariableNames', {'Date'});
filteredCF.('NA10') = fundData.('Market_Value') .* fundData.('Payout_Yield_10Y_MA');
filteredCF.('NA5') = fundData.('Market_Value') .* fundData.('Payout_Yield_5Y_MA');
filteredCF.('NP10') = fundData.('Earnings') .* fundData.('Payout_Ratio_10Y_MA');
filteredCF.('NP5') = fundData.('Earnings') .* fundData.('Payout_Ratio_5Y_MA');
filteredCF.('NNORM') = fundData.('Payout_Ratio_10Y_MA') .* fundData.('Adjusted_Earnings_10Y_MA');

end 
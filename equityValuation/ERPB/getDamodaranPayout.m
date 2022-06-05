function payout = getDamodaranPayout(ticker, startDate, endDate, freq)

% ticker = 'SPX Index';
% startDate = '1990-01-01';
% endDate = '2020-12-31';
% freq = 'yearly'

if nargin < 4
    freq = 'quarterly';
end

if exist('c')~=1 %#ok<EXIST>
   c = blp;
end 
from = datestr(datenum(startDate), 'mm/dd/yyyy');
to = datestr(datenum(endDate), 'mm/dd/yyyy');
bbgData = history(c, {ticker}, {'PX_LAST', 'DVD_SH_12M', 'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', 'EQY_DVD_YLD_12M', 'EARN_YLD'}, ...
                  from, to, {freq, 'calendar'}, 'USD');
bbgData = array2table(bbgData, 'VariableNames', {'Year', 'Price', 'Dividend', 'Buyback', 'Issuance', 'DividendYield', 'EarningsYield'});

payout = [table2array(bbgData(:, 1:2)), bbgData.Price .* bbgData.EarningsYield / 100, ...
          bbgData.Dividend, -1 * bbgData.Buyback, bbgData.Issuance, bbgData.Dividend - bbgData.Buyback, ...
          bbgData.Dividend - bbgData.Buyback - bbgData.Issuance, bbgData.DividendYield / 100, ...
          -1 * bbgData.Buyback ./ bbgData.Price, (bbgData.Dividend - bbgData.Buyback) ./ bbgData.Price, ...
          (bbgData.Dividend - bbgData.Buyback - bbgData.Issuance) ./ bbgData.Price];
payout = array2table(payout, 'VariableNames', {'Year', 'Market_Value', 'Earnings', 'Dividends', ...
                     'Buybacks', 'Stock_Issuance', 'Cash_to_Equity', 'Net_Cash_to_Equity', ...
                     'Dividend_Yield', 'Buyback_Yield', 'Gross_Cash_Yield', 'Net_Cash_Yield'});
       
inflation = history(c, {'CPI YOY Index'}, {'PX_LAST'}, from, to, {freq, 'calendar'}, 'USD');
payout.('Inflation_Rate') = inflation(:, 2) / 100;
payout.('CPI') = 100 * cumprod(inflation(:, 2) / 100 + 1);
inflationAdj = cumprod(1 + flip(payout.('Inflation_Rate')));
payout.('Inflation_Adjusted_Earnings') = payout.Earnings .* flip([1; inflationAdj(1:end-1)]);
payout.('Payout_Ratio') = (payout.Dividends + payout.Buybacks) ./ payout.Earnings;
payout.('Net_Payout_Ratio') = (payout.Dividends + payout.Buybacks - payout.('Stock_Issuance')) ./ payout.Earnings;

avgPayout10 = movmean(payout.('Net_Cash_Yield'), [9 0]);
avgPayout10(1 : 9) = 0;
payout.('Payout_Yield_10Y_MA') = avgPayout10;
avgPayout5 = movmean(payout.('Net_Cash_Yield'), [4 0]);
avgPayout5(1 : 4) = 0;
payout.('Payout_Yield_5Y_MA') = avgPayout5;
avgAdjPayout10 = movmean(payout.('Inflation_Adjusted_Earnings'), [9 0]);
avgAdjPayout10 = avgAdjPayout10 .* payout.CPI / payout.CPI(end);
avgAdjPayout10(1 : 9) = 0;
payout.('Adjusted_Earnings_10Y_MA') = avgAdjPayout10;
avgPayoutRatio10 = movmean(payout.('Net_Payout_Ratio'), [9 0]);
avgPayoutRatio10(1 : 9) = 0;
payout.('Payout_Ratio_10Y_MA') = avgPayoutRatio10;
avgPayoutRatio5 = movmean(payout.('Net_Payout_Ratio'), [4 0]);
avgPayoutRatio5(1 : 4) = 0;
payout.('Payout_Ratio_5Y_MA') = avgPayoutRatio5;

payout.NA10 = payout.('Market_Value') .* payout.('Payout_Yield_10Y_MA');
payout.NA5 = payout.('Market_Value') .* payout.('Payout_Yield_5Y_MA');
payout.NP10 = payout.('Earnings') .* payout.('Payout_Ratio_10Y_MA');
payout.NP5 = payout.('Earnings') .* payout.('Payout_Ratio_5Y_MA');
payout.NNORM = payout.('Payout_Ratio_10Y_MA') .* payout.('Adjusted_Earnings_10Y_MA');

end
function [fundData,startDate,endDate] = getPayoutData(ticker, startDate, endDate, freq, dataOption)
% ticker = 'SPX Index';
% startDate = '1990-01-01';
% endDate = '2020-12-31';
% freq = 'yearly'

if nargin < 4
    freq = 'quarterly';
end
if nargin < 5
    dataOption = 'bbg';
end

if strcmp(dataOption,'hardCopy') 
   dataPath = 'M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\Data Source';
   if strcmp(freq,'quarterly') 
      switch ticker
         case 'SPX Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_SPX_quarterly.csv'));
         case 'S5UTIL Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5UTIL_quarterly.csv'));
         case 'S5INFT Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5INFT_quarterly.csv'));
         case 'S5RLST Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5INFT_quarterly.csv'));
         case 'S5MATR Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5MATR_quarterly.csv'));
         case 'S5INDU Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5INDU_quarterly.csv'));
         case 'S5HLTH Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5HLTH_quarterly.csv'));
         case 'S5FINL Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5FINL_quarterly.csv'));
         case 'S5ENRS Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5ENRS_quarterly.csv'));
         case 'S5CONS Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5CONS_quarterly.csv'));
         case 'S5COND Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5COND_quarterly.csv'));
         case 'S5TELS Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_S5TELS_quarterly.csv'));
      end 
   else % annual
      switch ticker
         case 'SPX Index'
            fundData = readtable(fullfile(dataPath, 'fundInputDataERPB_SPX_annual.csv'));
      end 
   end 
   startDate = fundData.Date(1);
   endDate = fundData.Date(end);
elseif strcmp(dataOption,'bbgHardCopy') % ONLY WORKS FOR SPX, quarterly
   fundData = readtable('M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\Data Source\bbgSmoothedInputDataERPB_SPX_quarterly.csv');    
   startDate = fundData.Date(1);
   endDate = fundData.Date(end);
else % dataOption == 'bbg'
    if exist('c')~=1 %#ok<EXIST>
        c = blp;
    end
    from = datestr(datenum(startDate), 'mm/dd/yyyy');
    to = datestr(datenum(endDate), 'mm/dd/yyyy');
    bbgData = history(c, {ticker}, {'PX_LAST', 'DVD_SH_12M', 'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', 'EQY_DVD_YLD_12M', 'EARN_YLD'}, ...
        from, to, {freq, 'calendar'}, 'USD');
    bbgData = array2table(bbgData, 'VariableNames', {'Date', 'Price', 'Dividend', 'Buyback', 'Issuance', 'DividendYield', 'EarningsYield'});
    
    fundData = [table2array(bbgData(:, 1:2)), bbgData.Price .* bbgData.EarningsYield / 100, ...
        bbgData.Dividend, -1 * bbgData.Buyback, bbgData.Issuance, bbgData.Dividend - bbgData.Buyback, ...
        bbgData.Dividend - bbgData.Buyback - bbgData.Issuance, bbgData.DividendYield / 100, ...
        -1 * bbgData.Buyback ./ bbgData.Price, (bbgData.Dividend - bbgData.Buyback) ./ bbgData.Price, ...
        (bbgData.Dividend - bbgData.Buyback - bbgData.Issuance) ./ bbgData.Price];
    fundData = array2table(fundData, 'VariableNames', {'Date', 'Market_Value', 'Earnings', 'Dividends', ...
        'Buybacks', 'Stock_Issuance', 'Cash_to_Equity', 'Net_Cash_to_Equity', ...
        'Dividend_Yield', 'Buyback_Yield', 'Gross_Cash_Yield', 'Net_Cash_Yield'});
    
    inflation = history(c, {'CPI YOY Index'}, {'PX_LAST'}, from, to, {freq, 'calendar'}, 'USD');
    fundData.('Inflation_Rate') = inflation(:, 2) / 100;
    fundData.('CPI') = 100 * cumprod(inflation(:, 2) / 100 + 1);
    
    bbgData = history(c, {ticker}, {'RETURN_COM_EQY'},from, to, {'yearly', 'calendar'}, 'USD');
    growthRateLT = history(c, {'CBOPGDNY Index'}, {'PX_LAST'}, from, to, {'yearly', 'calendar'}, 'USD');
    epsEstimates = getBbgEstimate(from, to, ticker, 'BEST_EPS', 'yearly');
    fundData.('ROE') = bbgData(:, 2) / 100;
    fundData.('epsEst_FQ1') = epsEstimates.FQ1;
    fundData.('epsEst_FQ2') = epsEstimates.FQ2;
    fundData.('epsEst_FQ3') = epsEstimates.FQ3;
    fundData.('epsEst_FQ4') = epsEstimates.FQ4;
    fundData.('epsEst_FQ5') = epsEstimates.FQ5;
    fundData.('epsEst_FQ6') = epsEstimates.FQ6;
    fundData.('epsEst_FQ7') = epsEstimates.FQ7;
    fundData.('epsEst_FQ8') = epsEstimates.FQ8;
    fundData.('CBO_GDPgrwth') = growthRateLT(:,2)/100; 
end

end

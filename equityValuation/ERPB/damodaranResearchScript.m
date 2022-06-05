% data import come from spreadsheet 
% "M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\SPX\workWithERM\SPX_ERPcalculationInputs_damodaranComparison_feb2021_v2.xlsx"
% tab 'dataExport'.  The data from that tab get stored manually as a simple array in damodaranOOSoutput.mat in the same subdirectory.

%load 'M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\SPX\workWithERM\damodaranOOSoutput.mat';
%load 'M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\SPX\workWithERM\NA5_FA.mat';
% K = 5;
% erpb = calcDamodaranKperiodERPB(dataFrame,K); 

addpath C:\GIT\utils_ml\_data; 
addpath C:\GIT\utils_ml\_date; 
clear vars;

p.startDate = datenum('12/31/1989'); 
p.endDate = datenum('9/30/2021'); 
p.eqTicker = 'SPX Index'; 
p.ratesTicker = 'USGG30YR Index'; % 'USGG10YR Index'; 'USGG30YR Index'; 
p.payoutOptionBBs = 'OPT_AVG'; %  'BBG_SM_CURRVAL','CURRVAL','NA8', 'NA16','NA32','NP12','NP24',       'NNORM', 'OPT_AVG'
p.payoutOptionDivs = 'OPT_AVG'; % 'BBG_SM_CURRVAL','CURRVAL','NA12','NA24','NA36','NP12','NP24','NP36','NNORM', 'OPT_AVG'
p.growthOptionBBs = 'CBO_GDPgrwth'; % 'CONST4PERC', 'CBO_GDPgrwth', 'CompGrowth'
p.growthOptionDivs = 'CBO_GDPgrwth';  % 'CONST4PERC', 'CBO_GDPgrwth', 'CompGrowth'
p.payoutDataFrequency = 'quarterly'; % 'quarterly', 'annual'
p.dataOption = 'hardCopy'; % 'bbg', 'hardCopy', 'bbgHardCopy' (only w/ 'BBG_SM_CURRVAL' payoutOption), 
p.rateOption = 'flatCurve';
p.runMode = 'research'; % 'research', 'prod'
if strcmpi(p.payoutDataFrequency,'annual')
   p.K = 5;
else
   p.K = 20;
end 

% fcstTable = getDamodaranForecast(p.ticker, p.startDate, p.endDate, p.payoutDataFrequency, p.payoutOption, p.growthOption);

[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); 

[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p);
% [forecastCF, ~, ~, fundData] = calcCFforecast(fundData, p.payoutOption, p.growthOption); p.payoutOption = 'NP10';
% [forecastCF, ~, ~, fundData] = calcCFforecast(fundData, p.payoutOption, p.growthOption); p.payoutOption = 'NNORM';
% forecastCF = [table2array(forecastCF(:, 1)), (table2array(forecastCF(:, 2 : end - 1)) + table2array(forecastCF2(:, 2 : end - 1)) + table2array(forecastCF3(:, 2 : end - 1))) / 3.0, table2array(forecastCF(:, end)) / 100];

if strcmpi(p.runMode,'research') %&& strcmpi(p.payoutDataFrequency,'annual')
   if strcmpi(p.dataOption,'bbgHardCopy')
      netCashFlow = fundData(:,[1,2,6]);
      y = netCashFlow.netPayout;
   else
      netCashFlow = fundData(:,[1,2,8]);
      y = netCashFlow.Net_Cash_to_Equity;
   end
   [mse, errTbl] = calcOOScashFlowfcstError(forecastCF,netCashFlow,p);
   dates = netCashFlow.Date;
   T = size(dates,1);
   X0 = forecastCF.Q0; %forecastCF.Y0;
   X0((X0==0))= NaN;
   figure(4); plot(dates,[y, X0]); datetick('x','yyyy'); grid; title('Filtered Payouts vs. Actual');
    
   k1 = 26;
   temp = table2array(forecastCF(k1+1,3:end-1))';
   k2 = size(temp,1);
   x1 = [NaN(k1+1,1); temp; NaN((T-k1-k2-1),1)];
   figure(5); plot(dates,[y,X0,x1]); datetick('x','yyyy'); grid; title('Filtered Payouts vs. Actual');
end

if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
erpb = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF,p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
%erpb = calcPerturbationERPB(zeroRates, bbgData, divForecast, bbkForecast);

figure(6); plot(erpb.dates(:,1),erpb.value(:,end)); datetick('x','yyyy'); title('ERPB'); grid; 
disp('')

% data import come from spreadsheet 
% "M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\DataSource\
addpath C:\GIT\utils_ml\_data; 
addpath C:\GIT\utils_ml\_date; 
clear vars;

p.startDate = datenum('12/31/1989'); 
p.shortStartDate = datenum('06/30/2015'); 
p.endDate = datenum('05/20/2022'); 
p.payoutOptionBBs = 'OPT_AVG'; %  'BBG_SM_CURRVAL','CURRVAL','NA8', 'NA16','NA32','NP12','NP24',       'NNORM', 'OPT_AVG'
p.payoutOptionDivs = 'OPT_AVG'; % 'BBG_SM_CURRVAL','CURRVAL','NA12','NA24','NA36','NP12','NP24','NP36','NNORM', 'OPT_AVG'
p.growthOptionBBs = 'CBO_GDPgrwth'; % 'CONST4PERC', 'CBO_GDPgrwth', 'CompGrowth'
p.growthOptionDivs = 'CBO_GDPgrwth';  % 'CONST4PERC', 'CBO_GDPgrwth', 'CompGrowth'
p.payoutDataFrequency = 'quarterly'; % 'quarterly', 'annual'
p.K = 20; % 20 if quarterly, 5 if annual
p.dataOption = 'hardCopy'; % 'bbg', 'hardCopy', 'bbgHardCopy' (only w/ 'BBG_SM_CURRVAL' payoutOption), 
p.rateOption = 'flatCurve';
p.runMode = 'prod'; % 
temp = {'12/31/1994','12/31/1995','12/31/1996','12/31/1997','12/31/1998','12/31/1999',...
        '12/31/2000','12/31/2001','12/31/2002','12/31/2003','12/31/2004','12/31/2005',...
        '12/31/2006','12/31/2007','12/31/2008','12/31/2009','12/31/2010','12/31/2011',...
        '12/31/2012','12/31/2013','12/31/2014','12/31/2015','12/31/2016','12/31/2017',...
        '12/31/2018','12/31/2019','12/31/2020','12/31/2021','03/31/2022','05/20/2022'}; 
p.tableDates = datenum(temp'); 
clear temp; 

p.eqTicker = 'SPX Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrDataSPX] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbSPX = erpb;
oTableSPX = presentERPBoutput(erpbSPX,fundData,p); 
% attrDataSPX.date = attrDataSPX.date - 693960;
% writetable(attrDataSPX,['M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\researchOutput\attribDataSPX.csv']);
% writetable(oTableSPX,['M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\researchOutput\erpbResultsSPX.csv']); 

p.eqTicker = 'S5TELS Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbTELS = erpb; 
oTableTELS = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5COND Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbCOND = erpb; 
oTableCOND = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5CONS Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbCONS = erpb;
oTableCONS = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5ENRS Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbENRS = erpb;
oTableENRS = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5FINL Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbFINL = erpb;
oTableFINL = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5HLTH Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbHLTH = erpb;
oTableHLTH = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5INDU Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbINDU = erpb; 
oTableINDU = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5MATR Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbMATR = erpb;
oTableMATR = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5RLST Index'; 
p.ratesTicker = 'USGG30YR Index'; 
p.startDate = datenum('31-Oct-2001');
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); 
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbRLST = erpb;
%oTableRLST = presentERPBoutput(erpb,fundData,p); 
p.startDate = datenum('12/31/1989'); 

p.eqTicker = 'S5INFT Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbINFT = erpb;
oTableINFT = presentERPBoutput(erpb,fundData,p); 

p.eqTicker = 'S5UTIL Index'; 
p.ratesTicker = 'USGG30YR Index'; 
[fundData, startDate, endDate] = getPayoutData(p.eqTicker, p.startDate, p.endDate, p.payoutDataFrequency, p.dataOption); %#ok<ASGLU>
[forecastCF, ~, ~, ~, ~, fundData] = calcCFforecast(fundData, p); 
if strcmp(p.rateOption,'zeroCurve')
   zeroRates = getZeroRates(p.startDate, p.endDate, 'weekly'); % {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'} 
end 
[erpb,attrData] = calcFilteredERPB(p.eqTicker, p.startDate, p.endDate, 'weekly', p.payoutDataFrequency, 'flatCurve', p.ratesTicker, forecastCF, fundData, p.K); % 'zeroRates', zeroRates, forecastCF,p.K)
erpbUTIL = erpb;
oTableUTIL = presentERPBoutput(erpb,fundData,p); 

function oTable = presentERPBoutput(erpb,fundData,p)
% long history:
figure(1);
yyaxis left;
data = [erpb.value(:,3),erpb.value(:,2)/100];
plot(erpb.dates, data, 'LineWidth', 1.5);
datetick('x', 'ddmmmyyyy', 'keepticks');
xlim([erpb.dates(1, 1), erpb.dates(end, 1)]);
% ylim([0, 0.07]);
y = cellstr(num2str(get(gca, 'ytick')' * 100));
pct = char(ones(size(y, 1), 1) * '%'); 
new_yticks = [char(y), pct];
set(gca, 'yticklabel', new_yticks); 

yyaxis right;
plot(erpb.dates, erpb.value(:,1), 'LineWidth', 1.0);
datetick('x', 'ddmmmyyyy', 'keepticks');
xlim([erpb.dates(1, 1), erpb.dates(end, 1)]);

label = split(p.eqTicker, ' '); 
set(gcf, 'Position', [1000, 798, 840, 420]); 
grid on;
legend('ERPB', strcat(label{1},' 30Y US Govt YTM'), strcat(label{1}, ' (RHS)'), 'Location', 'northwest');
title(strcat(p.eqTicker, ' ERPB'));

% short history:
figure(2);
yyaxis left;
dTemp = datenum(p.shortStartDate); 
t0 = find(erpb.dates>=dTemp,1,'first'); 
plot(erpb.dates(t0:end,:), [erpb.value(t0:end,3), erpb.value(t0:end,2)/100], 'LineWidth', 2);
datetick('x', 'ddmmmyyyy', 'keepticks'); 
xlim([erpb.dates(t0, 1), erpb.dates(end, 1)]); 
% ylim([0, 0.07]);
y = cellstr(num2str(get(gca, 'ytick')' * 100));
pct = char(ones(size(y, 1), 1) * '%'); 
new_yticks = [char(y), pct];
set(gca, 'yticklabel', new_yticks); 

yyaxis right;
plot(erpb.dates(t0:end,:), erpb.value(t0:end,1), 'LineWidth', 2);
datetick('x', 'ddmmmyyyy', 'keepticks');
xlim([erpb.dates(t0, 1), erpb.dates(end, 1)]);
% ylim([1600, 3400]);

label = split(p.eqTicker, ' ');
set(gcf, 'Position', [1000, 798, 840, 420]);
grid on;
legend('ERPB', strcat(label{1},' 30Y US Govt YTM'), strcat(label{1}, ' (RHS)'), 'Location', 'northwest');
title(strcat(p.eqTicker,' ERPB'));

% now create output table:
temp = zeros(size(p.tableDates,1),5); 
temp(:,1) = p.tableDates;
for i = 1:length(temp)
   j = find(erpb.dates<=temp(i,1),1,'last');
   temp(i,4:5) = erpb.value(j,2:3); 
   k = find(fundData.Date<=temp(i,1),1,'last'); 
   temp(i,2:3) = 4*[fundData.Net_Cash_Yield(k,1),fundData.Earnings(k,1)/fundData.Market_Value(k,1)];
end 
temp(:,4) = temp(:,4)/100;
oTable = array2table(temp,'Variable',{'Date','Net_Payout_Yield','Earnings_Yield','Interest_Rate','ERPB'}); 
oTable.Date = datestr(oTable.Date);
end % fn

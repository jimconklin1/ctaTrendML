
config.methodology = 'version1'; % 'version1'
config.shortStartDate = '06/30/2018';
config.calcEndDate = datestr(today-1, 'mm/dd/yyyy'); %config.calcEndDate = datestr(today - weekday(today) - 2, 'mm/dd/yyyy');
config.caclFreq = 'weekly'; % daily weekly monthly

config.indexId = 'SPX Index'; % 
if strcmp(config.methodology,'version1')
   config.erpbMethod = 'analytical'; 
%   config.calcStartDate = '01/04/1997';
   config.calcStartDate = '12/31/1989';
   config.lastEPSpriorQuarter = datenum('30-sep-2020'); %datenum('31-dec-2020'); 
   config.lastEPSfactor = 0.6; %0.7;
   config.nomGrwth = 0.04;
   config.nonDivPO2earn = 0.47; % changed back in Feb 2021
   %config.nonDivPO2earn = 0.34; % NOTE: EPS data suddenly jumped up and changed all historical 
   %                              value for ERPB upwards (in Jan 2021)!  Had to change this parameter 
   %                              to bring POyld in line with prior value on 11/9/2020
   [erp, fcst] = calcAnalyticalERPB_jc(config);
elseif strcmp(config.methodology,'version2')
   load 'M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\Version2\ERP_histInputs_SPX.mat dataStruct rateStruct px'; 
   config.calcStartDate = datestr(dataStruct.dates(1),'mm/dd/yyyy');
   zeroCurves = rateStruct;
   zeroCurves.values = zeroCurves.values/100; % take from percentage units to decimal units
   % YOU ARE HERE: interpolate quarterly points between the annual points
   % on the interest rate curve 
   K1 = 4*5; % 5 years out
   K2 = size(zeroCurves.values,2);
   erp = calcNumericalERP(calcDates,px,dataStruct,zeroCurves,K1,K2);
end 
erpbSPX = erp;

config.indexId = 'CCMP Index';
config.calcStartDate = '01/01/2018';
config.calcEndDate = datestr(today-1, 'mm/dd/yyyy');
%config.calcEndDate = datestr(today - weekday(today) - 2, 'mm/dd/yyyy');
config.caclFreq = 'weekly';    
config.erpbMethod = 'analytical';
config.lastEPSpriorQuarter = datenum('31-mar-2020'); 
config.lastEPSfactor = 0.5;
config.nomGrwth = 0.055;
config.nonDivPO2earn = 0.35;
[erpbCCMP,~] = calcAnalyticalERPB_jc(config);


config.indexId = 'RTY Index';
config.calcStartDate = '01/01/2018';
config.calcEndDate = datestr(today-1, 'mm/dd/yyyy');
%config.calcEndDate = datestr(today - weekday(today) - 2, 'mm/dd/yyyy');
config.caclFreq = 'weekly';    
config.erpbMethod = 'analytical';
config.lastEPSpriorQuarter = datenum('31-mar-2020'); 
config.lastEPSfactor = 0.2;
config.nomGrwth = 0.035;
config.nonDivPO2earn = 0.25;
[erpbRTY,~] = calcAnalyticalERPB_jc(config);

config.indexId = 'OEX Index';
config.calcStartDate = '01/01/2018';
config.calcEndDate = datestr(today-1, 'mm/dd/yyyy');
%config.calcEndDate = datestr(today - weekday(today) - 2, 'mm/dd/yyyy');
config.caclFreq = 'weekly';    
config.erpbMethod = 'analytical';
config.lastEPSpriorQuarter = datenum('31-mar-2020'); 
config.lastEPSfactor = 0.2;
config.nomGrwth = 0.04;
config.nonDivPO2earn = 0.25;
[erpbOEX,~] = calcAnalyticalERPB_jc(config);

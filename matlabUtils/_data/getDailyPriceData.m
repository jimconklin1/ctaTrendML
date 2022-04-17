function dataStruct = getDailyPriceData(assetConfig,dataUse)
% Inputs:
%  assetConfig.header, TSRP IDs, (1 x N)
%  assetConfig.startDates, 1 x N
%  assetConfig.endDates, 1 x N
%  assetConfig.pricingClose = 'Tokyo', 'London', 'NewYork' 
%  assetConfig.signalClose = 'Tokyo', 'London', 'NewYork' 
%  assetConfig.rtnType = {tkTypeStr; lnTypeStr; nyTypeStr}, where each
%                         TypeStr = 'syn' or 'raw'
%  dataUse = 'pricing', 'signal', 'Tokyo', 'London', 'NewYork' 
% 
% Outputs: 
% assetData.header     = unique symbols identifying variables in GAUSS
%                        database, corresponding to requested tickers in
%                        assetNameList; 1 x N
% assetData.dates      = date vector associated with data matrix; T x 1
% assetData.startDates = first good data date for the variables in assetData.header, 1 x N
% assetData.endDates   = last good data date for the variables in assetData.header, 1 x N
% assetData.values     = the data themselves, aligned; T x N.
% assetData.busDays    = the good business days associated w/ the data, T x N (note: non-bus days get NaNs).

if nargin < 2 || isempty(dataUse)
   dataUse = 'pricing'; 
end 

startDateStr = datestr(max(assetConfig.startDates),'yyyy-mm-dd'); 
endDateStr = datestr(min(assetConfig.endDates),'yyyy-mm-dd'); 
if strcmpi(assetConfig.header{1}(end-6:end),'Curncy') || strcmpi(assetConfig.header{1}(1:3),'fx.')
   fxFlag = true;
else
   fxFlag = false;
end
switch dataUse
    case 'pricing'
       sessionClose = assetConfig.pricingClose;
    case 'signal'
       sessionClose = assetConfig.signalClose;
    case 'TK'
       sessionClose = 'Tokyo';
    case 'Tokyo'
       sessionClose = 'Tokyo';
    case 'LN'
       sessionClose = 'London';
    case 'London'
       sessionClose = 'London';
    case 'NY'
       sessionClose = 'NY';
    case 'NewYork'
       sessionClose = 'NY';
end 

switch sessionClose
    case 'Tokyo'
        dataStruct = fetchAlignedTSRPdata(assetConfig.header,'price','daily','tokyo',startDateStr,endDateStr,fxFlag,[]); 
        if ~isstruct(dataStruct) && isnan(dataStruct)
           tempStart = datestr(workday(datenum(startDateStr),-1),'yyyy-mm-dd'); 
           tempEnd = datestr(workday(datenum(endDateStr),-1),'yyyy-mm-dd'); 
           dataStruct = fetchAlignedTSRPdata(assetConfig.header,'price','daily','tokyo',tempStart,tempEnd,fxFlag,[]); 
        end
    case 'London'
        dTemp = datetime(now(),'ConvertFrom','datenum','TimeZone','Asia/Singapore');
        if datenum(dTemp) < datenum(endDateStr)+23/24
            startDateStr = datestr(workday(datenum(startDateStr),-1),'yyyy-mm-dd');
            endDateStr = datestr(workday(datenum(endDateStr),-1),'yyyy-mm-dd');
            dataStruct = fetchAlignedTSRPdata(assetConfig.header,'price','daily','london',startDateStr,endDateStr,fxFlag,[]);
        end 
    case 'NY'
        dTemp = datetime(now(),'ConvertFrom','datenum','TimeZone','Asia/Singapore');
        if datenum(dTemp) < datenum(endDateStr)+(12+16)/24
            startDateStr = datestr(workday(datenum(startDateStr),-1),'yyyy-mm-dd');
            endDateStr = datestr(workday(datenum(endDateStr),-1),'yyyy-mm-dd');
            dataStruct = fetchAlignedTSRPdata(assetConfig.header,'price','daily','ny',startDateStr,endDateStr,fxFlag,[]);
        end 
end % switch
dataStruct.timezone = repmat({sessionClose},[1,length(assetConfig.header)]); 
dataStruct.startDates = assetConfig.startDates; 
dataStruct.endDates = assetConfig.endDates; 
end % function

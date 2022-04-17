function dataStruct = getDailyReturnData(assetConfig,dataUse)
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
        dataStruct = fetchAlignedTSRPdata(assetConfig.header,'returns','daily','tokyo',startDateStr,endDateStr,fxFlag,assetConfig.rtnType(1,:));
    case 'London'
        dataStruct = fetchAlignedTSRPdata(assetConfig.header,'returns','daily','london',startDateStr,endDateStr,fxFlag,assetConfig.rtnType(2,:));
    case 'NY'
        dataStruct = fetchAlignedTSRPdata(assetConfig.header,'returns','daily','ny',startDateStr,endDateStr,fxFlag,assetConfig.rtnType(3,:));
end % switch
dataStruct.timezone = repmat(sessionClose,[1,size(assetConfig.header)]); 
dataStruct.startDates = assetConfig.startDates; 
dataStruct.endDates = assetConfig.endDates; 
end % function
 
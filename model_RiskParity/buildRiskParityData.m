function [dataStruct,lonDataStruct,dataStruct2] = buildRiskParityData(ctx,simConfig,countryList)
dataStruct = fetchAlignedTSRPdata(simConfig.assetHeader,'returns','daily','tokyo',ctx.conf.start_date,datestr(datetime('now'),'yyyy-mm-dd'));
dataStruct.TC = simConfig.TC;
lonDataStruct = fetchAlignedTSRPdata(simConfig.assetHeader,'returns','daily','london',ctx.conf.start_date,datestr(datetime('now'),'yyyy-mm-dd'));
lonDataStruct.TC = simConfig.TC;
for n = 1:size(dataStruct.header,2)
    temp = tsrp.fetch_holidays(dataStruct.header{n});
    dataStruct.holidays(n)={temp.datenum_holiday};
end % for n

switch countryList
    case 'US'
    % here get inflation swap data, earnings yield, and 10-yr gov't bond ytm: 
    tickers =   {'USSWIT7 CMPL Curncy', 'USSW10 CMPL Curncy', 'SPX Index', 'SPX Index'};
    bbgFields = {'PX_LAST',             'PX_LAST',            'PX_LAST',   'PE_RATIO'};
    [dataStruct2, badTickers] = fetchBbgDataJC(tickers,bbgFields,ctx.bbgConn,datenum(ctx.conf.start_date),today(),'daily'); 
    dataStruct2.header(4) = {'SPX Index PE'};
    % align datastruct2 and datastruct dates here:
    [temp1, ~] = alignNewDatesJC(dataStruct2.dates, dataStruct2.values, lonDataStruct.dates, NaN);
    dataStruct2.values = temp1;
    [temp2, ~] = alignNewDatesJC(dataStruct2.dates, dataStruct2.levels, lonDataStruct.dates, NaN);
    dataStruct2.levels = temp2;
    dataStruct2.dates = lonDataStruct.dates;
    clear temp1 temp2 tIndx;
    case 'G3'
        
    case 'G6'
        
    case 'G7'
end % switch

if ~isempty(badTickers)
    disp('Warning: fetchBbgDataJC was given bad tickers:')
    disp(badTickers)
end 
end % fn

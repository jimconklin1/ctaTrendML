function [assetData,equityData,ratesData,comdtyData, ...
             ccyData] = buildTrendDatasets(config,dataConfig,assetUniverse,TZ,bbgConn)

truncFlag = config.dataStartDate < config.simStartDate;

if strcmpi(assetUniverse(1:3),'all')||strcmpi(assetUniverse,'combined')
    equityData = getDailyReturnData(dataConfig.equity,TZ);
    equityData.holidays = repmat({''},[1,size(equityData.header,2)]);
    [BusDates , equityData.close] = addWkndRtns2Mon(equityData.dates, equityData.close, TZ);
    equityData.range = alignNewDatesJC(equityData.dates,equityData.range,BusDates);
    equityData.dates = BusDates; 
    for n = 1:size(equityData.header,2)
       temp=tsrp.fetch_holidays(equityData.header{n}); 
       equityData.holidays(n)={temp.datenum_holiday};
    end % for n
    if truncFlag
        equityData2 = startDataTrunc(equityData,config);
    end % if
    ratesData = getDailyReturnData(dataConfig.rates,TZ);
    ratesData.holidays = repmat({''},[1,size(ratesData.header,2)]);
    [ BusDates , ratesData.close ] = addWkndRtns2Mon (ratesData.dates , ratesData.close , TZ );
    ratesData.range = alignNewDatesJC(ratesData.dates,ratesData.range,BusDates);
    ratesData.dates = BusDates; 
    for n = 1:size(ratesData.header,2)
       temp=tsrp.fetch_holidays(ratesData.header{n}); 
       ratesData.holidays(n)={temp.datenum_holiday};
    end % for n
    if truncFlag
        ratesData2 = startDataTrunc(ratesData,config);
    end % if
    comdtyData = getDailyReturnData(dataConfig.comdty,TZ);
    comdtyData.holidays = repmat({''},[1,size(comdtyData.header,2)]);
    [ BusDates , comdtyData.close ] = addWkndRtns2Mon (comdtyData.dates , comdtyData.close , TZ );
    comdtyData.range = alignNewDatesJC(comdtyData.dates,comdtyData.range,BusDates);
    comdtyData.dates = BusDates; 
    for n = 1:size(comdtyData.header,2)
       temp=tsrp.fetch_holidays(comdtyData.header{n}); 
       comdtyData.holidays(n)={temp.datenum_holiday};
    end % for n
    if truncFlag;
       comdtyData2 = startDataTrunc(comdtyData,config);
    end % if
    ccyData = getDailyReturnData(dataConfig.ccy,TZ); 
    [ BusDates , ccyData.close ] = addWkndRtns2Mon (ccyData.dates , ccyData.close , TZ );
    ccyData.range = alignNewDatesJC(ccyData.dates,ccyData.range,BusDates);
    ccyData.dates = BusDates; 
    ccyData = cleanTSRPccyData(ccyData,config,TZ,bbgConn); 
    ccyData.holidays = repmat({''},[1,size(ccyData.header,2)]); % ccys have no holidays
    
    if truncFlag
        ccyData2 = startDataTrunc(ccyData,config);
    end % if 
    if truncFlag
        assetData = hCatDataStructures(equityData2,ratesData2,comdtyData2,ccyData2);
    else
        assetData = hCatDataStructures(equityData,ratesData,comdtyData,ccyData);
    end % if
    assetData.startDates = repmat(config.simStartDate,size(assetData.header));
    assetData.endDates = repmat(config.simEndDate,size(assetData.header));
    
elseif strcmp(assetUniverse,'futures')
    equityData = getDailyReturnData(dataConfig.equity,TZ);
    equityData.holidays = repmat({''},[1,size(equityData.header,2)]);
    [ BusDates , equityData.close ] = addWkndRtns2Mon (equityData.dates , equityData.close , TZ );
    equityData.range = alignNewDatesJC(equityData.dates,equityData.range,BusDates);
    equityData.dates = BusDates; 
    for n = 1:size(equityData.header,2)
       temp=tsrp.fetch_holidays(equityData.header{n}); 
       equityData.holidays(n)={temp.datenum_holiday};
    end % for n
    if truncFlag
        equityData2 = startDataTrunc(equityData,config);
    end % if
    ratesData = getDailyReturnData(dataConfig.rates,TZ);
    ratesData.holidays = repmat({''},[1,size(ratesData.header,2)]);
    [ BusDates , ratesData.close ] = addWkndRtns2Mon (ratesData.dates , ratesData.close , TZ );
    ratesData.range = alignNewDatesJC(ratesData.dates,ratesData.range,BusDates);
    ratesData.dates = BusDates; 
    for n = 1:size(ratesData.header,2)
       temp=tsrp.fetch_holidays(ratesData.header{n}); 
       ratesData.holidays(n)={temp.datenum_holiday};
    end % for n
    if truncFlag
        ratesData2 = startDataTrunc(ratesData,config);
    end % if
    comdtyData = getDailyReturnData(dataConfig.comdty,TZ);
    comdtyData.holidays = repmat({''},[1,size(comdtyData.header,2)]);
    [ BusDates , comdtyData.close ] = addWkndRtns2Mon (comdtyData.dates , comdtyData.close , TZ );
    comdtyData.range = alignNewDatesJC(comdtyData.dates,comdtyData.range,BusDates);
    comdtyData.dates = BusDates; 
    for n = 1:size(comdtyData.header,2)
       temp=tsrp.fetch_holidays(comdtyData.header{n}); 
       comdtyData.holidays(n)={temp.datenum_holiday};
    end % for n
    if truncFlag;
        comdtyData2 = startDataTrunc(comdtyData,config);
    end % if
    ccyData = []; 
    if truncFlag
        assetData = hCatDataStructures(equityData2,ratesData2,comdtyData2);
    else
        assetData = hCatDataStructures(equityData,ratesData,comdtyData);
    end % if
    assetData.startDates = repmat(config.simStartDate,size(assetData.header));
    assetData.endDates = repmat(config.simEndDate,size(assetData.header));

elseif strcmpi(assetUniverse(1:3),'ccy') || strcmpi(assetUniverse(1:3),'cur')
    ccyData = getDailyReturnData(dataConfig.ccy,TZ);
    [ BusDates , ccyData.close ] = addWkndRtns2Mon (ccyData.dates , ccyData.close , TZ );
    ccyData.range = alignNewDatesJC(ccyData.dates,ccyData.range,BusDates);
    ccyData.dates = BusDates; 
    ccyData = cleanTSRPccyData(ccyData,config,TZ,bbgConn); 
    ccyData.holidays = repmat({''},[1,size(ccyData.header,2)]); % ccys have no holidays    
    if truncFlag
        ccyData2 = startDataTrunc(ccyData,config);
    end % if 
    equityData = []; ratesData = []; comdtyData = []; 
    if truncFlag
        assetData = ccyData2;
    else
        assetData = ccyData;
    end % if
    assetData.startDates = repmat(config.simStartDate,size(assetData.header));
    assetData.endDates = repmat(config.simEndDate,size(assetData.header));

end % if

end % function
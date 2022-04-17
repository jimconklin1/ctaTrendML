function [ fillTS, fillPX ] = fillOrderMoc( minBarTS, minBarPX, orderTsUTC,  assetId, dataConfig )
    assetIdIndex = find (ismember (dataConfig.assetIDs,assetId )); 
    exchTZ = dataConfig.assetTimezone{assetIdIndex}; 
    tradingCloseTimeExchTz= dataConfig.trdDayEndTimeExchangeTZ{assetIdIndex} ; 
    
    
    
    orderTsExchTz = datetime (datetime (orderTsUTC, 'ConvertFrom','datenum','TimeZone', 'UTC' ) , 'TimeZone', exchTZ ) ;
    dtCloseExchTz = datetime ([datestr(orderTsExchTz, 'yyyy-mm-dd') ,' ', tradingCloseTimeExchTz], 'TimeZone', exchTZ); 
    if orderTsExchTz <= dtCloseExchTz 
        dtcloseTsUtc = datenum ( datetime (dtCloseExchTz,'TimeZone', 'UTC' )); 
    else 
        holidays = tsrp.fetch_holidays(dataConfig.assetIDsTsrp{assetIdIndex}).datenum_holiday ; 
        dtcloseTsUtc =  datenum ( datetime (datetime (busdate(datenum(dtCloseExchTz),1 , holidays) ,  'ConvertFrom','datenum','TimeZone', exchTZ)  ,'TimeZone', 'UTC' ) );
    end 
    
    indx= find (  minBarTS>dtcloseTsUtc-minutes(20)& minBarTS<=dtcloseTsUtc&~isnan(minBarPX),1, 'last'  ); 
    if isempty (indx)
        error ('no price for MOC')
    end 
    
 
    fillPX= minBarPX( indx);
    fillTS = minBarTS (indx); 




end 
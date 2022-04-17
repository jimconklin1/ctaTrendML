function [ fillTS, fillPX ] = fillOrderMoo( minBarTS, minBarPX, orderTsUTC,  assetId, dataConfig )
    assetIdIndex = find (ismember (dataConfig.assetIDs,assetId )); 
    exchTZ = dataConfig.assetTimezone{assetIdIndex}; 
    tradingOpenTimeExchTz= dataConfig.trdDayStartTimeExchangeTZ{assetIdIndex} ; 
    
    
    
    orderTsExchTz = datetime (datetime (orderTsUTC, 'ConvertFrom','datenum','TimeZone', 'UTC' ) , 'TimeZone', exchTZ ) ;
    dtOpenExchTz = datetime ([datestr(orderTsExchTz, 'yyyy-mm-dd') ,' ', tradingOpenTimeExchTz], 'TimeZone', exchTZ); 
    if orderTsExchTz <= dtOpenExchTz 
        dtOpenTsUtc = datenum ( datetime (dtOpenExchTz,'TimeZone', 'UTC' )); 
    else 
        holidays = tsrp.fetch_holidays(dataConfig.assetIDsTsrp{assetIdIndex}).datenum_holiday ; 
        dtOpenTsUtc =  datenum ( datetime (datetime (busdate(datenum(dtOpenExchTz),1 , holidays) ,  'ConvertFrom','datenum','TimeZone', exchTZ)  ,'TimeZone', 'UTC' ) );
    end 
    
    %indx= find (  minBarTS>=dtOpenTsUtc & minBarTS<dtOpenTsUtc+minutes(20)&~isnan(minBarPX),1  ); 
    indx= find (  minBarTS>=dtOpenTsUtc &~isnan(minBarPX),1  );
    if isempty (indx)
        error ('no price for MOO')
    end 
    
 
    fillPX= minBarPX( indx);
    fillTS = minBarTS (indx); 




end 
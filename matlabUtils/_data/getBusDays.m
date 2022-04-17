function dates = getBusDays( startDate , endDate, closeTZ  )
%This function returns the busdays including start and end dates. The
%timestamps are in UTC, and selected based on the given 'close' (e.g.,
%06:00:00 for tyo close). It also takes into consideration of dst changes. 


    startDate = floor (datenum (startDate)); 
    endDate = floor (datenum (endDate));

    if strcmpi (closeTZ , 'nyc') || strcmpi (closeTZ , 'NewYork') || strcmpi (closeTZ , 'NY') 
        dates = datetime (datetime (busdays (startDate , endDate , 1, nan),'ConvertFrom', 'datenum' ,'TimeZone', 'America/New_York') + hours (16),  'TimeZone', 'UTC'); 

    elseif strcmpi (closeTZ , 'tyo')|| strcmpi (closeTZ , 'Tokyo') || strcmpi (closeTZ , 'TK') 
        dates = datetime (datetime (busdays (startDate , endDate , 1, nan),'ConvertFrom', 'datenum' ,'TimeZone', 'Asia/Tokyo') + hours (15),  'TimeZone', 'UTC'); 

    elseif strcmpi (closeTZ , 'LN')|| strcmpi (closeTZ , 'London') || strcmpi (closeTZ , 'lon')  
        dates = datetime (datetime (busdays (startDate ,endDate , 1, nan),'ConvertFrom', 'datenum' ,'TimeZone', 'Europe/London') + hours (16),  'TimeZone', 'UTC'); 

    end    

    dates= datenum (dates);
end


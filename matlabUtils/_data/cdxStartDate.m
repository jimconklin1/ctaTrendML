function [seriesRollDt,dayRange] = cdxStartDate(ctx,CTicker,CTickerGen,CTickerAll,endDate,StartDate)
    
    temp = getdata(ctx.bbgConn,CTicker,'HISTORY_START_DT');
    if isnan(StartDate)
        startDate = cellstr(datestr(temp.HISTORY_START_DT));   
    else
        startDate = cellstr(repmat(datestr(StartDate),length(CTicker),1));
    end
    startDates = cellstr(datestr([year(startDate), month(startDate), day(startDate), repmat(8,size(startDate,1),1),zeros(size(startDate,1),1),zeros(size(startDate,1),1)]));
    outStartTime = startDates;
    
    for j = 1:length(CTicker)  
        name = char(strrep(strrep(CTickerGen(j),' ','_'),'_PRC',''));
        if ismember(CTickerAll(j),{'CDX EM CDSI GEN 5Y PRC Corp','CDX HY CDSI GEN 5Y PRC Corp','CDX IG CDSI GEN 5Y Corp'})
            fromTimeZone = 'America/New_York';
        elseif ismember(CTickerAll(j),{'SNRFIN CDSI GEN 5Y Corp','ITRX EUR CDSI GEN 5Y Corp','ITRX XOVER CDSI GEN 5Y Corp','SUBFIN CDSI GEN 5Y Corp'})
            fromTimeZone = 'Europe/London';
        elseif ismember(CTickerAll(j),{'ITRX AUS CDSI GEN 5Y Corp'})
            fromTimeZone = 'Australia/Sydney';
        elseif ismember(CTickerAll(j),{'ITRX JAPAN CDSI GEN 5Y Corp'})
            fromTimeZone = 'Asia/Tokyo';
        end
        toTimeZone = 'Asia/Singapore';
        
        tempTZ = datetime(startDates(j),'TimeZone',fromTimeZone);  
        tempTZ.TimeZone = toTimeZone; 
        
        outStartTime(j) = cellstr(tempTZ);
        
        startTimeSeries = busdate(datestr(outStartTime,'yyyy-mm-dd'),1);
        dayRange.(name) = cellstr(datestr(startTimeSeries(j):hours(24):endDate,'dd-mmm-yyyy'));
                
    end

    seriesRollDt = array2table([CTickerGen' outStartTime cellstr(datestr(startTimeSeries))],'VariableNames',{'Ticker','Initial_DT','Busdate_1'});
        
    
end

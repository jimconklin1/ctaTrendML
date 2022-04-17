function cdxPrice = GetCleanSpread(ctx,CTickerHis,dayRange,startDate,endDate,fromTimeZone,toTimeZone,CTickerName,cdxSpread)
   % pull price for tickers that have prices using 'history' function
   localTime = datetime(dayRange,'TimeZone',fromTimeZone);
   localTime.TimeZone = toTimeZone; 
   for i = 1:length(CTickerHis)
        CleanPriceHis = zeros(length(dayRange), 4);    
        price = history(ctx.bbgConn,CTickerHis(i),{'Open','High','Low','PX_LAST'},startDate,endDate);
        CleanPriceHis(ismember(dayRange,datestr(price(:,1))),:) = price(:,2:end);

        CleanPriceHis = [dayRange cellstr(localTime) array2table(CleanPriceHis)]; 
        CleanPriceHis.Properties.VariableNames = {'systemTime','localTime','Open','High','Low','Close'};
        cdxSpread.(char(strrep(strrep(CTickerName(i),' ','_'),'_PRC',''))) = CleanPriceHis;
    end
end
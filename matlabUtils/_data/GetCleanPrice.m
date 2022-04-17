function cdxPrice = GetCleanPrice(ctx,CTickerHis,sysDayRange,fromTimeZone,toTimeZone,CTickerName,cdxPrice)
   % pull price for tickers that have prices using 'history' function

   for i = 1:length(CTickerHis)
        dRange = sysDayRange.(char(strrep(strrep(CTickerName(i),' ','_'),'_PRC','')));
        localTime = datetime(dRange,'TimeZone',fromTimeZone);
        localTime.TimeZone = toTimeZone; 
        dayRange = cellstr(localTime(and(weekday(localTime)~=7,weekday(localTime)~=1)));
        dStartDate = datenum(dayRange(1));
        dEndDate = datenum(dayRange(end));
        price = history(ctx.bbgConn,CTickerHis(i),{'Open','High','Low','PX_LAST'},dStartDate,dEndDate);
        if ~isempty(price)
            dayRange = dayRange(ismember(dayRange,datestr(price(:,1))));
            index = ismember(cellstr(localTime),dayRange);
            CleanPriceHis = zeros(length(dayRange), 4);           
            if ~isempty(price)
                CleanPriceHis(ismember(dayRange,datestr(price(:,1))),:) = price(:,2:end);
            end
            for k = 2:size(CleanPriceHis,1)
                for l = 1:size(CleanPriceHis,2)
                    if CleanPriceHis(k,l) == 0
                        CleanPriceHis(k,l) = CleanPriceHis(k-1,l);
                    end
                end
            end        
            CleanPriceHis = [dRange(index) dayRange array2table(CleanPriceHis)]; 
            CleanPriceHis.Properties.VariableNames = {'systemTime','localTime','Open','High','Low','Close'};

            cdxPrice.(char(strrep(strrep(CTickerName(i),' ','_'),'_PRC',''))) = CleanPriceHis;
        else
            cdxPrice.(char(strrep(strrep(CTickerName(i),' ','_'),'_PRC',''))) = [];
        end
   end
   
end
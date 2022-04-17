function cdxPrice = sprdToPrc(ctx,ticker,cdxSpread,tickerName,cdxPrice)
% pull price for tickers that only have spread using 'getdata' function
fprintf('%s: spread to price starting time.\n', datestr(datetime()));

for j = 1:length(ticker)
    sprd = cdxSpread.(char(strrep(tickerName(j),' ','_')));
    if ~isempty(sprd)
        dayRange = sprd.localTime;
        Bprc = zeros(length(dayRange), 4);
        for i = 1:length(dayRange)
            Qsprd = table2array(sprd(i,3:end));
            for k = 1:length(Qsprd)
                spread = num2str(Qsprd(k));
                swapDt = datestr(busdate(datenum(sprd.localTime(i)),-1),'yyyymmdd');
                price = getdata(ctx.bbgConn,ticker(j),{'CDS_QUOTED_PRICE'},{'CDS_FLAT_SPREAD','SW_CURVE_DT'},{spread swapDt});
                if ~isnumeric(price.CDS_QUOTED_PRICE)   
                    price = getdata(ctx.bbgConn,ticker(j),{'CDS_QUOTED_PRICE'},{'CDS_FLAT_SPREAD','SW_CURVE_DT'},{spread swapDt});
                end
                if ~isnumeric(price.CDS_QUOTED_PRICE)   
                    Bprc(i,k) = 0;
                else
                    Bprc(i,k) = price.CDS_QUOTED_PRICE;
                end
            end
        end
        Bprc = [sprd(:,1:2) array2table(Bprc(:,1),'VariableNames',{'Open'}) array2table(Bprc(:,3),'VariableNames',{'High'}) array2table(Bprc(:,2),'VariableNames',{'Low'}) array2table(Bprc(:,4),'VariableNames',{'Close'})];
        Bprc.Properties.VariableNames = sprd.Properties.VariableNames; 
        cdxPrice.(char(strrep(tickerName(j),' ','_'))) = Bprc;
    else
        cdxPrice.(char(strrep(tickerName(j),' ','_'))) = [];
    end
end

fprintf('%s: spread to price ending time.\n', datestr(datetime()));

end
    
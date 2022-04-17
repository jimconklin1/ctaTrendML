function cdxSpread = prcToSprd(ctx,ticker,cdxPrice,tickerName,cdxSpread)
% pull price for tickers that only have spread using 'getdata' function
fprintf('%s: price to spread starting time.\n', datestr(datetime()));

for j = 1:length(ticker)
    prc = cdxPrice.(char(strrep(strrep(tickerName(j),' ','_'),'_PRC','')));
    if ~isempty(prc)
        dayRange = prc.localTime;
        Bsprd = zeros(length(dayRange), 4);
        for i = 1:length(dayRange)
            Qprice = table2array(prc(i,3:end));
            for k = 1:length(Qprice)
                price = num2str(Qprice(k));
                swapDt = datestr(busdate(datenum(prc.localTime(i)),-1),'yyyymmdd');
                spread = getdata(ctx.bbgConn,ticker(j),{'CDS_FLAT_SPREAD'},{'CDS_QUOTED_PRICE','SW_CURVE_DT'},{price swapDt});
                if ~isnumeric(spread.CDS_FLAT_SPREAD)   
                    spread = getdata(ctx.bbgConn,ticker(j),{'CDS_FLAT_SPREAD'},{'CDS_QUOTED_PRICE','SW_CURVE_DT'},{price swapDt});

                end
                if ~isnumeric(spread.CDS_FLAT_SPREAD)   
                    Bsprd(i,k) = 0;
                else
                    Bsprd(i,k) = spread.CDS_FLAT_SPREAD;
                end
            end
        end
        Bsprd = [prc(:,1:2) array2table(Bsprd(:,1),'VariableNames',{'Open'}) array2table(Bsprd(:,3),'VariableNames',{'High'}) array2table(Bsprd(:,2),'VariableNames',{'Low'}) array2table(Bsprd(:,4),'VariableNames',{'Close'})];
        Bsprd.Properties.VariableNames = prc.Properties.VariableNames; 
        cdxSpread.(char(strrep(strrep(tickerName(j),' ','_'),'_PRC_Corp','_Corp'))) = Bsprd;
    else
        cdxSpread.(char(strrep(strrep(tickerName(j),' ','_'),'_PRC_Corp','_Corp'))) = [];
    end
end

fprintf('%s:price to spread ending time.\n', datestr(datetime()));

end
    
function BCDSPrice = GetSpreadPrice(ctx,dayRange,CTickerSprd)
% pull price for tickers that only have spread using 'getdata' function
fprintf('%s: pull spread price starting time.\n', datestr(datetime()));
BCDSPrice = zeros(length(dayRange), length(CTickerSprd));

for j= 1:length(CTickerSprd)
    for i = 1:length(dayRange)
        bprice = getdata(ctx.bbgConn,CTickerSprd(j),{'CDS_QUOTED_PRICE'},{'SW_CURVE_DT'},cellstr(datestr(datenum(dayRange(i)),'yyyymmdd')));
        if ~isnumeric(bprice.CDS_QUOTED_PRICE)   
            bprice = getdata(ctx.bbgConn,CTickerSprd(j),{'CDS_QUOTED_PRICE'},{'SW_CURVE_DT'},cellstr(datestr(datenum(dayRange(i)),'yyyymmdd')));
        else
            BCDSPrice(i,j) = bprice.CDS_QUOTED_PRICE;
        end
    end
end

for i = 1:length(CTickerSprd)
    for j = 2:rows(BCDSPrice)
        if BCDSPrice(j,i) == 0
            BCDSPrice(j,i) = BCDSPrice(j-1,i);
        end
    end
end

fprintf('%s: pull spread price ending time.\n', datestr(datetime()));

end
    
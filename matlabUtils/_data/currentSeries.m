function cSeries = currentSeries(ctx,CTickerAll,series,CTickerGen)
    
    temp = getdata(ctx.bbgConn,CTickerAll,'ROLLING_SERIES');
    currentSeries = temp.ROLLING_SERIES;
    index = ismember(currentSeries,cellstr(num2str(series)));
    cSeries = array2table([CTickerAll' CTickerGen' currentSeries cellstr(num2str(index))],'VariableNames',{'ticker','tickers','currentSeries','current'});    
end

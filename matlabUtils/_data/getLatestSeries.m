function [currentSeries,seriesInfo] = getLatestSeries(ctx)

    CTickerAll = {'CDX EM CDSI GEN 5Y PRC Corp','CDX HY CDSI GEN 5Y PRC Corp','CDX IG CDSI GEN 5Y Corp','SNRFIN CDSI GEN 5Y Corp',...
        'ITRX EUR CDSI GEN 5Y Corp','ITRX XOVER CDSI GEN 5Y Corp','SUBFIN CDSI GEN 5Y Corp',...
        'ITRX AUS CDSI GEN 5Y Corp','ITRX JAPAN CDSI GEN 5Y Corp'};
    temp = getdata(ctx.bbgConn,CTickerAll,'ROLLING_SERIES');
    currentSeries = max(str2num(cell2mat(temp.ROLLING_SERIES))); %#ok<ST2NM>
    seriesInfo = array2table([CTickerAll' temp.ROLLING_SERIES],'VariableNames',{'ticker','current_series'});

end

    
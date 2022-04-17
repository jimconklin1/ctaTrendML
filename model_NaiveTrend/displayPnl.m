function displayPnl(portSim, trendType, verbose)
    if verbose && (~isdeployed)
        figure; plot(portSim.dates,calcCum(portSim.totPnl,0)); datetick('x','yyyy'); title(trendType); grid
        disp(['The Sharpe ratio of the ', trendType, ' simulation PnL is ',num2str(16*nanmean(portSim.totPnl)/nanstd(portSim.totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' rates sim  PnL is ',num2str(16*nanmean(portSim.subStrat(1).totPnl)/nanstd(portSim.subStrat(1).totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' equity DM sim PnL is ',num2str(16*nanmean(portSim.subStrat(2).totPnl)/nanstd(portSim.subStrat(2).totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' equity EM sim PnL is ',num2str(16*nanmean(portSim.subStrat(3).totPnl)/nanstd(portSim.subStrat(3).totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' curncy DM sim PnL is ',num2str(16*nanmean(portSim.subStrat(4).totPnl)/nanstd(portSim.subStrat(4).totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' curncy EM sim PnL is ',num2str(16*nanmean(portSim.subStrat(5).totPnl)/nanstd(portSim.subStrat(5).totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' comdty energy sim PnL is ',num2str(16*nanmean(portSim.subStrat(6).totPnl)/nanstd(portSim.subStrat(6).totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' comdty metals sim PnL is ',num2str(16*nanmean(portSim.subStrat(7).totPnl)/nanstd(portSim.subStrat(7).totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' comdty ags sim PnL is ',num2str(16*nanmean(portSim.subStrat(8).totPnl)/nanstd(portSim.subStrat(8).totPnl))])
        disp(['The Sharpe ratio of the ', trendType, ' short rates sim PnL is ',num2str(16*nanmean(portSim.subStrat(9).totPnl)/nanstd(portSim.subStrat(9).totPnl))])
    end
end


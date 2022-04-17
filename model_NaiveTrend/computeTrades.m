function portSim = computeTrades(portSim, portSimMMA, portSimMBO, portSimMMO,portSimTSTAT ,  dataConfig)

portSim.mmaPnl = portSimMMA.totPnl;
portSim.mboPnl = portSimMBO.totPnl;
portSim.mmoPnl = portSimMMO.totPnl;
portSim.tstatPnl = portSimTSTAT.totPnl;
indexEq = ismember(portSim.header, dataConfig.equity.header);
indexRates = ismember(portSim.header, dataConfig.rates.header);
indexCmd = ismember(portSim.header, dataConfig.comdty.header);
indexCcy = ismember(portSim.header, dataConfig.ccy.header);
portSim.equWts = sum(portSim.wts(:, indexEq), 2);
portSim.ratesWts = sum(portSim.wts(:, indexRates), 2);
portSim.cmdWts = sum(portSim.wts(:, indexCmd), 2);
portSim.ccyWts = sum(portSim.wts(:, indexCcy), 2);
portSim.equTrades = [0;(portSim.equWts(2:end,:) - portSim.equWts(1:end-1,:))];
portSim.ratesTrades = [0;(portSim.ratesWts(2:end,:) - portSim.ratesWts(1:end-1,:))];
portSim.cmdTrades = [0;(portSim.cmdWts(2:end,:) - portSim.cmdWts(1:end-1,:))];
portSim.ccyTrades = [0;(portSim.ccyWts(2:end,:) - portSim.ccyWts(1:end-1,:))];
portSim.equPnl = sum(portSim.pnl(:, indexEq), 2);
portSim.ratesPnl = sum(portSim.pnl(:, indexRates), 2);
portSim.cmdPnl = sum(portSim.pnl(:, indexCmd), 2);
portSim.ccyPnl = sum(portSim.pnl(:, indexCcy), 2);
portSim.trades = [zeros(1, length(portSim.header));(portSim.wts(2:end,:) - portSim.wts(1:end-1,:))];

end
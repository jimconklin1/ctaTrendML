function portSim = prepareData4VizAC(portSimCombined, dataConfig)

portSim.dates = portSimCombined.dates;

indexEquity = ismember(portSimCombined.header, dataConfig.equity.header);
portSim.equityPnl = nansum(portSimCombined.pnl(:,indexEquity),2);

indexFX = ismember(portSimCombined.header, dataConfig.ccy.header);
portSim.fxPnl = nansum(portSimCombined.pnl(:,indexFX),2);

indexRates = ismember(portSimCombined.header, dataConfig.rates.header);
portSim.ratesPnl = nansum(portSimCombined.pnl(:,indexRates),2);

indexCmd = ismember(portSimCombined.header, dataConfig.comdty.header);
portSim.cmdPnl = nansum(portSimCombined.pnl(:,indexCmd),2);
indexCmdEnergy = ismember(portSimCombined.header, dataConfig.comdty.energy.header);
portSim.cmdEnergyTrades = nansum(portSimCombined.trades(:, indexCmdEnergy), 2);
indexCmdMetals = ismember(portSimCombined.header, dataConfig.comdty.energy.header);
portSim.cmdMetalsTrades = nansum(portSimCombined.trades(:, indexCmdMetals), 2);
indexCmdAgs = ismember(portSimCombined.header, dataConfig.comdty.energy.header);
portSim.cmdAgsTrades = nansum(portSimCombined.trades(:, indexCmdAgs), 2);

end
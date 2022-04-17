function portSim = prepareData4Viz(portSimCombined, dataConfig)

portSim.dates = portSimCombined.dates;

indexAmerica = ismember(portSimCombined.header, dataConfig.americaHeaders);
portSim.americaPnl = nansum(portSimCombined.pnl(:, indexAmerica), 2);
indexAmericaEquity = ismember(portSimCombined.header, intersect(dataConfig.americaHeaders, dataConfig.equity.header));
portSim.americaEquityTrades = nansum(portSimCombined.pnl(:, indexAmericaEquity), 2);
indexAmericaRates = ismember(portSimCombined.header, intersect(dataConfig.americaHeaders, dataConfig.rates.header));
portSim.americaRatesTrades = nansum(portSimCombined.pnl(:, indexAmericaRates), 2);
indexAmericaCcy = ismember(portSimCombined.header, intersect(dataConfig.americaHeaders, dataConfig.ccy.header));
portSim.americaCcyTrades = nansum(portSimCombined.pnl(:, indexAmericaCcy), 2);

indexEmea = ismember(portSimCombined.header, dataConfig.emeaHeader);
portSim.emeaPnl = nansum(portSimCombined.pnl(:, indexEmea), 2);
indexEmeaEquity = ismember(portSimCombined.header, intersect(dataConfig.emeaHeader, dataConfig.equity.header));
portSim.emeaEquityTrades = nansum(portSimCombined.pnl(:, indexEmeaEquity), 2);
indexEmeaRates = ismember(portSimCombined.header, intersect(dataConfig.emeaHeader, dataConfig.rates.header));
portSim.emeaRatesTrades = nansum(portSimCombined.pnl(:, indexEmeaRates), 2);
indexEmeaCcy = ismember(portSimCombined.header, intersect(dataConfig.emeaHeader, dataConfig.ccy.header));
portSim.emeaCcyTrades = nansum(portSimCombined.pnl(:, indexEmeaCcy), 2);

indexAp = ismember(portSimCombined.header, dataConfig.asiaPacificHeaders);
portSim.apPnl = nansum(portSimCombined.pnl(:, indexAp), 2);
indexApEquity = ismember(portSimCombined.header, intersect(dataConfig.asiaPacificHeaders, dataConfig.equity.header));
portSim.apEquityTrades = nansum(portSimCombined.pnl(:, indexApEquity), 2);
indexApRates = ismember(portSimCombined.header, intersect(dataConfig.asiaPacificHeaders, dataConfig.rates.header));
portSim.apRatesTrades = nansum(portSimCombined.pnl(:, indexApRates), 2);
indexApCcy = ismember(portSimCombined.header, intersect(dataConfig.asiaPacificHeaders, dataConfig.ccy.header));
portSim.apCcyTrades = nansum(portSimCombined.pnl(:, indexApCcy), 2);

indexCmd = ismember(portSimCombined.header, dataConfig.comdty.header);
portSim.cmdPnl = nansum(portSimCombined.pnl(:, indexCmd), 2);
indexCmdEnergy = ismember(portSimCombined.header, dataConfig.comdty.energy.header);
portSim.cmdEnergyTrades = nansum(portSimCombined.trades(:, indexCmdEnergy), 2);
indexCmdMetals = ismember(portSimCombined.header, dataConfig.comdty.energy.header);
portSim.cmdMetalsTrades = nansum(portSimCombined.trades(:, indexCmdMetals), 2);
indexCmdAgs = ismember(portSimCombined.header, dataConfig.comdty.energy.header);
portSim.cmdAgsTrades = nansum(portSimCombined.trades(:, indexCmdAgs), 2);

end
function riskConfig = configureRisk4RiskParity2(simConfig)

riskConfig.buffer = 260;

riskConfig.volMethod = 'closeEWA'; % 'closeEWA', 'dailyRangeEWA', 'mixedEWA'

riskConfig.volFloor = repmat(0.035,[1,size(simConfig.assetClass,2)]); % default for 10yr bond min vol
indx = strcmp(simConfig.assetClass,'equities');
riskConfig.volFloor(1,indx) = 0.10;
indx = strcmp(simConfig.assetClass,'comdty');
riskConfig.volFloor(1,indx) = 0.15;

riskConfig.volMix = 0.5; 
riskConfig.volRangeHL = 11;
riskConfig.volRangeHL2 = 130;
riskConfig.volCloseHL = 21;
riskConfig.volCloseHL2 = 260;
riskConfig.volAlpha = 0.5;

riskConfig.corrShrinkFactor = 0.85;
riskConfig.corrHL = 42;
riskConfig.corrHL2 = 520;
riskConfig.corrAlpha = 0.5;
riskConfig.covAlpha = 0.5; 
end % fn
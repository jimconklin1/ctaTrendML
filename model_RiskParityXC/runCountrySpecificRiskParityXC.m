function [outStruct,outStruct2,simTrackOutStruct] = runCountrySpecificRiskParityXC(ctx, simConfig, riskConfig) 
dataStruct = fetchAlignedTSRPdata(simConfig.assetHeader,'returns','daily','tokyo',ctx.conf.start_date,datestr(datetime('now'),'yyyy-mm-dd'));
dataStruct.TC = simConfig.TC; 
for n = 1:size(dataStruct.header,2)
   temp = tsrp.fetch_holidays(dataStruct.header{n}); 
   dataStruct.holidays(n)={temp.datenum_holiday};
end % for n
omega = calcRiskMatrix2(dataStruct,riskConfig); 
annPortVol = repmat(simConfig.volTarget,[size(dataStruct.close,1),1]);
riskWts = simConfig.assetRiskWts; 
portSim = computeWeights(dataStruct,riskWts,annPortVol,omega); 
% Export weights based on today's Tokyo close for Sim Tracker
simTrackOutStruct = portSim;
simTrackOutStruct.header = simConfig.assetHeader;

lonDataStruct = fetchAlignedTSRPdata(simConfig.assetHeader,'returns','daily','london',ctx.conf.start_date,datestr(datetime('now'),'yyyy-mm-dd'));
lonDataStruct.TC = simConfig.TC;
portSim.riskWts = alignNewDatesJC(portSim.dates, portSim.riskWts, lonDataStruct.dates);
portSim.wts = alignNewDatesJC(portSim.dates, portSim.wts, lonDataStruct.dates);
portPnl = computePnl(lonDataStruct, portSim);

outStruct.header = simConfig.assetHeader; 
outStruct.assetClass = simConfig.assetClass; 
outStruct.country = simConfig.assetCountry; 
outStruct.dates = lonDataStruct.dates; 
outStruct.countryUniv = ctx.conf.country_universe; 
outStruct.riskWts = portSim.riskWts; % riskWts get re-sized in fn
outStruct.wts = portSim.wts; 
outStruct.pnl = portPnl.netPnl; 
outStruct.allPnl = nansum(portPnl.netPnl,2); 
% country PnLs:
for n = 1:length(simConfig.countryHeader) 
    cc = simConfig.countryHeader{n};
    cIndx = find(ismember(simConfig.assetCountry,cc));
    temp1 = nansum(portPnl.netPnl(:,cIndx),2); %#ok
    eval(['outStruct.',cc,'Pnl = temp1;'])
end % n

allTrades = [zeros(1,size(portSim.wts,2)); ...
             (portSim.wts(2:end,:) - portSim.wts(1:end-1,:))]; 
outStruct.trades = allTrades;

outStruct2.header = {'equities','rates'}; 
outStruct2.dates = lonDataStruct.dates; 
outStruct2.countryUniv = ctx.conf.country_universe; 
% country-specific trades, 'na' included for crude:
cIndx1 = find(ismember(simConfig.assetClass,'equities')); 
temp1 = ma(sum(allTrades(:,cIndx1),2),3); %#ok<FNDSB>
cIndx2 = find(ismember(simConfig.assetClass,'rates')); 
temp2 = ma(sum(allTrades(:,cIndx2),2),3); %#ok<FNDSB>
outStruct2.allTrades = [temp1, temp2];
for n = 1:length(simConfig.countryHeader) 
    cc = simConfig.countryHeader{n};
    cIndx1 = find(ismember(simConfig.assetCountry,cc) & ...
        ismember(simConfig.assetClass,'equities'));
    cIndx2 = find(ismember(simConfig.assetCountry,cc) & ...
        ismember(simConfig.assetClass,'rates'));
    temp1 = sum(allTrades(:,cIndx1),2); %#ok<FNDSB,NASGU>
    temp2 = sum(allTrades(:,cIndx2),2); %#ok<FNDSB,NASGU>
    eval(['outStruct2.',cc,'Trades = [temp1,temp2];'])
end % n

end % fn 
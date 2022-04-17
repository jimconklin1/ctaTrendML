function [outStruct,outStruct2,simTrackOutStruct] = runCountrySpecificRiskParity(ctx, simConfig, riskConfig) 
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
cComdty = find(strcmp(simConfig.assetCountry,'na')); 
for n = 1:length(simConfig.countryHeader) 
   if ~strcmp(simConfig.countryHeader{n},'na') 
      cc = simConfig.countryHeader{n};
      cIndx = find(ismember(simConfig.assetCountry,cc)); 
      temp1 = nansum(portPnl.netPnl(:,cIndx),2); %#ok
      tempC = nansum(simConfig.countryWts(n)*portPnl.netPnl(:,cComdty),2); %#ok NOTE: crude position is divided by country wt
      eval(['outStruct.',cc,'Pnl = temp1 + tempC;']) 
   end % if
end % n

allTrades = [zeros(1,size(portSim.wts,2)); ...
             (portSim.wts(2:end,:) - portSim.wts(1:end-1,:))]; 
outStruct.trades = allTrades;

outStruct2.header = {'equities','rates','comdty'}; 
outStruct2.dates = lonDataStruct.dates; 
outStruct2.countryUniv = ctx.conf.country_universe; 
% country-specific trades, 'na' included for crude:
cCrude = find(strcmp(simConfig.assetCountry,'na')); 
cIndx1 = find(ismember(simConfig.assetClass,'equities')); 
temp1 = ma(sum(allTrades(:,cIndx1),2),3); %#ok<FNDSB>
cIndx2 = find(ismember(simConfig.assetClass,'rates')); 
temp2 = ma(sum(allTrades(:,cIndx2),2),3); %#ok<FNDSB>
tempC = ma(sum(allTrades(:,cCrude),2),3); 
outStruct2.allTrades = [temp1, temp2, tempC];
for n = 1:length(simConfig.countryHeader) 
   if ~strcmp(simConfig.countryHeader{n},'na') 
      cc = simConfig.countryHeader{n};
      cIndx1 = find(ismember(simConfig.assetCountry,cc) & ...
                    ismember(simConfig.assetClass,'equities')); 
      cIndx2 = find(ismember(simConfig.assetCountry,cc) & ...
                    ismember(simConfig.assetClass,'rates')); 
      temp1 = sum(allTrades(:,cIndx1),2); %#ok<FNDSB,NASGU>
      temp2 = sum(allTrades(:,cIndx2),2); %#ok<FNDSB,NASGU>
      tempC = simConfig.countryWts(n)*ma(sum(allTrades(:,cCrude),2),3); %#ok<NASGU>
      eval(['outStruct2.',cc,'Trades = [temp1,temp2,tempC];']) 
   end % if
end % n

end % fn 
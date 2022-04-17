function portConfig = configPortConstruction2(dataConfig)

portConfig.method = 'fixedRiskWeights'; % 'proportionalRisk'; % 'corrParity' 
portConfig.ddMode = false; % if set to true, fill in dd params below  
portConfig.ddOpt = false; % if set to true, fill in dd params below  
portConfig.rebalTol = 0.001; 
portConfig.portVolTarget = 0.16; % ANNUAL vol units  
portConfig.assetVolFloor = 0.02; 
portConfig.numSubStrats = 9; 
portConfig.names = {'ratesBond','equityDM','equityEM','ccyDM','ccyEM',...
                    'comdtyEnergy','comdtyMetals','comdtyAgs','ratesShortRates'}; 
portConfig.assetClass = {'rates','equity','equity','ccy', 'ccy','comdty','comdty','comdty','rates'};
portConfig.subStratWts = [0.15,   0.125,   0.125,  0.075, 0.125, 0.125, 0.125,  0.00, 0.15];

portConfig.subStrat(1).indx = 1:length(dataConfig.rates.bonds.header);
portConfig.subStrat(1).header = dataConfig.rates.bonds.header;

portConfig.subStrat(2).indx = 1:length(dataConfig.equity.dm.header);
portConfig.subStrat(2).header = dataConfig.equity.dm.header;

portConfig.subStrat(3).indx = (1:length(dataConfig.equity.em.header)) + length(dataConfig.equity.dm.header);
portConfig.subStrat(3).header = dataConfig.equity.em.header; % XP1, PT1 -- later move to DM and replace w/ true EM indices 

portConfig.subStrat(4).indx = 1:length(dataConfig.ccy.dm.header);
portConfig.subStrat(4).header = dataConfig.ccy.dm.header;

portConfig.subStrat(5).indx = (1:length(dataConfig.ccy.em.header)) + length(dataConfig.ccy.dm.header);
portConfig.subStrat(5).header = dataConfig.ccy.em.header;

portConfig.subStrat(6).indx = 1:length(dataConfig.comdty.energy.header);
portConfig.subStrat(6).header = dataConfig.comdty.energy.header;

portConfig.subStrat(7).indx = (1:length(dataConfig.comdty.metals.header)) + length(dataConfig.comdty.energy.header);
portConfig.subStrat(7).header = dataConfig.comdty.metals.header;

portConfig.subStrat(8).indx = (1:length(dataConfig.comdty.ags.header)) + length(dataConfig.comdty.energy.header) + length(dataConfig.comdty.metals.header);
portConfig.subStrat(8).header = dataConfig.comdty.ags.header;

portConfig.subStrat(9).indx = (1:length(dataConfig.rates.shortRates.header)) + length(dataConfig.rates.bonds.header);
portConfig.subStrat(9).header = dataConfig.rates.shortRates.header;

portConfig.subStrat(1).executionLag = repmat(1,[1,length(portConfig.subStrat(1).header)]); %#ok<RPMT1> 
portConfig.subStrat(2).executionLag = repmat(1,[1,length(portConfig.subStrat(2).header)]); %#ok<RPMT1> 
portConfig.subStrat(3).executionLag = repmat(1,[1,length(portConfig.subStrat(3).header)]); %#ok<RPMT1> 
portConfig.subStrat(4).executionLag = repmat(1,[1,length(portConfig.subStrat(4).header)]); %#ok<RPMT1> 
portConfig.subStrat(5).executionLag = repmat(1,[1,length(portConfig.subStrat(5).header)]); %#ok<RPMT1> 
portConfig.subStrat(6).executionLag = repmat(1,[1,length(portConfig.subStrat(6).header)]); %#ok<RPMT1> 
portConfig.subStrat(7).executionLag = repmat(1,[1,length(portConfig.subStrat(7).header)]); %#ok<RPMT1> 
portConfig.subStrat(8).executionLag = repmat(1,[1,length(portConfig.subStrat(8).header)]); %#ok<RPMT1> 
portConfig.subStrat(9).executionLag = repmat(1,[1,length(portConfig.subStrat(9).header)]); %#ok<RPMT1> 

portConfig.executionLag = repmat(1,[1,length(dataConfig.assetIDs)]); %#ok<RPMT1> 
portConfig.annBusDays = 260; 
end % fn
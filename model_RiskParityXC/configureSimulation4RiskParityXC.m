function simConfig = configureSimulation4RiskParityXC(countryUniv)
simConfig.countryUniv = countryUniv; 
simConfig.volTarget = 0.08;
switch countryUniv
    case 'G3'
        simConfig.countryHeader = {'us','xm','jp','na'}; 
        simConfig.countryWts = [0.4,0.325,0.275]; % note, 'na' = not applicable, meaning asset gets applied in full to all countries
        simConfig.assetClassHeader = {'equities','rates'};
        simConfig.assetClassRiskWts = [0.5,0.5];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','NK1 Index',...
                                 'JB1 Comdty'};
        simConfig.assetCountry = {'us','us','xm','xm','jp','jp'};
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates'};
        simConfig.TC = [1, 1.25, 1, 1, 1, 0.9];
    case 'G6' 
        simConfig.countryHeader = {'us','xm','jp','gb','au','ca'}; 
        simConfig.countryWts = [0.25,0.20,0.175,0.125,0.125,0.125]; % note, 'na' = not applicable, meaning asset gets applied in full to all countries
        simConfig.assetClassHeader = {'equities','rates','comdty'};
        simConfig.assetClassRiskWts = [0.4,0.4,0.2];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','NK1 Index',...
                                 'JB1 Comdty','Z 1 Index','G 1 Comdty','XP1 Index','XM1 Comdty',...
                                 'PT1 Index','CN1 Comdty'}; 
        simConfig.assetCountry = {'us','us','xm','xm','jp','jp','gb','gb','au','au','ca','ca'}; 
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates','equities',...
                                'rates','equities','rates','equities','rates'}; 
        simConfig.TC = [1,1.25,1,1,1,0.9,1,1,2,2,2,2];
    case 'G6xJ'
        simConfig.countryHeader = {'us','xm','gb','au','ca'}; 
        simConfig.countryWts = [0.25,0.21,0.18,0.18,0.18]; 
        simConfig.assetClassHeader = {'equities','rates'};
        simConfig.assetClassRiskWts = [0.5,0.5];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','Z 1 Index',...
                              'G 1 Comdty','XP1 Index','XM1 Index','PT1 Index','CN1 Comdty'};
        simConfig.assetCountry = {'us','us','xm','xm','gb','gb','au','au','ca','ca'}; 
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates','equities',...
                                'rates','equities','rates','equities','rates'}; 
        simConfig.TC = [1,1.25,1,1,1,1,2,2,2,2];
    case 'G7' 
        simConfig.countryHeader = {'us','xm','jp','gb','au','ca','kr'}; 
        simConfig.countryWts = [0.18,0.165,0.155,0.125,0.125,0.125,0.125]; % note, 'na' = not applicable, meaning asset gets applied in full to all countries
        simConfig.assetClassHeader = {'equities','rates','comdty'};
        simConfig.assetClassRiskWts = [0.5,0.5];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','NK1 Index',...
                                 'JB1 Comdty','Z 1 Index','G 1 Comdty','XP1 Index','XM1 Comdty',...
                                 'PT1 Index','CN1 Comdty','KAA1 Comdty','KM1 Index'}; 
        simConfig.assetCountry = {'us','us','xm','xm','jp','jp','gb','gb','au','au','ca','ca','kr','kr'}; 
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates','equities',...
                                'rates','equities','rates','equities','rates','rates','equities'}; 
        simConfig.TC = [1,1.25,1,1,1,0.9,1,1,2,2,2,2,2,2];
    case 'DM' % same as G6 for now
        simConfig.countryHeader = {'us','xm','jp','gb','au','ca'}; 
        simConfig.countryWts = [0.2,0.18,0.17,0.15,0.15,0.15]; % note, 'na' = not applicable, meaning asset gets applied in full to all countries
        simConfig.assetClassHeader = {'equities','rates','comdty'};
        simConfig.assetClassRiskWts = [0.4,0.4,0.2];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','NK1 Index',...
                                 'JB1 Comdty','Z 1 Index','G 1 Comdty','XP1 Index','XM1 Comdty',...
                                 'PT1 Index','CN1 Comdty'}; 
        simConfig.assetCountry = {'us','us','xm','xm','jp','jp','gb','gb','au','au','ca','ca'}; 
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates','equities',...
                                'rates','equities','rates','equities','rates','comdty'}; 
        simConfig.TC = [1,1.25,1,1,1,0.9,1,1,2,2]; 
end
simConfig.assetRiskWts = zeros(1,size(simConfig.assetHeader,2));
for n = 1:size(simConfig.assetHeader,2)
   jj = find(strcmp(simConfig.assetClassHeader,simConfig.assetClass(n)));
   kk = find(strcmp(simConfig.countryHeader,simConfig.assetCountry(n)));
   simConfig.assetRiskWts(1,n) = simConfig.assetClassRiskWts(1,jj)*simConfig.countryWts(1,kk); %#ok<FNDSB>
end % for
simConfig.volMethod = 'mixedEWA'; % 'closeEWA', 'dailyRangeEWA', 'mixedEWA'
simConfig.volRangeHL = 14;
simConfig.volCloseHL = 42;
simConfig.volAlpha = 0.6;
simConfig.corrHL1 = 42;
simConfig.corrHL2 = 520;
simConfig.corrAlpha = 0.4;
simConfig.corrShrinkFactor = 0.5;
end % fn
function simConfig = configureSimulation4countrySpecificRiskParity(countryUniv)
simConfig.countryUniv = countryUniv; 
simConfig.volTarget = 0.08;
switch countryUniv
    case 'G3'
        simConfig.countryHeader = {'us','xm','jp','na'}; 
        simConfig.countryWts = [0.4,0.325,0.275,1]; % note, 'na' = not applicable, meaning asset gets applied in full to all countries
        simConfig.assetClassHeader = {'equities','rates','comdty'};
        simConfig.assetClassRiskWts = [0.4,0.4,0.2];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','NK1 Index',...
                                 'JB1 Comdty','CO1 Comdty'};
        simConfig.assetCountry = {'us','us','xm','xm','jp','jp','na'};
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates','comdty'};
        simConfig.TC = [1, 1.25, 1, 1, 1, 0.9, 2];
    case 'G6' 
        simConfig.countryHeader = {'us','xm','jp','gb','au','ca','kr','na'}; 
        simConfig.countryWts = [0.18,0.165,0.155,0.125,0.125,0.125,0.125,0.5]; % note, 'na' = not applicable, meaning asset gets applied in full to all countries
        simConfig.assetClassHeader = {'equities','rates','comdty'};
        simConfig.assetClassRiskWts = [0.4,0.4,0.2];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','NK1 Index',...
                                 'JB1 Comdty','Z 1 Index','G 1 Comdty','XP1 Index','XM1 Comdty',...
                                 'PT1 Index','CN1 Comdty','CO1 Comdty','GC1 Comdty','KAA1 Comdty',...
                                 'KM1 Index'}; 
        simConfig.assetCountry = {'us','us','xm','xm','jp','jp','gb','gb','au','au','ca','ca','na','na','kr','kr'}; 
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates','equities',...
                                'rates','equities','rates','equities','rates','comdty','comdty','rates','equities'}; 
        simConfig.TC = [1,1.25,1,1,1,0.9,1,1,2,2,2,2,2,2,2,2];
    case 'G6xJ'
        simConfig.countryHeader = {'us','xm','gb','au','ca','na'}; 
        simConfig.countryWts = [0.25,0.21,0.18,0.18,0.18,1]; 
        simConfig.assetClassHeader = {'equities','rates','comdty'};
        simConfig.assetClassRiskWts = [0.4,0.4,0.2];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','Z 1 Index',...
                              'G 1 Comdty','XP1 Index','XM1 Index','PT1 Index','CN1 Comdty','CO1 Comdty'};
        simConfig.assetCountry = {'us','us','xm','xm','gb','gb','au','au','ca','ca','na'}; 
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates','equities',...
                                'rates','equities','rates','equities','rates','comdty'}; 
        simConfig.TC = [1,1.25,1,1,1,1,2,2,2,2,2];
    case 'DM' % same as G6 for now
        simConfig.countryHeader = {'us','xm','jp','gb','au','ca','na'}; 
        simConfig.countryWts = [0.2,0.18,0.17,0.15,0.15,0.15,1]; % note, 'na' = not applicable, meaning asset gets applied in full to all countries
        simConfig.assetClassHeader = {'equities','rates','comdty'};
        simConfig.assetClassRiskWts = [0.4,0.4,0.2];
        simConfig.assetHeader = {'ES1 Index','TY1 Comdty','VG1 Index','RX1 Comdty','NK1 Index',...
                                 'JB1 Comdty','Z 1 Index','G 1 Comdty','XP1 Index','XM1 Comdty',...
                                 'PT1 Index','CN1 Comdty','CO1 Comdty'}; 
        simConfig.assetCountry = {'us','us','xm','xm','jp','jp','gb','gb','au','au','ca','ca','na'}; 
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates','equities',...
                                'rates','equities','rates','equities','rates','comdty'}; 
        simConfig.TC = [1,1.25,1,1,1,0.9,1,1,2,2,2,2,2]; 
    case 'EM' 
        simConfig.countryHeader = {'cn','mx','kr','za','na'}; 
        simConfig.countryWts = [0.25,0.25,0.25,0.25,1]; % note, 'na' = not applicable, meaning asset gets applied in full to all countries
        simConfig.assetClassHeader = {'equities','rates','comdty'};
        simConfig.assetClassRiskWts = [0.4,0.4,0.2];
        simConfig.assetHeader = {'XU1 Index','TFT1 Comdty','IS1 Index','DW1 Comdty',...
                                 'KM1 Index','KAA1 Comdty','AI1 Index','RNA1 Comdty','CO1 Comdty'}; 
        simConfig.assetCountry = {'cn','cn','mx','mx','kr','kr','za','za','na'};
        simConfig.assetClass = {'equities','rates','equities','rates','equities','rates',...
                                'equities','rates','comdty'}; 
        simConfig.TC = [3,4,2,3,1,2,5,5,2];
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
simConfig.entryStartUtcs = containers.Map(generateTimes('header'),generateTimes('entrytime'));
simConfig.entryEndUtcs = containers.Map(generateTimes('header'),generateTimes('endtime'));

end % fn

function cellArrayOut = generateTimes(opt)
temp = [ ...
        [{'ES1 Index'},{0.611111111111111+0.0069},{0.621527777777778+0.0069}]; ...
        [{'PT1 Index'},{0.645833333333333+0.0069},{0.656250000000000+0.0069}]; ...
        [{'KM1 Index'},{00000000000000000+0.0069},{0.010416666666666+0.0069}]; ...
        [{'NK1 Index'},{0.645833333333333+0.0069},{0.656250000000000+0.0069}]; ...
        [{'XP1 Index'},{0.604166666666667+0.0069},{0.614583333333333+0.0069}]; ...
        [{'VG1 Index'},{0.416666666666667+0.0069},{0.427083333333333+0.0069}]; ...
        [{'CN1 Comdty'},{0.611111111111111+0.0069},{0.621527777777778+0.0069}]; ...
        [{'TY1 Comdty'},{0.611111111111111+0.0069},{0.621527777777778+0.0069}]; ...
        [{'BJ1 Comdty'},{0.364583333333333+0.0069},{0.375000000000000+0.0069}]; ...
        [{'KAA1 Comdty'},{0.020833333333333+0.0069},{0.031250000000000+0.0069}]; ...
        [{'XM1 Comdty'},{0.520833333333333+0.0069},{0.531250000000000+0.0069}]; ...
        [{'G 1 Comdty'},{0.416666666666667+0.0069},{0.427083333333333+0.0069}]; ...
        [{'RX1 Comdty'},{0.416666666666667+0.0069},{0.427083333333333+0.0069}]; ...
        [{'CO1 Comdty'},{0.347222222222222+0.0069},{0.357638888888889+0.0069}]; ...
        [{'GC1 Comdty'},{0.611111111111111+0.0069},{0.621527777777778+0.0069}]; ...
        [{'Z 1 Index'},{0.416666666666667+0.0069},{0.427083333333333+0.0069}]; ...
    ];
    switch opt
        case 'header'
            cellArrayOut = temp(:,1)';
        case 'entrytime'
            cellArrayOut = temp(:,2)';
        case 'endtime'
            cellArrayOut = temp(:,3)';
    end 
end
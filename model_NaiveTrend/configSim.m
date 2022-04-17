function config = configSim(dataPath,simPath,config)

% name the strategy
config.stratName = 'naiveTrend'; 
config.trendSignalOption = 1; % 1 if simple; 3 if "enhanced" mode for break-out

config.refreshInputData= false; % true to re-build the input data, otherwise splice from config.spliceBusdays days to end
config.spliceBusdays= 60; 
% define data subdirectories: 
config.signalOutputPath = dataPath; 
config.signalFunctionPath = simPath;  

% set date parameters if not set in config file and convert dates to NUMERIC
% MATLAB STANDARD:
if ~isfield(config,'dataStartDate') || isempty(config.dataStartDate)
   config.dataStartDate = datenum('04-Jan-1999');
elseif ischar(config.dataStartDate) || iscell(config.dataStartDate)
   config.dataStartDate = datenum(config.dataStartDate);  
end

if ~isfield(config,'simStartDate') || isempty(config.simStartDate)
   config.simStartDate = datenum('03-Jan-2000');
elseif ischar(config.simStartDate) || iscell(config.simStartDate)
   config.simStartDate = datenum(config.simStartDate); 
end

if ~isfield(config,'simEndDate') || isempty(config.simEndDate)
  config.simEndDate = today(); 
elseif ischar(config.simEndDate) || iscell(config.simEndDate)
   config.simEndDate = datenum(config.simEndDate);  
end

config.annBusDays = 260; 
config.mnthlyBusDays = 21;

config.mma.rates.fParam.a = [8,9,10,12,15,16,18,20,21,24,28];%[6,8,9,10,12,15,16,18,20,21,24,28];%6:2:12;
config.mma.rates.fParam.b = [8,9,10,12,14,15,16,18,20,21,24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];%[15,21,30,42,55]; % [5,8,12,18,32,52];
config.mma.rates.fParam.L2Min=[280,280,150,180,225,240,270,280,280,280,280];%repmat (280 , 1, 12 );
config.mma.rates.fParam.L2Max=[400,repmat(1000,1,10)];%repmat (1000 , 1, 12 );
config.mma.rates.fParam.volHL = [21,63,260];
config.mma.rates.fParam.volThresh= [0.0, 0.75];
config.mma.rates.fParam.subStrategyNum = 1;

config.mma.equityDM.fParam.a = [5, 6,8,9,10,12,15,16,18,20,21,24,28];%6:3:15; % 6:2:20;
config.mma.equityDM.fParam.b = [8,9,10,12,14,15,16,18,20,21,24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];%[25,30,35,40,50,60]; % [20,25,30,35,40,50,60]; 
config.mma.equityDM.fParam.L2Min= [210,210,210,210,210,140,140,140,140,140,140,140,140];
config.mma.equityDM.fParam.L2Max= repmat (500 , 1, 13 );
config.mma.equityDM.fParam.volHL = [21,63,260];
config.mma.equityDM.fParam.volThresh= [0.0, 0.75];
config.mma.equityDM.fParam.subStrategyNum = 2;

config.mma.equityEM.fParam.a = [5,6,8,9,10,12,15,16,18,20,21,24,28];%9:3:21; % [5,10,15,20,30];
config.mma.equityEM.fParam.b =[8,9,10,12,14,15,16,18,20,21,24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];% 24:3:39;
config.mma.equityEM.fParam.L2Min= [252,252, 260,260,260, 252, 252, 252, 252,240,240,240, 224 ];
config.mma.equityEM.fParam.L2Max= repmat (600 , 1, 13 );
config.mma.equityEM.fParam.volHL = [21,63,260];
config.mma.equityEM.fParam.volThresh= [0.0, 0.75];
config.mma.equityEM.fParam.subStrategyNum = 3;

config.mma.ccyDM.fParam.a = [5,6,8,9,10,12,15,16,18,20,21,24,28];%9:3:21; %[5,10,15,20];
config.mma.ccyDM.fParam.b = [8,9,10,12,14,15,16,18,20,21,24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];%24:3:39; %20:2:36;
config.mma.ccyDM.fParam.L2Min= repmat (120 , 1, 13 );
config.mma.ccyDM.fParam.L2Max=repmat (720 , 1, 13 );
config.mma.ccyDM.fParam.volHL = [21,63,260];
config.mma.ccyDM.fParam.volThresh = [0.0, 0.75];
config.mma.ccyDM.fParam.subStrategyNum = 4;

config.mma.ccyEM.fParam.a = [5,6,8,9,10,12,15,16,18,20,21,24,28];%9:3:18; %[5,10,15,20];
config.mma.ccyEM.fParam.b = [8,9,10,12,14,15,16,18,20,21,24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];%15:3:36; % 10:3:30;
config.mma.ccyEM.fParam.L2Min= repmat (100 , 1, 13 );
config.mma.ccyEM.fParam.L2Max=repmat (300 , 1, 13 );
config.mma.ccyEM.fParam.volHL = [21,63,260];
config.mma.ccyEM.fParam.volThresh= [0.0, 0.75];
config.mma.ccyEM.fParam.subStrategyNum = 5;

config.mma.comdtyEnergy.fParam.a = [5,6,8,9,10,12,15,16,18,20,21,24,28];%9:3:18;% 5:5:20;s
config.mma.comdtyEnergy.fParam.b =[8,9,10,12,14,15,16,18,20,21,24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];% 10:2:18; % 8:2:16;
config.mma.comdtyEnergy.fParam.L2Min= repmat (135 , 1, 13 );
config.mma.comdtyEnergy.fParam.L2Max=repmat (378 , 1, 13 );
config.mma.comdtyEnergy.fParam.volHL = [21,63,260];
config.mma.comdtyEnergy.fParam.volThresh= [0.0, 0.75];
config.mma.comdtyEnergy.fParam.subStrategyNum = 6;

config.mma.comdtyMetal.fParam.a = [8,9,10,12,15,16,18,20,21,24,28];%8:4:28; %5:5:25;
config.mma.comdtyMetal.fParam.b = [14,15,16,18,20,21,24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];%9:3:27; %7:3:25;
config.mma.comdtyMetal.fParam.L2Min= repmat (312 , 1, 11 );
config.mma.comdtyMetal.fParam.L2Max=repmat (896 , 1, 11 );
config.mma.comdtyMetal.fParam.volHL = [21,63,260];
config.mma.comdtyMetal.fParam.volThresh= [0.0,0.75];
config.mma.comdtyMetal.fParam.subStrategyNum = 7;

config.mma.comdtyAgs.fParam.a =[8,9,10,12,15,16,18,20,21,24,28];% 8:4:24; %2:3:20;
config.mma.comdtyAgs.fParam.b = [24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];%12:3:30;
config.mma.comdtyAgs.fParam.L2Min= repmat (480 , 1, 11 );
config.mma.comdtyAgs.fParam.L2Max= repmat (1200 , 1, 11 );
config.mma.comdtyAgs.fParam.volHL = [21,63,260];
config.mma.comdtyAgs.fParam.volThresh= [0.0,0.75];
config.mma.comdtyAgs.fParam.subStrategyNum = 8;

config.mma.shortRates.fParam.a = [8,9,10,12,15,16,18,20,21,24,28];%6:3:15; %4:2:12;
config.mma.shortRates.fParam.b = [8,9,10,12,14,15,16,18,20,21,24,25,27,30,32,33,35,36,39,40,42,50,52,55,60];%[8,12,18,32,52]; %[5,8,12,18,32,52];
config.mma.shortRates.fParam.L2Min= [288,288,150,180,225,240,270,288,288,288,288];%repmat (288 , 1, 11 );
config.mma.shortRates.fParam.L2Max= [400,repmat(1000,1,10)];%repmat (1000 , 1, 11 );
config.mma.shortRates.fParam.volHL = [21,63,260];
config.mma.shortRates.fParam.volThresh= [0.0, 0.75];
config.mma.shortRates.fParam.subStrategyNum = 9;

config.mmo.rates.fParam.a =[64,97,130,195,260,390];%[64,97,130,195,260,390,520]; 
config.mmo.rates.fParam.b = 2;
config.mmo.rates.fParam.volHL = [21,63,260];
config.mmo.rates.fParam.volThresh= [0.0, 0.75];
config.mmo.rates.fParam.subStrategyNum = 1;
config.mmo.rates.fParam.nearZeroOption = true;

config.mmo.equityDM.fParam.a = [ 64, 97,  130, 195, 260, 390];%[21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]
config.mmo.equityDM.fParam.b = 2;
config.mmo.equityDM.fParam.volHL = [21,63,260];
config.mmo.equityDM.fParam.volThresh= [0.0, 0.75];
config.mmo.equityDM.fParam.subStrategyNum = 2;
config.mmo.equityDM.fParam.nearZeroOption = true;

config.mmo.equityEM.fParam.a =[  43, 64, 97,  130, 195, 260 ];%[21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]
config.mmo.equityEM.fParam.b = 2;
config.mmo.equityEM.fParam.volHL = [21,63,260];
config.mmo.equityEM.fParam.volThresh= [0.0, 0.75];
config.mmo.equityEM.fParam.subStrategyNum = 3;
config.mmo.equityEM.fParam.nearZeroOption = true;

config.mmo.ccyDM.fParam.a = [  64, 97,  130, 195, 260, 390,  520];%[21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]
config.mmo.ccyDM.fParam.b = 2;
config.mmo.ccyDM.fParam.volHL = [21,63,260];
config.mmo.ccyDM.fParam.volThresh= [0.0, 0.75];
config.mmo.ccyDM.fParam.subStrategyNum = 4;
config.mmo.ccyDM.fParam.nearZeroOption = true;

config.mmo.ccyEM.fParam.a = [  43, 64, 97,  130, 195];%[21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]
config.mmo.ccyEM.fParam.b = 2;
config.mmo.ccyEM.fParam.volHL = [21,63,260];
config.mmo.ccyEM.fParam.volThresh= [0.0, 0.75];
config.mmo.ccyEM.fParam.subStrategyNum = 5;
config.mmo.ccyEM.fParam.nearZeroOption = true;

config.mmo.comdtyEnergy.fParam.a = [ 43, 64, 97,  130, 195, 260, 390,  520];%[21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]
config.mmo.comdtyEnergy.fParam.b = 2;
config.mmo.comdtyEnergy.fParam.volHL = [21,63,260];
config.mmo.comdtyEnergy.fParam.volThresh= [0.0, 0.75];
config.mmo.comdtyEnergy.fParam.subStrategyNum = 6;
config.mmo.comdtyEnergy.fParam.nearZeroOption = true;

config.mmo.comdtyMetal.fParam.a = [ 43, 64, 97,  130, 195, 260, 390,  520];%[21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]
config.mmo.comdtyMetal.fParam.b = 2;
config.mmo.comdtyMetal.fParam.volHL = [21,63,260];
config.mmo.comdtyMetal.fParam.volThresh= [0.0, 0.75];
config.mmo.comdtyMetal.fParam.subStrategyNum = 7;
config.mmo.comdtyMetal.fParam.nearZeroOption = true;

config.mmo.comdtyAgs.fParam.a = [];%[21,64,128,256]; %[21,64,256];
config.mmo.comdtyAgs.fParam.b = 2;
config.mmo.comdtyAgs.fParam.volHL = [21,63,260];
config.mmo.comdtyAgs.fParam.volThresh= [0.0, 0.75];
config.mmo.comdtyAgs.fParam.subStrategyNum = 8;
config.mmo.comdtyAgs.fParam.nearZeroOption = true;

config.mmo.shortRates.fParam.a = [43,64,97,130,195,260,390];%[43,64,97,130,195,260,390,520];%[21,32,43,64,97,130,195,260,390,520]
config.mmo.shortRates.fParam.b = 2;
config.mmo.shortRates.fParam.volHL = [21,63,260];
config.mmo.shortRates.fParam.volThresh= [0.0, 0.75];
config.mmo.shortRates.fParam.subStrategyNum = 9;
config.mmo.shortRates.fParam.nearZeroOption = true;

config.mbo.rates.fParam.a =[60:5:85,190:10:320];% 190:10:320;%50:5:200; %10:5:180;
config.mbo.rates.fParam.b = [21, 126, 0.5];
config.mbo.rates.fParam.volHL = [21,63,260];
config.mbo.rates.fParam.volThresh= [0.0, 0.75];

config.mbo.equitydm.fParam.a = [85:5:200, 210:10:300]; %100:10:400;
config.mbo.equitydm.fParam.b = [21, 126, 0.5];
config.mbo.equitydm.fParam.volHL = [21,63,260];
config.mbo.equitydm.fParam.volThresh= [0.0, 0.75];

config.mbo.equityem.fParam.a = [115:5:200, 210:10:300]; % 50:5:200; 100
config.mbo.equityem.fParam.b = [21, 126, 0.5];
config.mbo.equityem.fParam.volHL = [21,63,260];
config.mbo.equityem.fParam.volThresh= [0.0, 0.75];

config.mbo.ccydm.fParam.a = [100:5:200, 210,220,230]; %100:5:200;
config.mbo.ccydm.fParam.b = [21, 126, 0.5];
config.mbo.ccydm.fParam.volHL = [21,63,260];
config.mbo.ccydm.fParam.volThresh= [0.0, 0.75];

config.mbo.ccyem.fParam.a =  [100:5:200, 210,220,230];%100:5:200;
config.mbo.ccyem.fParam.b = [21, 126, 0.5];
config.mbo.ccyem.fParam.volHL = [21,63,260];
config.mbo.ccyem.fParam.volThresh= [0.0, 0.75];

config.mbo.comdtyEnergy.fParam.a =  [75:5:200, 210:10:260]; %50:5:200;
config.mbo.comdtyEnergy.fParam.b = [21, 126, 0.5];
config.mbo.comdtyEnergy.fParam.volHL = [21,63,260];
config.mbo.comdtyEnergy.fParam.volThresh= [0.0, 0.75];

config.mbo.comdtyMetal.fParam.a =  [90:5:200, 210:10:320]; %50:5:200;
config.mbo.comdtyMetal.fParam.b = [21,126,0.5];
config.mbo.comdtyMetal.fParam.volHL = [21,63,260];
config.mbo.comdtyMetal.fParam.volThresh= [0.0, 0.75];

config.mbo.comdtyAgs.fParam.a = [];%50:5:150;
config.mbo.comdtyAgs.fParam.b = [21, 126, 0.5];
config.mbo.comdtyAgs.fParam.volHL = [21,63,260];
config.mbo.comdtyAgs.fParam.volThresh= [0.0, 0.75];

config.mbo.shortRates.fParam.a =[70:5:85,130:5:200,210:10:320];%[130:5:200,210:10:320];%50:5:200;
config.mbo.shortRates.fParam.b = [21, 126, 0.5];
config.mbo.shortRates.fParam.volHL = [21,63,260];
config.mbo.shortRates.fParam.volThresh= [0.0, 0.75];


%Tstat config [21,64,128,256]
config.tstat.spliceOption = true ; % true to splice tstat structure from config.tstat.spliceBusdays days to end
config.tstat.spliceBusdays= 21; 
config.tstat.rates.fParam.lookbacks =[43,64,97,130,195,260,390,520]; %[64,97,130,195,260,390,520]; %[21,32,43,64,97,130,195,260,390,520]; 
config.tstat.rates.fParam.squashLevelTstat = [0.54, 1.78];
config.tstat.rates.fParam.squashLevelSignal = 0.2 ;
config.tstat.rates.fParam.fetchTstatOption= false ;
config.tstat.rates.fParam.subStrategyNum = 1;

config.tstat.equityDM.fParam.lookbacks = [ 64, 97,  130, 195, 260, 390 ]; % [ 21 , 32, 43, 64, 97,  130, 195, 260, 390,  520];  
config.tstat.equityDM.fParam.squashLevelTstat = [0.51, 1.35];
config.tstat.equityDM.fParam.squashLevelSignal = 0.2 ;
config.tstat.equityDM.fParam.fetchTstatOption= false ;
config.tstat.equityDM.fParam.subStrategyNum = 2;

config.tstat.equityEM.fParam.lookbacks =[  43, 64, 97,  130, 195, 260]; % [ 21 , 32, 43, 64, 97,  130, 195, 260, 390,  520];    
config.tstat.equityEM.fParam.squashLevelTstat = [0.51, 1.35];
config.tstat.equityEM.fParam.squashLevelSignal = 0.2 ;
config.tstat.equityEM.fParam.fetchTstatOption= false ;
config.tstat.equityEM.fParam.subStrategyNum = 3;

config.tstat.ccyDM.fParam.lookbacks = [  64, 97,  130, 195, 260, 390,  520]; % [ 21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]; 
config.tstat.ccyDM.fParam.squashLevelTstat = [0.51, 1.35];
config.tstat.ccyDM.fParam.squashLevelSignal = 0.2 ;
config.tstat.ccyDM.fParam.fetchTstatOption= false ;
config.tstat.ccyDM.fParam.subStrategyNum = 4;

config.tstat.ccyEM.fParam.lookbacks = [ 32, 64, 97,  130, 195]; % [ 21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]; 
config.tstat.ccyEM.fParam.squashLevelTstat = [0.51, 1.35];
config.tstat.ccyEM.fParam.squashLevelSignal = 0.2 ;
config.tstat.ccyEM.fParam.fetchTstatOption= false ;
config.tstat.ccyEM.fParam.subStrategyNum = 5;

config.tstat.comdtyEnergy.fParam.lookbacks = [ 43, 64, 97,  130, 195, 260]; % [ 21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]; 
config.tstat.comdtyEnergy.fParam.squashLevelTstat = [0.51, 1.35];
config.tstat.comdtyEnergy.fParam.squashLevelSignal = 0.2 ;
config.tstat.comdtyEnergy.fParam.fetchTstatOption= false ;
config.tstat.comdtyEnergy.fParam.subStrategyNum = 6;

config.tstat.comdtyMetal.fParam.lookbacks = [  43, 64, 97,  130, 195, 260, 390,  520]; % [ 21 , 32, 43, 64, 97,  130, 195, 260, 390,  520]; 
config.tstat.comdtyMetal.fParam.squashLevelTstat = [0.51, 1.35];
config.tstat.comdtyMetal.fParam.squashLevelSignal = 0.2 ;
config.tstat.comdtyMetal.fParam.fetchTstatOption= false ;
config.tstat.comdtyMetal.fParam.subStrategyNum = 7;

config.tstat.comdtyAgs.fParam.lookbacks = []; % [ 21 , 32, 43, 64, 97,  130, 195, 260, 390,  520];  
config.tstat.comdtyAgs.fParam.squashLevelTstat = [0.60, 1.35];
config.tstat.comdtyAgs.fParam.squashLevelSignal = 0.2 ;
config.tstat.comdtyAgs.fParam.fetchTstatOption= false ;
config.tstat.comdtyAgs.fParam.subStrategyNum = 8;

config.tstat.shortRates.fParam.lookbacks = [ 43, 64, 97,  130, 195, 260, 390,  520]; % [ 21 , 32, 43, 64, 97,  130, 195, 260, 390,  520];  
config.tstat.shortRates.fParam.squashLevelTstat = [0.54, 1.78];
config.tstat.shortRates.fParam.squashLevelSignal = 0.2 ;
config.tstat.shortRates.fParam.fetchTstatOption= false ;
config.tstat.shortRates.fParam.subStrategyNum = 9;


% asset return type used:
config.assetReturnType = 'London';

end % fn

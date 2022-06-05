function RiskAssetAllocation2_VALIC(cfg,params)

assetView = cfg.assetView;
filePath= cfg.filePath;
rebalPeriods = cfg.rebalPeriods;
utilityFunction = cfg.utilityFunction;
utilityParam = cfg.utilityParam;
longOnly = cfg.longOnly;
riskType = cfg.riskType;
client = cfg.client;

liquidationLimit = params.liquidationLimit;
RBCLimit = params.RBCLimit;
ICLimit = params.ICLimit;
illiquidLimit = params.illiquidLimit;
varianceTarget = params.varianceTarget;
capCons.opt = params.capCons;
shrinkageRP = params.shrinkageRP;
allowLeverage = false; %#ok<NASGU>
gamma = utilityParam;

%Load asset data
switch riskType 
   case 'Accounting'
       assetDataTable = readtable(filePath+"\\QuarterlyAssetData5c.csv");
       t0 = find(assetDataTable.Date == datetime('03/31/2004'));
       if ~isempty(t0)
          assetDataTable = assetDataTable(t0:end,:);
       end 
       dataPeriods = 3;
       rebalPeriods = 3;
    case 'Intrinsic'
       assetDataTable = readtable(filePath+"\\QuarterlyUnsmoothedAssetData5c.csv");
       t0 = find(assetDataTable.Date == datetime('03/31/2004'));
       if ~isempty(t0)
          assetDataTable = assetDataTable(t0:end,:);
       end 
       dataPeriods = 3;
       rebalPeriods = 3;
end
disp(assetDataTable.Properties.VariableNames);
assetClassNames = assetDataTable.Properties.VariableNames(2:end); %#ok<NASGU>
nPeriods = size(assetDataTable{:,1},1); %#ok<NASGU>
dates = assetDataTable.Date; %#ok<NASGU>

%Load factor data
switch riskType 
    case 'Accounting'
        factorDataTable = readtable(filePath + "\\QuarterlyFactorData.csv");
        fDataPeriods = 3; 
    case 'Intrinsic'
        factorDataTable = readtable(filePath + "\\QuarterlyFactorData.csv");
        fDataPeriods = 3; 
    otherwise
        factorDataTable = readtable(filePath + "\\MonthlyFactorData.csv");
        fDataPeriods = 1; 
end
factorNames = factorDataTable.Properties.VariableNames(2:end);
nFactors = size(factorNames,2); %#ok<NASGU>
factorReturns = factorDataTable{:,factorNames};
t0 = find(factorDataTable.Date>=assetDataTable.Date(1),1);
factorReturns = factorReturns(t0:end,:); 

keySet = {'GlobalEquity','PvtEqBO','DirEqty','PvtEqRE','PvtEqFT','AbsRtn2'};
factorKeySet = {'Equity','Rates','Kredit','Mtg'};

%Extract a subset of asset data
if assetView == "AIG"
    % from M:\PublicEquityQuant\AssetAllocation\SAA_analysis\VALIC_retirementCarveOut\VALICretirementCarveOut_v2.xlsx
    % E[rtn]            Accounting	Intrinsic
    % 'GlobalEquity'	0.0645      0.0645 
    % 'PvtEqBO'         0.0995      0.1005 
    % 'DirEqty'         0.1300      0.1300 
    % 'PvtEqRE'         0.0800      0.0800 
    % 'PvtEqFT'         0.0635      0.0595 
    % 'AbsRtn2'         0.065       0.065  

    % 'GlobalEquity'	0.1700      0.1700 
    % 'PvtEqBO'         0.1292      0.2066 
    % 'DirEqty'         0.1600      0.2250 
    % 'PvtEqRE'         0.0750      0.1530 
    % 'PvtEqFT'         0.1000      0.1400 
    % 'AbsRtn2'         0.0600      0.0600 

    % FACTORS:          E[rtn]      E[vol]
    % Equity            0.0645      0.1700 
    % Rates             0.0200      0.0722 
    % Credit            0.0197      0.0664 
    % Mtg               0.0176      0.0668 

    F = [[ 0.0560 	 0.1700 ];
         [ 0.0200 	 0.0722 ];
         [ 0.0197 	 0.0664 ];
         [ 0.0176 	 0.0668 ]];
     
    factorERset = F(:,1)'; %#ok<NASGU> % annual units here
    factorVolSet =F(:,2)';
    
    %       Acctng   Intrnsc
    Ar = [[ 0.0560 	 0.0560 ];
          [ 0.0995 	 0.1005 ];
          [ 0.1300 	 0.1300 ];
          [ 0.0800 	 0.0800 ];
          [ 0.0686 	 0.0686 ];
          [ 0.0704	 0.0704 ]]; 
 
    Av = [[ 0.1700 	 0.1700 ];
          [ 0.13 	 0.205  ];
          [ 0.1600 	 0.2250 ];
          [ 0.0750 	 0.1530 ];
          [ 0.0390	 0.0840 ];
          [ 0.0570 	 0.0570 ]];

      
    switch riskType 
        case 'Accounting'
           erSet = Ar(:,1)';
           volSet = Av(:,1)';
        case 'Intrinsic'
           erSet = Ar(:,2)';
           volSet = Av(:,2)';
    end 
end
assetReturns = assetDataTable{:,keySet};
assetClassNames = keySet;
nAssets = size(assetClassNames,2);

%Estimate asset co-moments
iA = mapStrings(keySet,assetClassNames);
iF = mapStrings(factorKeySet,factorNames); 
if strcmpi(riskType,'accounting')
   iPE = find(strcmp(keySet,'PvtEqBO'));
   iDE = find(strcmp(keySet,'DirEqty'));
   assetReturns(2:end,iPE) = assetReturns(1:end-1,iPE);
   assetReturns(2:end,iDE) = assetReturns(1:end-1,iDE);
   assetReturns = assetReturns(2:end,:); 
   factorReturns = factorReturns(2:end,:);
end 
assetMu = mean(assetReturns,1)';

if capCons.opt % set capacity constraint params if option is true
   lb = zeros(length(keySet),1); 
   ub = ones(length(keySet),1); 
   iEQ = find(strcmp(keySet,'GlobalEquity')); %#ok<NASGU>
   iPE = find(strcmp(keySet,'PvtEqBO')); %#ok<NASGU>
   iDE = find(strcmp(keySet,'DirEqty'));
   iRE = find(strcmp(keySet,'PvtEqRE')); %#ok<NASGU>
   iFT = find(strcmp(keySet,'PvtEqFT'));
   iAR = find(strcmp(keySet,'AbsRtn2')); %#ok<NASGU>
%                               Per_1  Per_2   Per_3
%   ub(iEQ) = 1.0;              667%   667%    667%   
%   ub(iPE) = 1.0;              100%   100%    100%   
   ub(iDE) = 0.33; %#ok<FNDSB>  0.33   0.33    0.33 
   ub(iFT) = 0.5;  %#ok<FNDSB>  0.0    0.5     0.17 
%   ub(iRE) = 1.0;              333%   333%    333%   
%   ub(iAR) = 1.0;              100%   100%    100%   
   capCons.ub = ub; 
   capCons.lb = lb; 
end

assetCov = RobustCovarianceEstimate(assetReturns(:,iA),factorReturns(:,iF),"FactorView",sqrt(fDataPeriods/12)*factorVolSet');
assetCos = RobustCoskewnessEstimate(assetReturns(:,iA),factorReturns(:,iF),"Factor");
assetCok = RobustCokurtosisEstimate(assetReturns(:,iA),factorReturns(:,iF),"Factor");

%Overwrite ARP and HF expected returns and vol

%Match asset views before adjusting
if(size(erSet,2) > 1)
    erViewMap = containers.Map(keySet,erSet);
    volViewMap = containers.Map(keySet,volSet);
    
    erView = assetMu*12/dataPeriods;
    volView = diag(assetCov).^0.5*sqrt(12/dataPeriods);
    
    for i=1:nAssets
        if isKey(erViewMap,assetClassNames(1,i))
            erView(i,1) = erViewMap(string(assetClassNames(1,i)));
            volView(i,1) = volViewMap(string(assetClassNames(1,i)));
        end
    end
   
    %All moments will be consistent in terms of frequency
    [assetMu,assetCov,assetCos,assetCok,varianceTarget] = AdjustAssetView(dataPeriods,assetMu,assetCov,assetCos,assetCok,erView,volView,varianceTarget);
end

assetVar = zeros(nAssets,1);
assetSkew = zeros(nAssets,1);
assetKurt = zeros(nAssets,1);
for i=1:nAssets
    assetVar(i,1) = assetCov(i,i);
    assetSkew(i,1) = assetCos(i,(i-1)*nAssets+i);
    assetKurt(i,1) = assetCok(i,((i-1)*nAssets+i-1)*nAssets+i);
end

%Liquidation
assetLiq=zeros(nAssets,1);
assetRBC=zeros(nAssets,1);
assetIC=zeros(nAssets,1);
assetIlliquid=zeros(nAssets,1);
for i=1:nAssets
    switch string(assetClassNames(iA(i)))
        case char('GlobalEquity')
            assetLiq(i,1)=0.019;
%            assetRBC(i,1)=(client=="L&R")*0.6246+(client=="GI")*0.0549;
            assetRBC(i,1)=(client=="L&R")*0.57+(client=="GI")*0.0549;
            assetIC(i,1)=0.44;
            assetIlliquid(i,1) = 0;
        case char('PvtEqBO')  
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.38+(client=="GI")*0.0732;
            assetIC(i,1)=0.37;
            assetIlliquid(i,1) = 1;
        case char('DirEqty')
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.38+(client=="GI")*0.0732;
            assetIC(i,1)=0.37;
            assetIlliquid(i,1) = 1;
        case char('PvtEqRE')
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.714+(client=="GI")*0.04;
            assetIC(i,1)=0.43;
            assetIlliquid(i,1) = 1;
        case char('PvtEqFT')
            assetLiq(i,1)=8.0;
            assetRBC(i,1)=(client=="L&R")*0.237+(client=="GI")*0.04;
            assetIC(i,1)=0.39;
            assetIlliquid(i,1) = 1;
        case char('AbsRtn2')
            assetLiq(i,1)=0.04;
            assetRBC(i,1)=(client=="L&R")*0.535+(client=="GI")*0.0732;
            assetIC(i,1)=0.278;
            assetIlliquid(i,1) = 0;
        otherwise
    end
end

%Asset allocation
figure(1);
clf(1);
hold on;

% rebalPeriods  = rebalPeriods/dataPeriods; % Logic based on poor time unit convention; now d

% Optimal allocation
% Utility function case:
a = sqrt((12/rebalPeriods)*varianceTarget);
a = round(a,3); 
volGrid = a +(1:5)*0.01-0.03;
varGrid = volGrid.^2/(12/rebalPeriods);
outputArray2 = zeros(length(varGrid),length(assetMu));
outputArray3 = zeros(length(varGrid),10);
II = length(varGrid);

% Mean Variance case:
% lambdaGrid = gamma + (1:5)*0.1 - 0.3;
% outputArray2 = zeros(length(lambdaGrid),length(assetMu));
% outputArray3 = zeros(length(lambdaGrid),10);
% II = length(lambdaGrid);

for i = 1:II
   % Mean Variance case:
   % gamma = lambdaGrid(i); 
   % varTarg = params.varianceTarget;
   w = ExpectedUtilityOptimization(utilityFunction,gamma,shrinkageRP,assetMu,assetCov,assetCos,assetCok,rebalPeriods,longOnly,...
                                   assetLiq,assetRBC,assetIC,assetIlliquid,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,...
                                   varGrid(i),capCons);
%                                   varTarg,capCons);

   varp = (w'*assetCov*w)*(12/rebalPeriods); % annualize
   volp = sqrt(varp); 
   mup = (w'*assetMu)*(12/rebalPeriods); % annualize
   annSR = mup/volp; 
   avgLiqHzn = w'*assetLiq; 
   avgRBCcharge = w'*assetRBC; 
   avgICcharge = w'*assetIC; 
   illiquidsWt = w'*assetIlliquid; 
   outputArray2(i,:) = w'; 
   outputArray3(i,:) = [mup,volp,annSR,shrinkageRP,varGrid(i),gamma,avgLiqHzn,avgRBCcharge,avgICcharge,illiquidsWt]; 
end
w2 = outputArray2(2,:)';
varp2 = (w2'*assetCov*w2)*(12/rebalPeriods); % annualize
volp2 = sqrt(varp2); 
mup2 = (w2'*assetMu)*(12/rebalPeriods); % annualize
w3 = outputArray2(3,:)';
varp3 = (w3'*assetCov*w3)*(12/rebalPeriods); % annualize
volp3 = sqrt(varp3); 
mup3 = (w3'*assetMu)*(12/rebalPeriods); % annualize
w4 = outputArray2(4,:)';
varp4 = (w4'*assetCov*w4)*(12/rebalPeriods); % annualize
volp4 = sqrt(varp4); 
mup4 = (w4'*assetMu)*(12/rebalPeriods); % annualize

if (liquidationLimit > 0) || (RBCLimit > 0) || (ICLimit > 0) || (illiquidLimit > 0)
   plot(volp2,mup2,'bs','DisplayName','Opt Constrained Prtflio 1'); 
   plot(volp3,mup3,'bs','DisplayName','Opt Constrained Prtflio 2'); 
   plot(volp4,mup4,'bs','DisplayName','Opt Constrained Prtflio 3'); 
else
   plot(volp,mup,'bs','DisplayName','Optimal Portfolio');
end 
% annSR = 12*mup/(sqrt(12)*volp); 

%Current allocation
curWeights = [0.074, 0.277, 0.154, 0.263, 0.029, 0.204]; % [0.1, 0.375, 0.21, 0.04, 0.275]; % 0.100461772	0.375727026	0.209030985	0.038774719	0.276005499


curMup = curWeights*assetMu*(12/rebalPeriods);
curVolp = sqrt(curWeights*assetCov*curWeights'*(12/rebalPeriods));
curSRp = curMup/curVolp; %#ok<NASGU>
plot(curVolp,curMup,'cd','DisplayName','Current Portfolio');
    
%Efficient frontier
w0=GlobalMinimumVariance(assetCov,true);
w1=GlobalMaximumVariance(assetCov,true);
minVar=(w0'*assetCov*w0)*(12/rebalPeriods); %#ok<NASGU>
maxVar=(w1'*assetCov*w1)*(12/rebalPeriods); %#ok<NASGU> 

minRet = min(assetMu); % not annualized
maxRet = max(assetMu); % not annualized

returns = sort(unique([minRet:(maxRet-minRet)/40:maxRet assetMu' mup/(12/rebalPeriods)])*(12/rebalPeriods)); % rtns annualized, assetMu and Cov NOT...
vars = returns;
for i=1:size(returns,2)
    w=MinimumVariance(assetMu,assetCov,(12/rebalPeriods),returns(1,i),true);
    vars(1,i)= (w'*assetCov*w)*(12/rebalPeriods);
end 

% vars = sort(unique([minVar:(maxVar-minVar)/40:maxVar (diag(assetCov)*rebalPeriods)' varp]));
% returns = vars;
% for i=1:size(vars)
%    w = ExpectedUtilityOptimization(utilityFunction,gamma,shrinkageRP,assetMu,assetCov,assetCos,assetCok,rebalPeriods,longOnly,assetLiq,assetRBC,assetIC,assetIlliquid,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget);
%    returns(1,i) = w*assetMu*(12/rebalPeriods); 
% end

vols = sqrt(vars); 
plot(vols,returns,'DisplayName','MV Efficient Frontier');

%Risk parity
w=RiskParity(assetCov,longOnly);

varp = (w'*assetCov*w)*(12/rebalPeriods);
volp = sqrt(varp);
mup = (w'*assetMu)*(12/rebalPeriods);
plot(volp,mup,'g*','DisplayName','Risk Parity');

plot(sqrt(assetVar*(12/rebalPeriods)),assetMu*(12/rebalPeriods),'r+','DisplayName','Asset View');
dv = mean(sqrt(assetVar*(12/rebalPeriods)))*0.05;
for i=1:nAssets
   text(sqrt(assetVar(i)*(12/rebalPeriods))+dv,assetMu(i)*(12/rebalPeriods),assetClassNames(i));
end

legend('Location','southeast');
hold off

title(['Portfolio Analysis ',client,', ',riskType,' Risk'])
xlabel('Portfolio Vol'); ylabel('Portfolio E[xsRtn]');
grid
correl = assetCov./((diag(assetCov).^.5).*(diag(assetCov).^.5));
outputArray4 = [4*assetMu./diag(4*assetCov).^.5,correl]; %#ok<NASGU>

% outputArray2(i,:) = w'; 
% outputArray3(i,:) = [mup,volp,annSR,shrinkageRP,varGrid(i),gamma,avgLiqHzn,avgRBCcharge,avgICcharge,illiquidsWt]; 
xx = [outputArray3(:,[1:3,7:8]),outputArray2]; 
xx1 = outputArray2(2:4,:)';
xx2 = outputArray3(2:4,[1:3,8:9])';
disp(xx)
disp(xx1)
disp(xx2)

end 

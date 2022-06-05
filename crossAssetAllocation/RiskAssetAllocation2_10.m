%Function Arguments:
%
%
function RiskAssetAllocation2_10(assetView,filePath,rebalPeriods,utilityFunction,utilityParam,shrinkageRP,...
                              longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,capCons,riskType,client)

allowLeverage = false; %#ok<NASGU>
gamma = utilityParam;
if nargin < 15 || isempty(client)
   client = 'L&R'; % 'L&R' or 'GI'
end
if nargin < 14 || isempty(riskType)
   riskType = 'Accounting'; % 'accounting' or 'intrinsic'
end
if nargin < 13 || isempty(capCons)
   capCons.opt = false;
end

%Load asset data
switch riskType 
   case 'Accounting'
       assetDataTable = readtable(filePath+"\\QuarterlyAssetData12.csv");
%       assetDataTable = readtable(filePath+"\\QuarterlyAssetData10.csv");
       t0 = find(assetDataTable.Date == datetime('03/31/2004'));
       if ~isempty(t0)
          assetDataTable = assetDataTable(t0:end,:);
       end 
       dataPeriods = 3;
       rebalPeriods = 3;
    case 'Intrinsic'
       assetDataTable = readtable(filePath+"\\QuarterlyUnsmoothedAssetData10.csv");
       t0 = find(assetDataTable.Date == datetime('03/31/2004'));
       if ~isempty(t0)
          assetDataTable = assetDataTable(t0:end,:);
       end 
       dataPeriods = 3;
       rebalPeriods = 3;
    otherwise
       assetDataTable = readtable(filePath+"\\MonthlyAssetData.csv");
       dataPeriods = 1;
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

keySet = {'PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFBeta0','ARP','AbsRtn','MSR'};
%keySet = {'GlobalEquity','PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFBeta0','ARP','AbsRtn'};
%erSet =[];
% if assetView == "AIG"
%     keySet = {'GlobalEquity','PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFAlpha1','ARP','HFAlpha2'};
% end

%Extract a subset of asset data
assetReturns = assetDataTable{:,keySet};
assetClassNames = keySet;
nAssets = size(assetClassNames,2);

%View overwrite
erSet =[];
%Asset view
if assetView == "JPM"
    %JPM view
    erSet = [0.10362,0.098,0.07324,0.067,0.07304,0.0645,0.069,0.03954,0.048,0.03276,0.07349];
    volSet = [0.194,0.118,0.14125,0.1046,0.0822,0.0832,0.1071,0.0737,0.05,0.0756,0.1089];
% elseif assetView == "AQR"
%     %AQR view
%     erSet =[0.0638,0.0478,0.0478,0.0478,0.0358,0.07,0.07,0.0638,0.07];
%     volSet = [0.153,0.233,0.139,0.111,0.065,0.086,0.086,0.153,0.086];
% elseif assetView == "PIMCO"
%     %PIMCO view
%     erSet =[0.051,0.06,0.06,0.06,0.04,0.053,0.053,0.051,0.055];
%     volSet = [0.141,0.23,0.14,0.14,0.059,0.11,0.08,0.141,0.1];
% elseif assetView == "2-Sigma"
%     %2-Sigma view
% elseif assetView == "BlackRock"
%     %BlackRock view
%     erSet =[0.0584,0.132,0.0564,0.0564,0.0424,0.0542,0.0542,0.0584,0.0542];
%     volSet = [0.164,0.298,0.116,0.116,0.072,0.077,0.077,0.164,0.077];
% elseif assetView == "Historical"
%     %Historical
elseif assetView == "AIG_COVID"
    % from M:\PublicEquityQuant\AssetAllocation\SAA_analysis\externalAssetClassReturnAssumptions\combined_capitalMarketAssumptions_June2020.xlsx
    switch riskType 
        case 'Accounting'
           factorKeySet = {'Equity','Rates','Kredit','Mtg'};
           factorERset =[0.070124572,  0.011800061, 0.012945044, 0.013452167]; %#ok<NASGU> % annual units here
           factorVolSet =[0.174271928, 0.071595505,0.065505117,0.067080039];
           keySet = {'GlobalEquity','PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFBeta0','ARP','AbsRtn'};
           erSet = [0.08301,0.10525431,0.0766664,0.067,0.0660685,0.0645,0.062831,0.042,0.05474,0.04841,0.076716];
           volSet = [0.19405,0.1104667,0.14125,0.1046,0.0922,0.0832,0.1071,0.0737,0.05,0.07,0.1];
        case 'Intrinsic'
           factorKeySet = {'Equity','Rates','Kredit','Mtg'};
           factorERset =[0.070124572, 0.011800061, 0.012945044, 0.013452167]; %#ok<NASGU> % annual units here
           factorVolSet =[0.174271928,0.071595505, 0.059550107, 0.030490927];
           keySet = {'GlobalEquity','PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFBeta0','ARP','AbsRtn'};
           erSet =[0.083008405,0.107284045,0.073738308,0.067,0.066068527,0.0645,0.062830957,0.041990066,0.054741334,0.048408554,0.076716247]; 
           volSet =[0.1941,0.14551,0.14125,0.1046,0.0922,0.0832,0.1071,0.0737,0.05,0.07,0.1]; 
    end 
elseif assetView == "AIG"
    % from M:\PublicEquityQuant\AssetAllocation\SAA_analysis\externalAssetClassReturnAssumptions\combined_capitalMarketAssumptions_June2020.xlsx
    switch riskType 
        case 'Accounting'
           factorKeySet = {'Equity','Rates','Kredit','Mtg'};
           factorERset =[0.070124572,  0.011800061, 0.012945044, 0.013452167]; %#ok<NASGU> % annual units here
           factorVolSet =[0.174271928, 0.071595505,0.065505117,0.067080039];
           keySet = {'GlobalEquity','PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFBeta0','ARP','AbsRtn'};
           erSet =  [0.06143,     0.0991,     0.0682,   0.08688,  0.04890, 0.0486, 0.05966, 0.04327, 0.0486, 0.06684, 0.0735];
           volSet = [0.151325,    0.1292,     0.076,    0.0811,   0.07378, 0.0781, 0.11253, 0.07574, 0.06,   0.0887,  0.1];
        case 'Intrinsic'
           factorKeySet = {'Equity','Rates','Kredit','Mtg'};
           factorERset =[0.070124572, 0.011800061, 0.012945044, 0.013452167]; %#ok<NASGU> % annual units here
           factorVolSet =[0.174271928,0.071595505, 0.059550107, 0.030490927];
           keySet = {'GlobalEquity','PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFBeta0','ARP','AbsRtn'};
           erSet =   [0.06143,      0.10031,  0.0644,   0.08688,  0.04890, 0.0486, 0.05966, 0.04326, 0.0486, 0.06684, 0.0735]; 
           volSet =  [0.15132,      0.2066,   0.153,    0.1135,   0.0737,  0.0781, 0.1125,  0.0758,  0.06,   0.0887,  0.1]; 
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
   iRE = find(strcmp(keySet,'PvtEqRE'));
   assetReturns(2:end,iPE) = assetReturns(1:end-1,iPE);
   assetReturns(2:end,iRE) = assetReturns(1:end-1,iRE);
   assetReturns = assetReturns(2:end,:); 
   factorReturns = factorReturns(2:end,:);
end 
assetMu = mean(assetReturns,1)';

if capCons.opt % set capacity constraint params if option is true
   lb = zeros(length(keySet),1); 
   ub = ones(length(keySet),1); 
   iEQ = find(strcmp(keySet,'GlobalEquity'));
   iPE = find(strcmp(keySet,'PvtEqBO'));
   iRE = find(strcmp(keySet,'PvtEqRE'));
   iFT = find(strcmp(keySet,'PvtEqFT'));
   iHY = find(strcmp(keySet,'HYcorp'));
   iEM = find(strcmp(keySet,'HYem'));
   iPC = find(strcmp(keySet,'PvtCrMM'));
   iHF = find(strcmp(keySet,'HFBeta'));
   iHF0 = find(strcmp(keySet,'HFBeta0'));
   iARP = find(strcmp(keySet,'ARP'));
   iAR = find(strcmp(keySet,'AbsRtn'));
   if strcmpi(client,'L&R')
%       ub(iEQ) = 0.06; 
%       ub(iPE) = 0.12; 
%       ub(iRE) = 0.16; 
      ub(iFT) = 0.04; 
%       ub(iHY) = 0.3; 
%       ub(iEM) = 0.12; 
%       ub(iPC) = 0.44; 
%       ub(iHF) = 0.09; 
      ub(iHF0) = 0.04; 
      ub(iARP) = 0.04; 
      ub(iAR) = 0.04; 
%       lb(iPE) = 0.04; 
%       lb(iRE) = 0.08; 
%       lb(iHY) = 0.21; 
%       lb(iEM) = 0.04; 
%       lb(iPC) = 0.35; 
%       lb(iHF) = 0.01; 
   else % 'GI'
%       ub(iEQ) = 0.06; 
%       ub(iPE) = 0.2; 
%       ub(iRE) = 0.3; 
      ub(iFT) = 0.06; 
%       ub(iHY) = 0.11; 
%       ub(iEM) = 0.075; 
%       ub(iPC) = 0.39; 
%       ub(iHF) = 0.28; 
      ub(iHF0) = 0.06; 
      ub(iARP) = 0.06; 
      ub(iAR) = 0.06; 
%       lb(iPE) = 0.07; 
%       lb(iRE) = 0.17; 
%       lb(iPC) = 0.26; 
   end 
   capCons.ub = ub; 
   capCons.lb = lb; 
end

assetCov = RobustCovarianceEstimate(assetReturns(:,iA),factorReturns(:,iF),"FactorView",sqrt(fDataPeriods/12)*factorVolSet');
assetCos = RobustCoskewnessEstimate(assetReturns(:,iA),factorReturns(:,iF),"Factor");
assetCok = RobustCokurtosisEstimate(assetReturns(:,iA),factorReturns(:,iF),"Factor");

%Overwrite ARP and HF expected returns and vol
if assetView ~= "Historical" && assetView ~= "AIG"
    %Estimate alpha for ARP
    idxGE = find(strcmp(keySet,'GlobalEquity'));
    idxARP = find(strcmp(keySet,'ARP'));
    [alpha,beta, err]=EstimateFactorExposure(assetReturns(:,idxARP),assetReturns(:,idxGE),false);
    erSet(idxARP) = alpha*12/dataPeriods + beta*erSet(idxGE);
    volSet(idxARP) = sqrt((beta*volSet(idxGE))^2+var(err)*12/dataPeriods);
    
    %Estimate alpha for HFBeta
    idxHFBeta = find(strcmp(keySet,'HFBeta'));
    [alpha, beta, err]=EstimateFactorExposure(assetReturns(:,idxHFBeta),assetReturns(:,idxGE),false); %#ok<ASGLU>
    beta = 0.2;
    erSet(idxHFBeta) = alpha*12/dataPeriods + beta*erSet(idxGE);
    volSet(idxHFBeta) = sqrt((beta*volSet(idxGE))^2+var(err)*12/dataPeriods);
    
    idxHFAlpha1 = find(strcmp(keySet,'HFBeta0'));
    volSet(idxHFAlpha1) = 0.04;
    erSet(idxHFAlpha1) = volSet(idxHFAlpha1)*1.0; 
    
    idxHFAlpha2 = find(strcmp(keySet,'AbsRtn'));
    volSet(idxHFAlpha2) = 0.1;
    erSet(idxHFAlpha2) = volSet(idxHFAlpha2)*0.75; 
end

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
            assetRBC(i,1)=(client=="L&R")*0.6246+(client=="GI")*0.0549;
            assetIC(i,1)=0.44;
            assetIlliquid(i,1) = 0;
        case char('PvtEqBO')
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.4164+(client=="GI")*0.0732;
            assetIC(i,1)=0.37;
            assetIlliquid(i,1) = 1;
        case char('PvtEqRE')
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.7048+(client=="GI")*0.0732;
            assetIC(i,1)=0.43;
            assetIlliquid(i,1) = 1;
        case char('PvtEqFT')
            assetLiq(i,1)=8.0;
            assetRBC(i,1)=(client=="L&R")*0.237+(client=="GI")*0.04;
            assetIC(i,1)=0.43;
            assetIlliquid(i,1) = 1;
        case char('HYcorp')
            assetLiq(i,1)=0.0833;
            assetRBC(i,1)=(client=="L&R")*0.2264+(client=="GI")*0.0085;
            assetIC(i,1)=0.2;
            assetIlliquid(i,1) = 0;
        case char('HYem')
            assetLiq(i,1)=0.0833;
            assetRBC(i,1)=(client=="L&R")*0.1765+(client=="GI")*0.0061;
            assetIC(i,1)=0.2;
            assetIlliquid(i,1) = 0;
        case char('PvtCrMM')
            assetLiq(i,1)=3.0;
            assetRBC(i,1)=(client=="L&R")*0.2908+(client=="GI")*0.0158;
            assetIC(i,1)=0.2;
            assetIlliquid(i,1) = 0;
        case char('HFBeta') %
            assetLiq(i,1)=1.1;
            assetRBC(i,1)=(client=="L&R")*0.4164+(client=="GI")*0.0732;
            assetIC(i,1)=0.3;
            assetIlliquid(i,1) = 1;
        case char('HFBeta0')
            assetLiq(i,1)=0.5;
            assetRBC(i,1)=(client=="L&R")*.4164+(client=="GI")*0.0732;
            assetIC(i,1)=0.3;
            assetIlliquid(i,1) = 0;
        case char('ARP')
            assetLiq(i,1)=0.012;
            assetRBC(i,1)=(client=="L&R")*0.035+(client=="GI")*0.0025;
            assetIC(i,1)=0.31;
            assetIlliquid(i,1) = 0;
        case char('AbsRtn')
            assetLiq(i,1)=0.04;
            assetRBC(i,1)=(client=="L&R")*0.4164+(client=="GI")*0.0732;
            assetIC(i,1)=0.3;
            assetIlliquid(i,1) = 0;
        otherwise
    end
end

%Asset allocation
figure(1);
clf(1);
hold on;

% rebalPeriods  = rebalPeriods/dataPeriods; % Logic based on poor time unit convention; now d

% SR asset perturbation here: 
%{'GlobalEquity','PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFBeta0','ARP','AbsRtn'};
ii = find(strcmpi(keySet,{'AbsRtn'}));
assetMu(ii) = 1.1*assetMu(ii);

%Optimal allocation
a = sqrt((12/rebalPeriods)*varianceTarget);
a = round(a,3); 
volGrid = a +(1:7)*0.01-0.05;
varGrid = volGrid.^2/(12/rebalPeriods);
outputArray2 = zeros(length(varGrid),length(assetMu));
outputArray3 = zeros(length(varGrid),10);
for i = 1:length(varGrid)
   w = ExpectedUtilityOptimization(utilityFunction,gamma,shrinkageRP,assetMu,assetCov,assetCos,assetCok,rebalPeriods,longOnly,...
                                   assetLiq,assetRBC,assetIC,assetIlliquid,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,...
                                   varGrid(i),capCons);
   varp = (w'*assetCov*w)*(12/rebalPeriods); % annualize
   volp = sqrt(varp); 
   mup = (w'*assetMu)*(12/rebalPeriods); % annualize
   annSR = mup/volp; 
   avgLiqHzn = w'*assetLiq; 
   avgRBCcharge = w'*assetRBC; 
   avgICcharge = w'*assetIC; 
   illiquidsWt = w'*assetIlliquid; 
   outputArray2(i,:) = w'; 
   outputArray3(i,:) = [mup,volp,annSR,shrinkageRP,varianceTarget,gamma,avgLiqHzn,avgRBCcharge,avgICcharge,illiquidsWt]; 
end
w = outputArray2(5,:)';
varp = (w'*assetCov*w)*(12/rebalPeriods); % annualize
volp = sqrt(varp); 
mup = (w'*assetMu)*(12/rebalPeriods); % annualize

if (liquidationLimit > 0) || (RBCLimit > 0) || (ICLimit > 0) || (illiquidLimit > 0)
   plot(volp,mup,'bs','DisplayName','Optimal Constrainted Portfolio');
else
   plot(volp,mup,'bs','DisplayName','Optimal Portfolio');
end 
   % annSR = 12*mup/(sqrt(12)*volp); 

%Current allocation
curWeights =[];
if client == "L&R"
    if assetView == "AIG"
        curWeights = [0.019631,0.0804916,0.117991,0,0.2561,0.08107,0.39172,0.052974,0,0,0];
    else
        curWeights = [0.019631,0.0804916,0.117991,0,0.2561,0.08107,0.39172,0.052974,0,0,0];
    end
elseif client == "GI"
    if assetView == "AIG"
        curWeights = [0.010713,0.13688,0,0.2346,0.05225,0.014875,0.32574,0.224923,0,0,0];
    else
        curWeights = [0.010713,0.13688,0,0.2346,0.05225,0.014875,0.32574,0.224923,0,0,0];
    end
end

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
xx = [outputArray3(:,[1:3,7:8]),outputArray2]; 
disp(xx)

end 

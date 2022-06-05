%Function Arguments:
%
%
function RiskAssetAllocationJC_10(assetView,filePath,rebalPeriods,utilityFunction,utilityParam,shrinkageRP,longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,riskType,client)

allowLeverage = false; %#ok<NASGU>
gamma = utilityParam;
if nargin < 13 || isempty(riskType)
   riskType = 'Accounting'; % 'Accounting' or 'Intrinsic'
end
%Load asset data
switch riskType 
   case 'Accounting'
      assetDataTable = readtable(filePath+"\\QuarterlyAssetData10.csv");
      t0 = find(assetDataTable.Date == datetime('03/31/2004'));
      assetDataTable = assetDataTable(t0:end,:);
      dataPeriods = 3;
      rebalPeriods = 3;
   case 'Intrinsic'
      assetDataTable = readtable(filePath+"\\QuarterlyUnsmoothedAssetData10.csv");
      t0 = find(assetDataTable.Date == datetime('03/31/2004'));
      assetDataTable = assetDataTable(t0:end,:);
      dataPeriods = 3;
      rebalPeriods = 3;
   otherwise
      assetDataTable = readtable(filePath+"\\MonthlyAssetData.csv");
      dataPeriods = 1;
end
disp(assetDataTable.Properties.VariableNames);
assetClassNames = assetDataTable.Properties.VariableNames(2:end);
nAssets = size(assetClassNames,2); %#ok<NASGU>
nPeriods = size(assetDataTable{:,1},1); %#ok<NASGU>
dates = assetDataTable.Date; %#ok<NASGU>
assetReturns = assetDataTable{:,assetClassNames};

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

%View overwrite 
keySet = {'GlobalEquity','PvtEqBO','PvtEqRE','PvtEqFT','HYcorp','HYem','PvtCrMM','HFBeta','HFBeta0','ARP','AbsRtn'};
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
elseif assetView == "AIG"
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
end

%Estimate asset co-moments 
iA = mapStrings(keySet,assetClassNames); 
iF = mapStrings(factorKeySet,factorNames); 
assetMu = mean(assetReturns(:,iA),1)';
assetCov = RobustCovarianceEstimate(assetReturns(:,iA),factorReturns(:,iF),"FactorView",sqrt(fDataPeriods/12)*factorVolSet');
assetCos = RobustCoskewnessEstimate(assetReturns(:,iA),factorReturns(:,iF),"Factor");
assetCok = RobustCokurtosisEstimate(assetReturns(:,iA),factorReturns(:,iF),"Factor");
nAssets2 = length(iA); 

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
    
    for i=1:length(iA)
        if isKey(erViewMap,assetClassNames(1,iA(i)))
            erView(i,1) = erViewMap(string(assetClassNames(1,iA(i))));
            volView(i,1) = volViewMap(string(assetClassNames(1,iA(i))));
        end
    end
   
    % All moments will be consistent in terms of frequency: assetMu,assetCov,assetCos,assetCok have the frequency of the dataset; erView and volView are annual
    % assetMu,assetCov,assetCos and assetCok get adjusted to have magnitudes consistent with erView and volView: 
    [assetMu,assetCov,assetCos,assetCok,varianceTarget] = AdjustAssetView(dataPeriods,assetMu,assetCov,assetCos,assetCok,erView,volView,varianceTarget); 
end

assetVar = zeros(nAssets2,1);
assetSkew = zeros(nAssets2,1);
assetKurt = zeros(nAssets2,1);
for i=1:nAssets2
    assetVar(i,1) = assetCov(i,i);
    assetSkew(i,1) = assetCos(i,(i-1)*nAssets2+i);
    assetKurt(i,1) = assetCok(i,((i-1)*nAssets2+i-1)*nAssets2+i);
end

%Liquidation
assetLiq=zeros(nAssets2,1);
assetRBC=zeros(nAssets2,1);
% assetRBC_lr=zeros(nAssets2,1);
% assetRBC_gi=zeros(nAssets2,1);
assetIC=zeros(nAssets2,1);
assetIlliquid=zeros(nAssets2,1);

for i=1:nAssets2
    switch string(assetClassNames(iA(i)))
        case char('GlobalEquity')
            assetLiq(i,1)=0.019;
            assetRBC(i,1)=(client=="L&R")*0.391+(client=="GI")*0.0549;
            assetIC(i,1)=0.44;
            assetIlliquid(i,1) = 0;
        case char('PvtEqBO') % ,',,,,,
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.261+(client=="GI")*0.0732;
            assetIC(i,1)=0.37;
            assetIlliquid(i,1) = 1;
        case char('PvtEqRE')
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.7+(client=="GI")*0.072;
            assetIC(i,1)=0.43;
            assetIlliquid(i,1) = 1;
        case char('PvtEqFT')
            assetLiq(i,1)=8.0;
            assetRBC(i,1)=(client=="L&R")*0.237+(client=="GI")*0.04;
            assetIC(i,1)=0.43;
            assetIlliquid(i,1) = 0;
        case char('HYcorp')
            assetLiq(i,1)=0.0833;
            assetRBC(i,1)=(client=="L&R")*0.4123+(client=="GI")*0.0223;
            assetIC(i,1)=0.2;
            assetIlliquid(i,1) = 0;
        case char('HYem')
            assetLiq(i,1)=0.0833;
            assetRBC(i,1)=(client=="L&R")*0.4123+(client=="GI")*0.0223;
            assetIC(i,1)=0.2;
            assetIlliquid(i,1) = 0;
        case char('PvtCrMM')
            assetLiq(i,1)=3.0;
            assetRBC(i,1)=(client=="L&R")*0.4123+(client=="GI")*0.0223;
            assetIC(i,1)=0.2;
            assetIlliquid(i,1) = 0;
        case char('HFBeta') %
            assetLiq(i,1)=1.1;
            assetRBC(i,1)=(client=="L&R")*0.2807+(client=="GI")*0.0723;
            assetIC(i,1)=0.3;
            assetIlliquid(i,1) = 1;
        case char('HFBeta0')
            assetLiq(i,1)=0.5;
            assetRBC(i,1)=(client=="L&R")*0.216+(client=="GI")*0.0732;
            assetIC(i,1)=0.3;
            assetIlliquid(i,1) = 0;
        case char('ARP')
            assetLiq(i,1)=0.012;
            assetRBC(i,1)=0;
            assetIC(i,1)=0.31;
            assetIlliquid(i,1) = 0;
        case char('AbsRtn')
            assetLiq(i,1)=0.04;
            assetRBC(i,1)=(client=="L&R")*0.216+(client=="GI")*0.0732;
            assetIC(i,1)=0.3;
            assetIlliquid(i,1) = 0;
        otherwise
    end
end

%Asset allocation
% figure(1);
% clf(1);
% hold on;

%rebalPeriods  = rebalPeriods/dataPeriods; %Use asset data frequency as the unit

%Optimal allocation
rpw = 0.6*EqualRiskContribution(assetCov,longOnly,varianceTarget)'+...
      0.2*EqualRiskContribution(assetCov,longOnly)'+...
      0.2*RiskParity(assetCov,longOnly,'simple')';
%        'GlobalEquity','PE_BO',    'PE_RE',   'PE_FT','HY',  'HY_EM','PvtCr_MM','HFBeta','HFAlpha1','ARP','HFAlpha2'};
wtsLR = [0.019631,      0.0804916,   0.117991, 0,      0.2561, 0.0811,   0.3917,   0.052974, 0, 0, 0];
wtsGI = [0.01071323,	0.13688062,	0.2346145, 0,	   0.0523, 0.014875, 0.325744, 0.22492,  0, 0, 0];
muRP = (12/dataPeriods)*rpw*assetMu;
muLR = (12/dataPeriods)*wtsLR*assetMu;
muGI = (12/dataPeriods)*wtsGI*assetMu;
volRP = sqrt((12/dataPeriods)*rpw*assetCov*rpw');
volLR = sqrt((12/dataPeriods)*wtsLR*assetCov*wtsLR');
volGI = sqrt((12/dataPeriods)*wtsGI*assetCov*wtsGI');
SR_RP = muRP/volRP;
SR_LR = muLR/volLR;
SR_GI = muGI/volGI;
outputArray1 = {utilityFunction,assetView,riskType}; %#ok<NASGU>
volArray = 0.05:0.0025:0.09; 
outputArray2 = zeros(length(volArray)+3,nAssets2); % nAssets); 
outputArray3 = zeros(length(volArray)+3,10); 
outputArray2(1:3,:) = [rpw; wtsLR; wtsGI]; 
ww = [rpw;wtsLR;wtsGI]; 
temp = repmat([shrinkageRP,varianceTarget,gamma],[3,1]);
outputArray3(1:3,:) = [[[muRP;muLR;muGI],[volRP;volLR;volGI],[SR_RP;SR_LR;SR_GI]],temp,ww*[assetLiq';assetRBC';assetIC';assetIlliquid']']; 
%outputArray3(1:3,:) = [(rpw'*assetMu)*12/dataPeriods,sqrt((w'*assetMu)*12/dataPeriods),0];
for i = 1:length(volArray)
   varianceTarget = (volArray(i)^2)*(rebalPeriods/12); % convert variance target from annual units to returns' period units
   w = ExpectedUtilityOptimization(utilityFunction,gamma,shrinkageRP,assetMu,assetCov,assetCos,assetCok,rebalPeriods,longOnly,assetLiq,assetRBC,assetIC,assetIlliquid,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget);
   % w = ExpectedUtilityOptimization(utilityFunction,gamma,shrinkageRP,assetMu,assetCov,assetCos,assetCok,rebalPeriods,longOnly,assetLiq,assetRBC,assetIC,assetIlliquid,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget);

   varp = (w'*assetCov*w)*12/dataPeriods;
   mup = (w'*assetMu)*12/dataPeriods;
   volp = sqrt(varp);
   annSR = mup/volp;
   % annSR = 12*mup/(sqrt(12)*volp); 
   avgLiqHzn = w'*assetLiq;
   avgRBCcharge = w'*assetRBC;
   avgICcharge = w'*assetIC;
   illiquidsWt = w'*assetIlliquid;
   outputArray2(i+3,:) = w';
   outputArray3(i+3,:) = [mup,volp,annSR,shrinkageRP,varianceTarget,gamma,avgLiqHzn,avgRBCcharge,avgICcharge,illiquidsWt]; 
end 
disp(outputArray2)
disp(outputArray3)
outputArray4 = [[muLR,volLR,SR_LR,wtsLR];[muGI,volGI,SR_GI,wtsGI]]; %#ok<NASGU>

% %Efficient frontier
% w=GlobalMinimumVariance(assetCov,true);
% minVar = (w'*assetCov*w)*12/dataPeriods; %#ok<NASGU>
% 
% minRet = min(assetMu)*12/dataPeriods;
% maxRet = max(assetMu)*12/dataPeriods;
% 
% returns = sort(unique([minRet:(maxRet-minRet)/40:maxRet assetMu'*12/dataPeriods mup]));
% vars = returns;
% for i=1:size(returns,2)
%     w=MinimumVariance(assetMu,assetCov,12/dataPeriods,returns(1,i),true);
%     vars(1,i)= (w'*assetCov*w)*12/dataPeriods;
% end
% 
% figure(1);
% plot(vars.^0.5*100,returns*100,100*volLR,100*muLR,'bs',100*volGI,100*muGI,'gd'); 
% title(['Efficient Frontier, ',riskType,' Risk']);legend('MV Efficient Frontier','L&R','GI'); 
% xlabel('Portfolio Vol'); ylabel('Portfolio E[xsRtn]'); grid; 
% 
% %Risk parity
% w=RiskParity(assetCov,longOnly);
% 
% varp = (w'*assetCov*w)*12/dataPeriods;
% mup = (w'*assetMu)*12/dataPeriods;
% plot(varp^0.5*100,mup*100,'g*','DisplayName','Risk Parity');
% 
% plot((assetVar*12/dataPeriods).^0.5*100,assetMu*12/dataPeriods*100,'r+','DisplayName','Asset View');
% dv = mean(assetVar)*12/dataPeriods*0.05;
% for i=1:nAssets2
%     text((assetVar(i)*12/dataPeriods+dv).^0.5*100,assetMu(i)*12/dataPeriods*100,keySet(i));
% end
% 
% legend('Location','southeast');
% hold off
% 
% disp("Optimal weights:");
% disp(w);


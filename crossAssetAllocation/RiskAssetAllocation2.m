%Function Arguments:
%
%
function RiskAssetAllocation2(assetView,filePath,rebalPeriods,utilityFunction,utilityParam,shrinkageRP,...
                              longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,riskType,client)

allowLeverage = false; %#ok<NASGU>
gamma = utilityParam;
if nargin < 14 || isempty(client)
   riskType = 'L&R'; % 'L&R' or 'GI'
end
if nargin < 13 || isempty(riskType)
   riskType = 'Accounting'; % 'accounting' or 'intrinsic'
end
%Load asset data
switch riskType 
   case 'Accounting'
       assetDataTable = readtable(filePath+"\\QuarterlyAssetData.csv");
       dataPeriods = 3;
       rebalPeriods = 3;
    case 'Intrinsic'
       assetDataTable = readtable(filePath+"\\QuarterlyUnsmoothedAssetData.csv");
       dataPeriods = 3;
       rebalPeriods = 3;
    otherwise
       assetDataTable = readtable(filePath+"\\MonthlyAssetData.csv");
       dataPeriods = 1;
end
disp(assetDataTable.Properties.VariableNames);
assetClassNames = assetDataTable.Properties.VariableNames(2:end);  %#ok<NASGU>
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

keySet = {'GlobalEquity','PE','GRE','REIT','HY','HFBeta','HFAlpha1','ARP','HFAlpha2'};
if assetView == "AIG"
    keySet = {'GlobalEquity','PE','GRE','HY','HFBeta','ARP','HFAlpha2'};
end

%Extract a subset of asset data
assetReturns = assetDataTable{:,keySet};
assetClassNames = keySet;
nAssets = size(assetClassNames,2);

%View overwrite
erSet =[];
%Asset view
if assetView == "JPM"
    %JPM view
    erSet =[0.0655,0.088,0.077,0.058,0.0455,0.045,0.045,0.0655,0.045];
    volSet = [0.143,0.202,0.172,0.111,0.079,0.074,0.074,0.143,0.074];
elseif assetView == "AQR"
    %AQR view
    erSet =[0.0638,0.0478,0.0478,0.0478,0.0358,0.07,0.07,0.0638,0.07];
    volSet = [0.153,0.233,0.139,0.111,0.065,0.086,0.086,0.153,0.086];
elseif assetView == "PIMCO"
    %PIMCO view
    erSet =[0.051,0.06,0.06,0.06,0.04,0.053,0.053,0.051,0.055];
    volSet = [0.141,0.23,0.14,0.14,0.059,0.11,0.08,0.141,0.1];
elseif assetView == "2-Sigma"
    %2-Sigma view
elseif assetView == "BlackRock"
    %BlackRock view
    erSet =[0.0584,0.132,0.0564,0.0564,0.0424,0.0542,0.0542,0.0584,0.0542];
    volSet = [0.164,0.298,0.116,0.116,0.072,0.077,0.077,0.164,0.077];
elseif assetView == "Historical"
    %Historical
elseif assetView == "AIG"
    % from M:\PublicEquityQuant\AssetAllocation\SAAdocumentation\externalAssetClassReturnAssumptions\combined_capitalMarketAssumptions_feb2020.xlsx
    switch riskType 
        case 'Accounting'
           factorKeySet = {'Equity','Rates','Kredit','Mtg'}; 
           factorERset =  [0.070124572, 0.011800061, 0.012945044, 0.013452167]; %#ok<NASGU>
           factorVolSet = [0.174271928, 0.071595505, 0.065505117, 0.067080039]; 
           erSet =  [0.07684988, 0.081959911,0.065994811,0.048672885,0.036300985,0.038866091,0.069376106];
           volSet = [0.174271928,0.128555948,0.138810134,0.075267458,0.065267458,0.0756,     0.1089];
        case 'Intrinsic'
           factorKeySet = {'Equity','Rates','Kredit','Mtg'}; 
           factorERset =[0.070124572, 0.011800061, 0.012945044, 0.013452167]; %#ok<NASGU>
           factorVolSet =[0.174271928,0.071595505,0.059550107,0.030490927]; 
           keySet = {'GlobalEquity','PE','GRE','HY','HFBeta','ARP','HFAlpha2'};
           erSet = [0.07684988, 0.104314949,0.076546504,0.048672885,0.036300985,0.038866091,0.069376106];
           volSet =[0.174271928,0.191426788,0.138810134,0.075267458,0.065267458,0.0756,     0.1089];
    end 
end

%Estimate asset co-moments
iF = mapStrings(factorKeySet,factorNames); 
assetMu = mean(assetReturns,1)';
assetCov = RobustCovarianceEstimate(assetReturns,factorReturns(:,iF),"FactorView",sqrt(fDataPeriods/12)*factorVolSet');
assetCos = RobustCoskewnessEstimate(assetReturns,factorReturns,"Factor");
assetCok = RobustCokurtosisEstimate(assetReturns,factorReturns,"Factor");

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
    
    idxHFAlpha1 = find(strcmp(keySet,'HFAlpha1'));
    volSet(idxHFAlpha1) = 0.04;
    erSet(idxHFAlpha1) = volSet(idxHFAlpha1)*1.0; 
    
    idxHFAlpha2 = find(strcmp(keySet,'HFAlpha2'));
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
    switch string(assetClassNames(i))
        case char('GlobalEquity')
            assetLiq(i,1)=0.019;
            assetRBC(i,1)=(client=="L&R")*0.391+(client=="GI")*0.0549;
            assetIC(i,1)=0.44;
            assetIlliquid(i,1) = 0;
        case char('PE')
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.261+(client=="GI")*0.0732;
            assetIC(i,1)=0.37;
            assetIlliquid(i,1) = 1;
        case char('GRE')
            assetLiq(i,1)=6.5;
            assetRBC(i,1)=(client=="L&R")*0.7+(client=="GI")*0.072;
            assetIC(i,1)=0.43;
            assetIlliquid(i,1) = 1;
        case char('REIT')
            assetLiq(i,1)=0.019;
            assetRBC(i,1)=(client=="L&R")*0.391+(client=="GI")*0.0549;
            assetIC(i,1)=0.43;
            assetIlliquid(i,1) = 0;
        case char('HY')
            assetLiq(i,1)=0.0833;
            assetRBC(i,1)=(client=="L&R")*0.4123+(client=="GI")*0.0223;
            assetIC(i,1)=0.2;
            assetIlliquid(i,1) = 0;
        case char('HFBeta')
            assetLiq(i,1)=1.1;
            assetRBC(i,1)=(client=="L&R")*0.2807+(client=="GI")*0.0723;
            assetIC(i,1)=0.3;
            assetIlliquid(i,1) = 1;
        case char('HFAlpha1')
            assetLiq(i,1)=0.5;
            assetRBC(i,1)=(client=="L&R")*0.216+(client=="GI")*0.0732;
            assetIC(i,1)=0.3;
            assetIlliquid(i,1) = 0;
        case char('ARP')
            assetLiq(i,1)=0.012;
            assetRBC(i,1)=0;
            assetIC(i,1)=0.31;
            assetIlliquid(i,1) = 0;
        case char('HFAlpha2')
            assetLiq(i,1)=0.03;
            assetRBC(i,1)=(client=="L&R")*0.216+(client=="GI")*0.0732;
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

%Optimal allocation
a=sqrt((12/rebalPeriods)*varianceTarget);
varGrid = [(a-0.01)^2/(12/rebalPeriods),(a-0.005)^2/(12/rebalPeriods),(a)^2/(12/rebalPeriods),(a+0.005)^2/(12/rebalPeriods),(a+0.01)^2/(12/rebalPeriods)]; % time units correspond to sample period length (e.g., monthly or qrtrly)
outputArray2 = zeros(length(varGrid),length(assetMu));
outputArray3 = zeros(length(varGrid),10);
for i = 1:length(varGrid)
   w = ExpectedUtilityOptimization(utilityFunction,gamma,shrinkageRP,assetMu,assetCov,assetCos,assetCok,rebalPeriods,longOnly,...
                                   assetLiq,assetRBC,assetIC,assetIlliquid,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,...
                                   varGrid(i));
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
w = outputArray2(3,:)';
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
        curWeights = [0.022526332,0.091489198,0.086953179,0.73990928,0.059122011,0,0];
    else
        curWeights = [0.022526332,0.091489198,0.086953179,0,0.73990928,0,0.059122011,0,0];
    end
elseif client == "GI"
    if assetView == "AIG"
        curWeights = [0.01202951,0.151720999,0.175437503,0.41534795,0.245464037,0,0];
    else
        curWeights = [0.01202951,0.151720999,0.175437503,0,0.41534795,0,0.245464037,0,0];
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

disp(outputArray2)
disp(outputArray3)

end 

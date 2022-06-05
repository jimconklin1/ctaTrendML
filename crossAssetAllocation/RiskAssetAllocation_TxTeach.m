function RiskAssetAllocation_TxTeach(cfg,params)

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
       assetDataTable = readtable(filePath+"SAA_Analysis\SAA_TexasTeachers\QuarterlyAssetData_TXteachers_Q12021.csv");
       t0 = find(assetDataTable.Date == datetime('03/31/2004'));
       if ~isempty(t0)
          assetDataTable = assetDataTable(t0:end,:);
       end 
       dataPeriods = 3;
       rebalPeriods = 3;
    case 'Intrinsic'
       assetDataTable = readtable(filePath+"SAA_Analysis\SAA_TexasTeachers\QuarterlyUnsmoothedAssetData_TXteachers_Q12021.csv");
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
        factorDataTable = readtable(filePath + "SAA_Analysis\SAA_TexasTeachers\QuarterlyFactorData_TXteachers_Q12021.csv");
        fDataPeriods = 3; 
    case 'Intrinsic'
        factorDataTable = readtable(filePath + "SAA_Analysis\SAA_TexasTeachers\QuarterlyFactorData_TXteachers_Q12021.csv");
        fDataPeriods = 3; 
    otherwise
        factorDataTable = readtable(filePath + "SAA_Analysis\SAA_TexasTeachers\MonthlyFactorDataQ12021.csv");
        fDataPeriods = 1; 
end
factorNames = factorDataTable.Properties.VariableNames(2:end);
nFactors = size(factorNames,2); %#ok<NASGU>
factorReturns = factorDataTable{:,factorNames};
t0 = find(factorDataTable.Date>=assetDataTable.Date(1),1);
factorReturns = factorReturns(t0:end,:); 

keySet = {'GlobalEquity','PvtEqBO','DirEqty','PvtEqRE','PvtEqFT','AbsRtn','HFBeta','CLOeq'};
%keySet = {'GlobalEquity','PvtEqBO','DirEqty','PvtEqRE','PvtEqREva','PvtEqFT','AbsRtn','HFBeta'};
factorKeySet = {'Equity','Rates','Kredit','Mtg'};

o = setExpMoments(riskType);

factorERset = o.factorERset; %#ok<NASGU>
factorVolSet = o.factorVolSet;
erSet = o.erSet;
volSet = o.volSet;

assetReturns = assetDataTable{:,keySet};
assetClassNames = keySet;
nAssets = size(assetClassNames,2);

%Estimate asset co-moments
iA = mapStrings(keySet,assetClassNames);
iF = mapStrings(factorKeySet,factorNames); 
if strcmpi(riskType,'accounting')
   iPE = find(strcmp(keySet,'PvtEqBO'));
   iDE = find(strcmp(keySet,'DirEqty'));
   iFT = find(strcmp(keySet,'PvtEqFT'));
   assetReturns(2:end,iPE) = assetReturns(1:end-1,iPE);
   assetReturns(2:end,iDE) = assetReturns(1:end-1,iDE);
   assetReturns(2:end,iFT) = assetReturns(1:end-1,iFT);
   assetReturns = assetReturns(2:end,:); 
   factorReturns = factorReturns(2:end,:);
end 
assetMu = mean(assetReturns,1)';

if capCons.opt % set capacity constraint params if option is true
   lb = zeros(length(keySet),1); 
   ub = ones(length(keySet),1); 
   iEQ = find(strcmp(keySet,'GlobalEquity')); 
   iPE = find(strcmp(keySet,'PvtEqBO')); 
   iDE = find(strcmp(keySet,'DirEqty'));
   iRE = find(strcmp(keySet,'PvtEqRE')); 
   iFT = find(strcmp(keySet,'PvtEqFT'));
   iAR = find(strcmp(keySet,'AbsRtn')); 
   iHF = find(strcmp(keySet,'HFBeta')); 
   iCL = find(strcmp(keySet,'CLOeq')); 
   %                             Per_1  Per_2   Per_3
   %        Public Equity       20%     33%     46%
   %        PE                  36%     43%     51%
   %        DE                  21%     31%     41%
   %        GRE                 29%     39%     50%
   %        Farm and Timber     3.6%	5.2%	7.5%
   %        Absolute Return     23%     31%     41%

   % imposing Per_2/base case:
   ub(iEQ) = 0.4;  %#ok<FNDSB>
   ub(iPE) = 0.4;  %#ok<FNDSB>
   ub(iDE) = 0.35; %#ok<FNDSB>  
   ub(iRE) = 0.4; %#ok<FNDSB>  
   ub(iFT) = 0.1; %#ok<FNDSB>
   ub(iAR) = 0.3; %#ok<FNDSB>  
   ub(iHF) = 0.3; %#ok<FNDSB>  
   ub(iCL) = 0.3; %#ok<FNDSB>  
%    capCons.ub = ub; 
%    capCons.lb = lb; 
%    % imposing Per_2/ relaxed limits case:
%    ub(iEQ) = 0.5;  %#ok<FNDSB>
%    ub(iPE) = 0.5;  %#ok<FNDSB>
%    ub(iDE) = 0.4; %#ok<FNDSB>  
%    ub(iRE) = 0.5; %#ok<FNDSB>  
%    ub(iFT) = 0.2; %#ok<FNDSB>
%    ub(iAR) = 0.4; %#ok<FNDSB>  
%    ub(iHF) = 0.4; %#ok<FNDSB>  
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
J = 5;
volStep = 0.01;
b = (1:J)*volStep;
volGrid = a + b - round(J/2,0)*volStep;
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
w1 = outputArray2(1,:)';
varp1 = (w1'*assetCov*w1)*(12/rebalPeriods); % annualize
volp1 = sqrt(varp1); 
mup1 = (w1'*assetMu)*(12/rebalPeriods); % annualize
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
w5 = outputArray2(5,:)';
varp5 = (w5'*assetCov*w5)*(12/rebalPeriods); % annualize
volp5 = sqrt(varp5); 
mup5 = (w5'*assetMu)*(12/rebalPeriods); % annualize

if (liquidationLimit > 0) || (RBCLimit > 0) || (ICLimit > 0) || (illiquidLimit > 0)
   plot(volp1,mup1,'bs','DisplayName','Opt Constrained Prtflio 1'); 
   plot(volp2,mup2,'bs','DisplayName','Opt Constrained Prtflio 2'); 
   plot(volp3,mup3,'bs','DisplayName','Opt Constrained Prtflio 3'); 
   plot(volp4,mup4,'bs','DisplayName','Opt Constrained Prtflio 4'); 
   plot(volp5,mup5,'bs','DisplayName','Opt Constrained Prtflio 5'); 
else
   plot(volp,mup,'bs','DisplayName','Optimal Portfolio');
end 
% annSR = 12*mup/(sqrt(12)*volp); 

%Current allocation
curWeights = [0.008, 0.3, 0.217, 0.263, 0.029, 0.083, .1]; % [0.1, 0.375, 0.21, 0.04, 0.275]; % 0.100461772	0.375727026	0.209030985	0.038774719	0.276005499

curMup = curWeights*assetMu*(12/rebalPeriods);
curVolp = sqrt(curWeights*assetCov*curWeights'*(12/rebalPeriods));
curSRp = curMup/curVolp; 
curRBC = curWeights*assetRBC;
curIC = curWeights*assetIC;
curPortVec =[curMup, curVolp, curSRp, curRBC, curIC]'; %#ok<NASGU>
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
xx1 = outputArray2(1:5,:)';
xx2 = outputArray3(1:5,[1:3,8:9])';
disp(xx)
disp(xx1)
disp(xx2)

end 

function o = AssetFactorModel(filePath,dataOpt)

if nargin < 1 || isempty(filePath)
   filePath = 'M:\PublicEquityQuant\AssetAllocation\';
end

if nargin < 2 || isempty(dataOpt)
   dataOpt = 'quarterly'; % 'monthly'; 'quarterly', 'quarterly10','quarterlyUnsmoothed','quarterlyUnsmoothed10'
end

switch dataOpt
    case 'monthly'
       assetDataTable = readtable(filePath + "\\MonthlyAssetData.csv");
       factorDataTable = readtable(filePath + "\\MonthlyFactorData.csv");
       timeScalar = 12; 
    case 'quarterly'
       assetDataTable = readtable(filePath + "\\QuarterlyAssetDataQ12021.csv");
       factorDataTable = readtable(filePath + "\\QuarterlyFactorDataQ12021.csv");
       timeScalar = 4; 
    case 'quarterly10'
       assetDataTable = readtable(filePath+"\\QuarterlyAssetData10.csv");
       t0 = find(assetDataTable.Date == datetime('03/31/2004'));
       iN = find(~strcmp(assetDataTable.Properties.VariableNames,{'REIT'})); 
       assetDataTable = assetDataTable(t0:end,iN); %#ok<FNDSB>
       factorDataTable = readtable(filePath + "\\QuarterlyFactorData.csv");
       timeScalar = 4; 
    case 'quarterlyUnsmoothed'
       assetDataTable = readtable(filePath + "\\QuarterlyUnsmoothedAssetDataQ12021.csv");
       factorDataTable = readtable(filePath + "\\QuarterlyFactorDataQ12021.csv");
       timeScalar = 4; 
   case 'quarterlyUnsmoothed10'
       assetDataTable = readtable(filePath+"\\QuarterlyUnsmoothedAssetData10.csv");
       t0 = find(assetDataTable.Date == datetime('03/31/2004'));
       iN = find(~strcmp(assetDataTable.Properties.VariableNames,{'REIT'})); 
       assetDataTable = assetDataTable(t0:end,iN); %#ok<FNDSB>
       factorDataTable = readtable(filePath + "\\QuarterlyFactorData.csv");
       timeScalar = 4; 
end

% stucture asset variable data
disp(assetDataTable.Properties.VariableNames);
assetClassNames = assetDataTable.Properties.VariableNames(2:end);
nAssets = size(assetClassNames,2);

dates = assetDataTable.Date;
assetReturns = assetDataTable{:,assetClassNames};
assetVols = sqrt(timeScalar)*std(assetReturns)'; 

% stucture factor variable data
disp(factorDataTable.Properties.VariableNames);
factorNames = factorDataTable.Properties.VariableNames(2:end);
nFactors = size(factorNames,2); 
factorReturns = factorDataTable{:,factorNames};
factorVols = sqrt(timeScalar)*std(factorReturns); 

% pre-allocate variables
if assetDataTable.Date(1)~=factorDataTable.Date(1)
   tempDate = max([assetDataTable.Date(1); factorDataTable.Date(1)]); 
   t0a = find(tempDate>=assetDataTable.Date,1,'last');
   t0f = find(tempDate>=factorDataTable.Date,1,'last');
else
   t0a = 1;
   t0f = 1;
end
nPeriods = size(assetDataTable{t0a:end,1},1); 

B = zeros(nAssets,nFactors-1); 
Tstats = zeros(nAssets,nFactors-1); 
pVals = zeros(nAssets,nFactors-1); 
Rsqr = zeros(nAssets,1); 
alpha = zeros(nAssets,1); 
alphaTstats = zeros(nAssets,1); 
alphaTS = zeros(nPeriods,nAssets); 

% estimate factor loadings
statCfg = {'tstat','fstat','rsquare','yhat','r','dwstat'};
X = factorReturns(t0f:end,2:5) - repmat(factorReturns(t0f:end,1),[1,4]);
iPE = find(strcmp(assetClassNames,'PE'));
iRE = find(strcmp(assetClassNames,'GRE'));
if isempty(iPE)
   iPE = find(strcmp(assetClassNames,'PvtEqBO'));
   iRE = find(strcmp(assetClassNames,'PvtEqRE'));
end 


for i = 1:nAssets
   if i==iPE && (strcmp(dataOpt,'quarterly') || strcmp(dataOpt,'quarterly10'))
      y = assetReturns(t0a:end-1,i); 
      XX = X(t0f+1:end,:); 
      stats = regstats(y,XX,'linear',statCfg); 
   elseif i==iRE && (strcmp(dataOpt,'quarterly') || strcmp(dataOpt,'quarterly10'))
      y = assetReturns(t0a:end-1,i); 
      XX = X(t0f+1:end,:); 
      stats = regstats(y,XX,'linear',statCfg); 
   else
      y = assetReturns(t0a:end,i); 
      stats = regstats(y,X,'linear',statCfg); 
   end   
   B(i,:) = stats.tstat.beta(2:5); 
   Tstats(i,:) = stats.tstat.t(2:5); 
   pVals(i,:) = stats.tstat.pval(2:5);
   Rsqr(i,1) = stats.rsquare; 
   alpha(i,1) = stats.tstat.beta(1); 
   alphaTstats(i,1) = stats.tstat.t(1);
   if i==iPE && (strcmp(dataOpt,'quarterly') || strcmp(dataOpt,'quarterly10'))
      alphaTS(:,i) = stats.tstat.beta(1) + [zeros(1,size(stats.r,2)); stats.r]; 
   elseif i==iRE && (strcmp(dataOpt,'quarterly') || strcmp(dataOpt,'quarterly10'))
      alphaTS(:,i) = stats.tstat.beta(1) + [zeros(1,size(stats.r,2)); stats.r]; 
   else
      alphaTS(:,i) = stats.tstat.beta(1) + stats.r; 
   end
end 

temp1 = pVals < 0.1;
temp2 = pVals <= 0.25;
BB = 0.5*B.*(temp1+temp2);
alpha = timeScalar*alpha;
o.aHeader = assetClassNames;
o.fHeader = factorNames(2:5);
o.dates = dates;
o.alpha = alpha;
o.beta = BB;
o.tstat = Tstats;
o.pval = pVals;
o.rsqr = Rsqr;
o.alphaTS = alphaTS;
o.aVols = assetVols;
o.fVols = factorVols;

end 
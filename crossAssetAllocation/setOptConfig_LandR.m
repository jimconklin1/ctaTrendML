function cfg = setOptConfig_LandR(riskType)
cfg.filePath = 'M:\PublicEquityQuant\AssetAllocation\';
cfg.client = 'L&R'; % 'L&R', 'GI' 
if nargin>0 || ~iseempty(riskType)
    cfg.riskType = riskType;
 else
    cfg.riskType = 'Intrinsic'; % 'Accounting'; 'Intrinsic'
end
cfg.assetView = 'AIG'; %
cfg.utilityFunction = 'Power'; % 'Power','Log','Exponential','MeanVariance','Linear','Quadratic','InfoRatio'
cfg.utilityParam = 0.1; % 1.5 if 'Power'; 0.5 if 'Mean Variance'
cfg.unitsMos = 12; 
cfg.rebalPeriods = 1; % default is 1 month
cfg.longOnly = true;
end
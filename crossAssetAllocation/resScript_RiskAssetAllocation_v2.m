% resScript_RiskAssetAllocation
cd C:\GIT\AssetAllocation 
addpath C:\GIT\utils_ml\_data 

% load M:\PublicEquityQuant\AssetAllocation\RiskAssetAllocation_inputVars.mat; 
% variables loaded: assetView, filePath, ICLimit, illiquidLimit, liquidationLimit, longOnly, RBCLimit, rebalPeriods,
%                   riskType, shrinkageRP, utilityFunction, utilityParam, varianceTarget

% Optimimzation configuration:
cfg2 = setOptConfig_LandR('Intrinsic'); % setOptConfig_VALIC(); 'Intrinsic' 'Accounting'
params = setOptParams_LandR(cfg2); % setOptParams_VALIC(cfg2);

RiskAssetAllocation_TxTeach(cfg2,params); 
% RiskAssetAllocation2_LandR(cfg2,params); 
% RiskAssetAllocation2_VALIC(cfg2,params);

% Simple plot of utility function: 
x = 0.01:0.0025:0.1;
y = zeros(1,length(x)); 
gamma = 1.5;
for i = 1:length(x)
  y(i) = 20+((x(i))^(1-gamma))/(1-gamma); 
end
figure(2); plot(x,y); grid;
xlabel('rtn'); ylabel('U(rtn)')

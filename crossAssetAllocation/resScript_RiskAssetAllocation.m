% resScript_RiskAssetAllocation
cd C:\GIT\AssetAllocation 
addpath C:\GIT\utils_ml\_data 
load M:\PublicEquityQuant\AssetAllocation\RiskAssetAllocation_inputVars.mat; 
% variables loaded: assetView, filePath, ICLimit, illiquidLimit, liquidationLimit, longOnly, RBCLimit, rebalPeriods,
%                   riskType, shrinkageRP, utilityFunction, utilityParam, varianceTarget

% Optimimzation configuration:
client = 'GI'; riskType = 'Accounting';% 'L&R', 'GI' 
%client = 'GI'; riskType = 'Intrinsic';% 'L&R', 'GI' 
%client = 'L&R'; riskType = 'Accounting';% 'L&R', 'GI' 
%client = 'L&R'; riskType = 'Intrinsic';% 'L&R', 'GI' 
assetView = 'AIG'; 
utilityFunction = 'Power'; % 'Power','Log','Exponential','MeanVariance','Linear','Quadratic','InfoRatio'
unitsMos = 12; 
rebalPeriods = 1; % default is 1 month
RBCLimit = -999999999; %-999999999 or 1 (if 1 will be modified in logic below)
ICLimit = -999999999; % -999999999 0.4;
illiquidLimit = -999999999; % this will remove the constraint from the optimization; initial value if binding = 0.33
liquidationLimit = -999999999; % 
capCons.opt = false; % true false % capacity constraints?
if strcmp(client,'L&R') && strcmp(riskType,'Intrinsic')
    varianceTarget = (0.08035^2); % in annual units
elseif strcmp(client,'GI') && strcmp(riskType,'Intrinsic')
    varianceTarget = (0.08225^2); % in annual units
elseif strcmp(client,'L&R') && strcmp(riskType,'Accounting')
    varianceTarget = (0.06986^2); % in annual units
elseif strcmp(client,'GI') && strcmp(riskType,'Accounting')
    varianceTarget = (0.06263^2); % in annual units
end 
% conditional variables:
if strcmp(client,'L&R') && RBCLimit>0
   RBCLimit = 0.27; % 
   ICLimit = 0.28;
   liquidationLimit = 3.0; % 
%   illiquidLimit = 0.2;
elseif RBCLimit>0 % 'GI' case
   RBCLimit = 0.04; % 
   ICLimit = 0.32;
   liquidationLimit = 4.0; %-999999999; % this will remove the constraint from the optimization; initial value if binding = 2.5
%   illiquidLimit = 0.35;
end 

%  Perturbations section:
% RBCLimit = 1.25*RBCLimit;
% liquidationLimit = 0.8*liquidationLimit;

if strcmp(utilityFunction,'Power')
   utilityParam = 1.5; % 1.5 if gamma; 1.0 if lambda for mean var (results in vol of 6% for AIG intrinsic view); more risk averse than long
   if strcmp(riskType,'Intrinsic')
      shrinkageRP = 2.1e-02; %2.1e-02; %0.02 is roughly parametrized to give this moderate but meaningful impact for i
   else % 'Accounting'
      shrinkageRP = 1.5e-02;
   end 
end 
%RiskAssetAllocationJC(assetView,filePath,rebalPeriods,utilityFunction,utilityParam,shrinkageRP,longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,riskType,client);
%RiskAssetAllocation2(assetView,filePath,rebalPeriods,utilityFunction,utilityParam,shrinkageRP,longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,riskType,client);
%RiskAssetAllocationJC_10(assetView,filePath,rebalPeriods,utilityFunction,utilityParam,shrinkageRP,longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,riskType,client);
% This function used for the Aug 2020 version of the analysis:
%RiskAssetAllocation2_10(assetView,filePath,rebalPeriods,utilityFunction,utilityParam,shrinkageRP,longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,capCons,riskType,client);

% This version used for the SAA analysis of MSR:
RiskAssetAllocation2_12(assetView,filePath,rebalPeriods,utilityFunction,utilityParam,shrinkageRP,longOnly,liquidationLimit,RBCLimit,ICLimit,illiquidLimit,varianceTarget,capCons,riskType,client);

% Simple plot of utility function: 
x = 0.01:0.0025:0.1;
y = zeros(1,length(x)); 
gamma = 1.5;
for i = 1:length(x)
  y(i) = 20+((x(i))^(1-gamma))/(1-gamma); 
end
figure(2); plot(x,y); grid;
xlabel('rtn'); ylabel('U(rtn)')

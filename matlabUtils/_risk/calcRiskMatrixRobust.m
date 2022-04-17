function [omega, vol, rho] = calcRiskMatrixRobust(assetData,assetPxData,riskConfig)
% inputs: 
% assetData.close            = returns data you will be estimating the
%                              var-cov of, from signal returns
% assetPxData.close          = returns data you will be estimating the
%                              var-cov of, from pricing returns [can't use
%                              last data point 't': not available on trading
%                              day]

% riskConfig.corrShrinkFactor = shrinkage factor to apply to off-diags, between 0 and 1 
% riskConfig.corrHL1          = fast half-life for correlation matrix, matrix 1 
% riskConfig.corrHL2          = slow half-life for correlation matrix, matrix 2 
% riskConfig.corrAlpha        = mixing factor for fast and slow corr matrices
% riskConfig.volRangeHL       = half life param if you're using daily range
%                              to comput on-diags (variances), matrix 1
% riskConfig.volRangeHL2      = half life param if you're using daily range
%                              to comput on-diags (variances), matrix 2
% riskConfig.volCloseHL       = half life param if you're using daily closes
%                              to comput on-diags (variances), matrix 1
% riskConfig.volCloseHL2      = half life param if you're using daily closes
%                              to comput on-diags (variances), matrix 2
% riskConfig.volAlpha         = mixing factor for fast and slow variance
%                              estimates
% riskConfig.volMethod        = 'mixedEWA', 'closeEWA', or 'dailyRangeEWA'
config1 = rmfield(riskConfig,{'corrHL2'; 'volRangeHL2'; 'volCloseHL2'});
config2 = config1; 
config2.corrHL = riskConfig.corrHL2; 
config2.volRangeHL = riskConfig.volRangeHL2; 
config2.volCloseHL = riskConfig.volCloseHL2; 

rho1 = calcDynCorrCSRP2(assetData,config1); 
rho2 = calcDynCorrCSRP2(assetData,config2); 
vol1 = calcVolCSRP2(assetData,config1); 
vol2 = calcVolCSRP2(assetData,config2); 
omega1 = calcMixedVarCov(rho1,vol1); 
omega2 = calcMixedVarCov(rho2,vol2); 
vol = riskConfig.volAlpha*vol1 + (1-riskConfig.volAlpha)*vol2; 
rho = riskConfig.corrAlpha*rho1 + (1-riskConfig.corrAlpha)*rho2; 
omega = riskConfig.covAlpha*omega1 + (1-riskConfig.covAlpha)*omega2; 

clear omega1 omega2 rho1 rho2 vol1 vol2;

rho1 = calcDynCorrCSRP2(assetPxData,config1); 
rho2 = calcDynCorrCSRP2(assetPxData,config2); 
vol1 = calcVolCSRP2(assetPxData,config1); 
vol2 = calcVolCSRP2(assetPxData,config2); 
omega1 = calcMixedVarCov(rho1,vol1); 
omega2 = calcMixedVarCov(rho2,vol2); 
volP = riskConfig.volAlpha*vol1 + (1-riskConfig.volAlpha)*vol2; 
rhoP = riskConfig.corrAlpha*rho1 + (1-riskConfig.corrAlpha)*rho2; 
omegaP = riskConfig.covAlpha*omega1 + (1-riskConfig.covAlpha)*omega2; 

end % fn
function [omega, vol, rho] = calcRiskMatrix(assetData,simConfig)
% inputs: 
% assetData.close            = returns data you will be estimating the var-cov of
% simConfig.corrShrinkFactor = shrinkage factor to apply to off-diags, between 0 and 1 
% simConfig.corrHL1          = fast half-life for correlation matrix 
% simConfig.corrHL2          = slow half-life for correlation matrix 
% simConfig.corrAlpha        = mixing factor for fast and slow corr matrices
% simConfig.volRangeHL       = half life param if you're using daily range
%                              to comput on-diags (variances)
% simConfig.volCloseHL       = half life param if you're using daily closes
%                              to comput on-diags (variances)
% simConfig.volAlpha         = mixing factor for fast and slow variance
%                              estimates
% simConfig.volMethod        = 'mixedEWA', 'closeEWA', or 'dailyRangeEWA'
rho = calcDynCorrCSRP(assetData,simConfig); 
vol = calcVolCSRP(assetData,simConfig); 
omega = calcMixedVarCov(rho,vol); 
end % fn
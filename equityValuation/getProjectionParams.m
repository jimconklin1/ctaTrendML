function projParams = getProjectionParams()
readtable('divProjData.csv');
projParams.div.oosDate = divProjData.dates; % oos date begins in 31mar2008 and indicates that all params on that period use data strictly available on or before that date 
% suppose oosDate is length T
projParams.div.equationDesc = {'DIV(t) = DIV(t-1) + (alpha1 + beta1*(EBIT(t)-EBIT(t-1)/EBIT(t-1))+',...
                               'beta2*(EBIT(t-1)-EBIT(t-2)/EBIT(t-2))+ beta3*(EBIT(t-2)-EBIT(t-3)/EBIT(t-3))'};
projParams.div.dataFieldNames = {'IQ_DIV_SHARE','IQ_DIV_SHARE','IQ_EBIT'};
projParams.div.paramNames = {'alpha1','beta1','beta2','beta3','beta4'};
projParams.div.paramValues = divProjData.values; % size T by 5 

readtable('bbbProjData.csv');
projParams.bb.oosDate = bbProjData.dates; % oos date begins in 31mar2008 and indicates that all params on that period use data strictly available on or before that date 
% suppose oosDate is length T
projParams.bb.equationDesc = {'DIV(t) = DIV(t-1) + (alpha1 + beta1*(EBIT(t)-EBIT(t-1)/EBIT(t-1))+',...
                               'beta2*(EBIT(t-1)-EBIT(t-2)/EBIT(t-2))+ beta3*(EBIT(t-2)-EBIT(t-3)/EBIT(t-3))'};
projParams.bb.dataFieldNames = {'IQ_DIV_SHARE','IQ_DIV_SHARE','IQ_EBIT'};
projParams.bb.paramNames = {'alpha1','beta1','beta2','beta3','beta4'};
projParams.bb.paramValues = bbProjData.values; % size T by 5 
end
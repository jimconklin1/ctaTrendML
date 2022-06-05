function table = createExposureTable2(rNames,vNames,hIndx,outStruct)
unpack(outStruct);
yy0 = fExpos.beta(hIndx,5:8);

% compute correlations:
yy = [rtns(:,2:6), factors(:,5:8)]; % all-in correlations
yy1 = corrcoef(yy);
yy1 = yy1(1:5,6:9);

yy = [fExpos.refinedAlphaTS(:,2:6), factors(:,5:8)]; % alpha correlations
yy2 = corrcoef(yy); 
yy2 = yy2(1:5,6:9);

table = array2table([yy0,yy1,yy2],'RowNames',rNames','VariableNames', vNames); 
end
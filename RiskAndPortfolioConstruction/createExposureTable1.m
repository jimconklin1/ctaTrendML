function table = createExposureTable1(rNames,vNames,hIndx,outStruct)
unpack(outStruct);
yy0 = fExpos.beta(hIndx,1:4);

% compute correlations:
yy = [rtns(:,2:6), factors(:,1:4)]; %#ok<IDISVAR,NODEF> % all-in correlations
yy1 = corrcoef(yy);
yy1 = yy1(1:5,6:9);

yy = [fExpos.refinedAlphaTS(:,2:6), factors(:,1:4)]; % alpha correlations
yy2 = corrcoef(yy); 
yy2 = yy2(1:5,6:9); 

table = array2table([yy0,yy1,yy2],'RowNames',rNames','VariableNames', vNames); 
end
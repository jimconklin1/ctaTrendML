validIdx = sum(~isnan(fExpos.refinedAlphaTS(:,hIndx)))>0;
hhIdx = hIndx(validIdx);

sortTbl = array2table(mktValue.style(:,hhIdx)','RowNames',string(hhIdx'),'VariableNames',["Style"]);
sortTbl = sortrows(sortTbl, {'Style'},{'ascend'});

permIdx = cell2mat(arrayfun(@(x) str2num(x), string(sortTbl.Properties.RowNames), 'UniformOutput', false));

covRefined = cov(fExpos.refinedAlphaTS(:,permIdx), 'partialrows');
dR = diag(diag(1./sqrt(covRefined)));
corrRefined = dR*covRefined*dR;

covPrim = cov(fExpos.primaryAlphaTS(:,permIdx), 'partialrows');
dP = diag(diag(1./sqrt(covPrim)));
corrPrim = dP*covPrim*dP;

debugDir = fullfile(outDataDir, "debug");
[~,~] = mkdir(debugDir);

% file 1
m = covRefined;
fn = fullfile(debugDir, "covRefined.csv");

% repeat this block for file2, file3, file4 as well
tbl = array2table(m,'RowNames',string(hHeader(permIdx)'),'VariableNames',tblHeader(hHeader(permIdx)));
tbl = addvars(tbl,mktValue.style(:,permIdx)','Before',tbl.Properties.VariableNames{1}, 'NewVariableNames',"Style");
writetable(tbl, fn, 'WriteRowNames', true);

% file 2
m = corrRefined;
fn = fullfile(debugDir, "corrRefined.csv");

% file 3
m = corrPrim;
fn = fullfile(debugDir, "corrPrim.csv");

% file 4
m = covPrim;
fn = fullfile(debugDir, "covPrim.csv");

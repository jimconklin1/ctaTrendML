PubEqPath.addLibPath('_util', '_data', '_platform', '_database', '_file', '_date');

[filePath,fileName,fileExt] = fileparts(mfilename('fullpath'));
parentDir = normalizePath(fullfile(filePath, '..'));
addpath(parentDir);

% tempTimig = rmNaNs(fExpos.timingRtnMatrix);
fullRefinedAlpha = fExpos.refinedAlphaTS(:,hIndx) % + tempTimig(:,hIndx);

%fullRefinedAlpha = fExpos.totRtns;

% only include long samples in the analysis (for now)
filteredAlpha = fullRefinedAlpha; %(:,sum(~isnan(fExpos.refinedAlphaTS)) > 30);
z1 = sqrt(12)*calcARCHvol(filteredAlpha - nanmean(filteredAlpha), 6, 6);


% try garch/arch MLE fit by Matlab
mdl = garch(0,1);    
mdl_g = garch(1,1);    

assetNum = 6;

% this block can be copy-pasted into command window to execute ARCH/GARCH
% for consecutive assets
mdl = garch(0,1);    
mdl_g = garch(1,1);    
assetNum = assetNum+1;
mdl.estimate(filteredAlpha(:,assetNum)); % , 'display', 'off'
mdl_g.estimate(filteredAlpha(:,assetNum));
% end of block

% res = mdl.summarize();

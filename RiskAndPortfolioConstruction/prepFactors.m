% Raw factor returns are pre-processed for by this script to be used by rapcScript.m. 
% Factor transformations are done based on configuration JSON files in RAPC/factor/cfg sub-directory. 
% The output is written into “factor library” (which is just a directory on disk, out/factor). 
% In the factor library dir, factor returns are saved as CSV 
% and factor definitions (including transformations) are saved as JSON.

PubEqPath.addLibPath('_util','_data','_platform','_database','_file','_date', '_string');
rootPath = getMainScriptDir();
FACTOR_DIRNAME = 'factor';
addpath(fullfile(rootPath, FACTOR_DIRNAME));

outPath = fullfile(PubEqPath.localDataPath(), 'RAPC', FACTOR_DIRNAME); 

factorCfg = loadFactorTransformCfg(fullfile(rootPath, FACTOR_DIRNAME, 'cfg'));

cfg = getRapcConfig();
cfg.endDt = eomdate(datetime("2020-08-01"));
%cfg.startDt = '1990-01-01';
cfg.startDt = '2012-07-01';

coreDb = Env.newPubEqCoreDb();
fctrs = loadRapcFactors(coreDb, cfg);

%factorCfg.getItem('Markit IG CDX NA');
%structToJsonFile(ans, 'abc.txt');

transformed = transformFactors(fctrs.equFactorRtns, factorCfg, cfg.headers.riskFree);
saveFactors(transformed, factorCfg, outPath);

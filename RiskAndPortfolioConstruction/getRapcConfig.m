function cfg = getRapcConfig(cfgName)

cfg.headers.betaHeader = {'MSCIworld','Markit IG CDX NA','BarcGlobalTreas','US Agency MBS'};
cfg.headers.arsHeader = {'msQuality','msValue','msMomentum','msLowBeta'};
cfg.headers.bmHeader = {'HFRX','HFRX Equity','HFRX Event','HFRX CTA Macro', 'HFRX EMN'};
cfg.headers.riskFree = {'USD LIBOR 3M'};
%cfg.opt = 'blockSequential'; 
cfg.factors.blocks = {cfg.headers.betaHeader, cfg.headers.arsHeader};
% cfg.factors.flat = [cfg.headers.betaHeader cfg.headers.arsHeader];
cfg.standAloneBetas = cfg.headers.bmHeader;

numFactors = sum(cellfun(@(x) length(x), cfg.factors.blocks));
cfg.factors.flat = repmat("", 1, numFactors);
blockStart = 1;
for i = 1:length(cfg.factors.blocks)
    blockLen = length(cfg.factors.blocks{i});
    cfg.factors.flat(1,blockStart : blockStart+blockLen-1) = string(cfg.factors.blocks{i});
    blockStart = blockStart+blockLen;
end

cfg.opt.processMV = true;
cfg.opt.processStrategy = true;
cfg.opt.processBenchmark = true;
cfg.opt.processReturnAttribution = true;
cfg.opt.autoTrimReturns = false;
cfg.opt.regression.dwstat = true;
cfg.adjustForTiming = true;
cfg.saveToDb = false;

if exist('cfgName', 'var') && cfgName ~=""
    if (cfgName == "EH")
        cfg.opt.processMV = false;
        cfg.opt.processBenchmark = false;
        cfg.opt.processReturnAttribution = false;
        cfg.opt.autoTrimReturns = true;
        cfg.opt.regression.dwstat = false;
    end
    cfg.dataSrc = cfgName;
else    
    cfg.dataSrc = "";
end % if


end
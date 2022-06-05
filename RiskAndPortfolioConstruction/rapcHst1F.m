% https://share.connect.aig/teams/PubEqInv/Shared Documents/Code/RAPC/rapcHst1F.m.docx

PubEqPath.addLibPath('_util', '_data', '_platform', '_database', '_file', '_date');

dbi = Env.dbConnections().pubEqCore; 
coreDb = PubEqCoreDb(dbi);

companyFilter = "";
cfg = getRapcConfig();
if companyFilter ~=""
    finalSubDir = companyFilter;
else
    finalSubDir = "All";
end    
outDataDir = fullfile(PubEqPath.localDataPath(), 'RAPC', 'output', 'History_1F', finalSubDir); 

if companyFilter == "All"
    periodFrom = eomdate(datetime('2018-07-01'));
else    
    periodFrom = eomdate(datetime('2016-04-01'));
end % if 
cfg.endDt = '2020-03-01';

src = loadRapcDb(coreDb, cfg, companyFilter); 
%src = preProcRapcInput(src, cfg);

if ~isequal(src.equHFrtns.header, src.mktValue.header)
    throw(MException('Data:Invalid', 'Fund headers for Market values and returns don''t align'));
end %if    
if src.equHFrtns.dates(1) ~= src.mktValue.dates(1)
    throw(MException('Data:Invalid', 'Start date doesn''t align between MVs and Returns'));
end %if    
if src.equHFrtns.dates(1) ~= src.equFactorRtns.dates(1)
    throw(MException('Data:Invalid', 'Start date doesn''t align between Returns and Factor Returns'));
end %if    

fundFilter = ~startsWith(src.equHFrtns.header, "aigHF"); %remove composite "fund"
src.mktValue = ourTimeSeriesColSubset(src.mktValue, fundFilter);
src.equHFrtns = ourTimeSeriesColSubset(src.equHFrtns, fundFilter);

% This block can be removed without affecting the result, but it makes it
% easier to navigate the universe of funds.
% Here we filter out the funds that we have never invested in.
everSubscribedFilter = sum(abs(src.mktValue.values),1)>0;
src.mktValue = ourTimeSeriesColSubset(src.mktValue, everSubscribedFilter);
src.equHFrtns = ourTimeSeriesColSubset(src.equHFrtns, everSubscribedFilter);

startIdx =  find(src.mktValue.dates >= datenum(periodFrom), 1, 'first');
endIdx = length(src.mktValue.dates);

eqIdx = strcmp(cfg.headers.betaHeader(1), src.equFactorRtns.header); 
eq = src.equFactorRtns.values(:,eqIdx);
rfrIdx = strcmp(cfg.headers.riskFree, src.equFactorRtns.header); 
rfr = src.equFactorRtns.values(:,rfrIdx);

% We are doing this because these will only be analyzed in the "aggreagated" 
% form, that is, after they are summed up using portfolio weights.
src.equHFrtns.values(isnan(src.equHFrtns.values))=0;
src.mktValue.values(isnan(src.mktValue.values))=0;

eq = eq - rfr;

betas = NaN(endIdx - startIdx +1, 2);

for i = startIdx : endIdx
    stats = portfFctr(src.equHFrtns.values, src.mktValue.values, eq, rfr, i);
    betas(i-startIdx+1,:) = stats.tstat.beta;
end %for i

betas(:,1) = betas(:,1) * 12; % convert monthly to annualized returns (alpha)

dateStrs = string(dateToIsoStr(src.mktValue.dates(startIdx : endIdx)));
outData.betas = array2table(betas ...
    ,'RowNames', dateStrs ...
    ,'VariableNames', ["Alpha", "Beta"]); 
tblStruct2csvSet(outData, outDataDir);



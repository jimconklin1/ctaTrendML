PubEqPath.addLibPath('_util', '_data', '_platform', '_database');

% inDataDir = 'M:\Manager of Managers\Hedge\quantDev\DATA\RAPC\'; 
inDataDir = fullfile(PubEqPath.dataPath(), 'RAPC'); 
outDataDir = fullfile(PubEqPath.dataPath(), 'RAPC'); 
% outDataDir = fullfile(PubEqPath.localDataPath(), 'RAPC'); 

%outStruct = fetchRAPCdataStructures(dataDir,{'monthlyEquityARPandHFdata201902.mat'});

outStruct = loadRapcFile(inDataDir, {'monthlyEquityARPandHFdata201902_wSPX.mat'});
unpack(outStruct); % equHFrtns,equFactorRtns, mktVal

% clean data:
hfStartDates = findFirstGood(equHFrtns.values,0,[]); 
equHFrtns.startDates = hfStartDates;
mm = find(strcmp({'USD_LIBOR_3M'},equFactorRtns.header));
rfr = equFactorRtns.values(:,mm);  %#ok<FNDSB>
mm = find(strcmp({'SPX_TR'},equFactorRtns.header));
spx = equFactorRtns.values(:,mm); 
tmpRtns = equHFrtns.values; 
strIndx = mapStrings(mktValue.header,equHFrtns.header,false);
tempMktVal = mktValue.giValues(end,strIndx);
giWts = [0,tempMktVal(end,2:end)/tempMktVal(end,1)]; 
ahacWts = mktValue.ahacValues; % note, ins co "xxValues" fields are actually weights... not consistent
lexWts = mktValue.lexValues; % note, ins co "xxValues" fields are actually weights... not consistent
nuficWts = mktValue.nuficValues; % note, ins co "xxValues" fields are actually weights... not consistent
t0 = find(equHFrtns.dates>=mktValue.dates(1),1,'first'); 
dates = equHFrtns.dates(t0:end,:); 
tmpRtns = tmpRtns(t0:end,:); 
rfr = rfr(t0:end,:); 
tt0 = find(equFactorRtns.dates>=mktValue.dates(1),1,'first'); 
spx = spx(tt0:end,:); 
tr1 = tmpRtns*giWts'-rfr;
tr2 = tmpRtns*ahacWts'-rfr;
tr3 = tmpRtns*lexWts'-rfr;
tr4 = tmpRtns*nuficWts'-rfr;
stats1 = regstats(tr1,spx,'linear',{'tstat','fstat','rsquare','dwstat','r'});
stats2 = regstats(tr2,spx,'linear',{'tstat','fstat','rsquare','dwstat','r'});
stats3 = regstats(tr3,spx,'linear',{'tstat','fstat','rsquare','dwstat','r'});
stats4 = regstats(tr4,spx,'linear',{'tstat','fstat','rsquare','dwstat','r'});
alphaTS1 = stats1.tstat.beta(1)+stats.r;
betaTS1 = stats1.tstat.beta(2)*spx; 
alphaTS2 = stats2.tstat.beta(1)+stats.r;
betaTS2 = stats2.tstat.beta(2)*spx; 
alphaTS3 = stats3.tstat.beta(1)+stats.r;
betaTS3 = stats3.tstat.beta(2)*spx; 
alphaTS4 = stats4.tstat.beta(1)+stats.r;
betaTS4 = stats4.tstat.beta(2)*spx; 

outStruct = preProcRapcInput(outStruct);
%struct2csv(rapcInput, 'C:\tmp\diff\rapc_1.csv')

[T,N] = size(rtns); 
[~,M] = size(factors); 
% This line is here to silence a Java warning when database connection 
% is created when the script is re-run from Matlab GUI
clear java; %#ok<CLJAVA>

[filePath,fileName,fileExt] = fileparts(mfilename('fullpath'));
addpath(fullfile(filePath, '..', 'matlabUtils', '_util'));

gitDir = normalizePath(filePath, '..');
rootDir = normalizePath(gitDir, '..');

%cd 'H:\research\GIT\hfFactorModel'; 
%dataDir = 'H:\research\DATA\hfFactorModel\'; 
%addpath 'H:\research\GIT\matlabUtils\_data'; 
addpath (fullfile(rootDir, 'GIT', 'matlabUtils', '_data'));
cd (fullfile(rootDir, 'GIT', 'hfFactorModel')); 
dataDir = fullfile(rootDir, 'DATA', 'hfFactorModel');
load(fullfile(dataDir,'monthlyEquityARPandHFdata201812.mat')); % monthlyEquityARPandHFdata201812est.mat; varnames: equHFrtns equFactorRtns mktValue
% save H:\research\DATA\hfFactorModel\monthlyEquityARPandHFdata201812.mat equHFrtns equFactorRtns mktValue;
hfStartDates = findFirstGood(equHFrtns.values,0,[]); 
equHFrtns.startDates = hfStartDates;
% dbConn = getOracleDb(); 

% queryStr = ['select * from data_table_directory' ...
%             ' where table_display_name_key = ''MODEL_FACTOR_' model '_1'''];
% tableName = readDbQuery(dbConn, queryStr);

% % Load the list of funds and factors (mixed; factors are 7 last columns)
% fundDS = select(dbConn,'SELECT inst_id, inst_name from arp.hf_funds_factors_for_rtn_v');
% 
% % Map database fund ID to sequence number for filling out the returns matrix
% InvID_to_Idx = containers.Map(fundDS.INST_ID, 1:length(fundDS.INST_ID));
% 
% % this is what used to be the "header" in the original data set
% header = fundDS.INST_NAME.';
% 
% monthTo = '2018-08';
% retSQLStr = ['select * from table(arp.hf_return.hf_monthly_return(date ''' ...
%              , monthTo, '-01' , '''))' ];
% 
% datesDS = select(dbConn,'SELECT dt from table(arp.hf_return.monthend_dates(date ''' , monthTo, '-01''))');
% 
% % this is what used to be "dates" in the original set
% dates = datenum(datesDS.DT);
% 
% retDS = select(dbConn, retSQLStr);
% 
% rtns = zeros(length(dates), length(fundDS.INST_ID));
% 
% % fill in "rtns" matrix from the Oracle data set.
% dbRecNum = 1;
% colNum = 1;
% oldInstId = retDS.INST_ID(1)-10000;
% for recNum =1 : length(retDS.INST_ID)
%     instId = retDS.INST_ID(recNum);
%     if (instId ~= oldInstId)
%         colNum = InvID_to_Idx(instId);
%         lineNum = 1;
%         oldInstId = instId;
%     end
%     
%     rtns(lineNum, colNum) = retDS.RTN_FRAC(recNum);
%     
%     lineNum = lineNum+1;
% end

% By now we have "header", "dates", and "rtns" loaded.
% TODO: Dmitriy needs to replace NaNs with zeroes for compatibility with
% existing script (although NaNs are arguably better because we won't have
% "magic numbers" in our code, and could handle legitimate zero returns correctly.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      database section end     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %------------------
% 
% addpath (fullfile(root_dir, 'GIT/matlabUtils/_data'));
% cd (fullfile(root_dir, 'GIT/hfFactorModel')); 
% dataDir = fullfile(root_dir, 'DATA/hfFactorModel');
% load(fullfile(dataDir,'monthlyEquityARPandHFdata.mat')); % varname: equHFrtns


% HACKS: rendering market factors mutually orthogonal
temp = 3.5*(equFactorRtns.values(:,2)-.09125*equFactorRtns.values(:,1));
equFactorRtns.values(:,2) = temp; 
temp = 1.15*(equFactorRtns.values(:,4)-.225*equFactorRtns.values(:,3));
equFactorRtns.values(:,4) = temp; 

% Create aggregate return series for: bckstCrrntPrtfl; bckstEquityLS; bckstQuantMacro; bckstEventDr; bckstOpportunistic; 
tmpRtns = equHFrtns.values; 
strIndx = mapStrings(mktValue.header,equHFrtns.header);
tempMktVal = mktValue.values(end,strIndx);
hfStyleWts = zeros(5,1); 
hfStyleMktVal = zeros(5,1); 
hfWts = [0,tempMktVal(1,2:end)]/sum(tempMktVal(1,2:end)); 
equityLSwts = zeros(size(hfWts));
macroWts = zeros(size(hfWts));
eventDrivenWts = zeros(size(hfWts));
opportunisticWts = zeros(size(hfWts));
tmpIndx = find(strcmp(mktValue.style,{'L-S_equity'})); 
hfStyleWts(1) = 1;
hfStyleMktVal(1) = tempMktVal(1,1);
hfStyleWts(2) = sum(hfWts(1,tmpIndx)); 
hfStyleMktVal(2) = sum(tempMktVal(1,tmpIndx));
equityLSwts(1,tmpIndx) = hfWts(1,tmpIndx)/hfStyleWts(2); 
tmpIndx = find(strcmp(mktValue.style,{'GlobalMacro'})); 
hfStyleWts(3) = sum(hfWts(1,tmpIndx)); 
hfStyleMktVal(3) = sum(tempMktVal(1,tmpIndx));
macroWts(1,tmpIndx) = hfWts(1,tmpIndx)/hfStyleWts(3); 
tmpIndx = find(strcmp(mktValue.style,{'EventDriven'})); 
hfStyleWts(4) = sum(hfWts(1,tmpIndx)); 
hfStyleMktVal(4) = sum(tempMktVal(1,tmpIndx));
eventDrivenWts(1,tmpIndx) = hfWts(1,tmpIndx)/hfStyleWts(4); 
tmpIndx = find(strcmp(mktValue.style,{'Opportunistic'})); 
hfStyleWts(5) = sum(hfWts(1,tmpIndx)); 
hfStyleMktVal(5) = sum(tempMktVal(1,tmpIndx));
opportunisticWts(1,tmpIndx) = hfWts(1,tmpIndx)/hfStyleWts(5); 
tr = tmpRtns*hfWts';
tr(:,2) = tmpRtns*equityLSwts';
tr(:,3) = tmpRtns*macroWts';
tr(:,4) = tmpRtns*eventDrivenWts';
tr(:,5) = tmpRtns*opportunisticWts';
hHeader = [equHFrtns.header(1,1),{'aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},equHFrtns.header(1,2:end)]; 
rtns = [tmpRtns(:,1), tr, tmpRtns(:,2:end)]; 

% re-name factor variables, compute some params:
factors = equFactorRtns.values; 
fHeader = equFactorRtns.header;
volsHF = sqrt(12)*std(rtns)';
volsFact = sqrt(12)*std(factors)';
%sigma = cov(equHFrtns.values);
%rho = corrcoef(equHFrtns.values);
t0 = find(equHFrtns.dates>=mktValue.dates(1),1,'first'); 
rtnsLong = rtns;
rtns = rtns(t0:end,:); 
tt0 = find(equFactorRtns.dates>=mktValue.dates(1),1,'first'); 
factorsLong = factors;
factors = factors(tt0:end,:); 
mm = find(strcmp({'USD_LIBOR_3M'},fHeader)); 
rfr = factors(:,mm); 
clear mm;
[T,N] = size(rtns);
[~,M] = size(factors);

fConfig.betaHeader = {'MSCIworld','US_CDX_IG_5yr','BarcGlobalTreas','US_Agency_MBS'};
fConfig.arsHeader = {'dbQuality','dbValue','dbMomentum','dbLowBeta'};
fConfig.bmHeader = {'HFRX ','HFRX_Equity','HFRX_Event','HFRX_CTA_Macro'};
opt = 'blockSequential'; 
fExpos = computeFactorExposures2(hHeader,rtns,fHeader,factors,fConfig,opt);

% YOU ARE HERE: incorporate fExpos into risk calc, report-writing code
% below:

% performance assumptions,
%     E[SR] E[vol] correlations:
rNames = {'MSCI_Wrld','US_IG5yrCDX','US_10yr','US_MBS','ARP_eqGlobQual','ARP_eqGlobVal','ARP_eqGlobMom','ARP_eqGlobLowVol'};
vNames = {'E_SR','E_vol','corr1','corr2','corr3','corr4','corr5','corr6','corr7','corr8'};
%      E_SRs:                                          E_vols:
xx = [[0.35; 0.3; 0.2; 0.25; 0.4; 0.4; 0.4; 0.4],[0.15; 0.02; 0.05; 0.025; 0.03; 0.05; 0.08; 0.08]];
wtsARP = [0.35, 0.25, 0.2, 0.2];
corrMat = corrcoef(factors(:,1:8)); 
omega = corr2cov(xx(:,2),corrMat);
xx0 = [xx,corrMat];
perfAssTable = array2table(xx0,'RowNames',rNames,'VariableNames',vNames); 
alphaDecay = 0.5;

% Computations for Table 2: cols Rel Wt	($mm) E[SR]	E[SR_?]	E[ARP] E[SR_?] E[vol] E[vol_?] E[vol_ARP] E[vol_?]
%nn = mapStrings({'aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},hHeader); 
rNames = {'FullHFportfolio','EquityLS_HFs','GlobMacroQuant_HFs','EventDriven_HFs','Opportunistic_HFs','ARP','eqGlobQual','eqGlobVal','eqGlobMom','eqGlobLowVol','MSCI_Wrld','US_IG5yrCDX','US_MBS','US_10yr'};
vNames = {'RelWts','MktVal','E_SR','E_SR_beta','E_SR_ARP','E_SR_alpha','E_vol','E_vol_beta','E_vol_ARP','E_vol_alpha'}; 
xx2 = zeros(14,10);
xx2(1:5,1) = hfStyleWts'; 
xx2(1:5,2) = hfStyleMktVal';

% now E_SR column 3: overall
hIndx = mapStrings({'lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},hHeader); 
fIndx = 1:8; 
E_rtn = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR.*perfAssTable.E_vol)+alphaDecay*12*fExpos.alpha(hIndx,1); 
hfStyleFactorVarCov = fExpos.beta(hIndx,fIndx)*omega*fExpos.beta(hIndx,fIndx)'; 
aTemp = fExpos.alphaTS(:,hIndx); aTemp(aTemp==0) = NaN; 
hfAlphaVarCov = 12*nancov(aTemp); 
hfStyleVol = (diag(hfStyleFactorVarCov+hfAlphaVarCov)).^.5; 
clear hIndx fIndx;

E_rtn(2:5,1) = E_rtn; 
hfStyleVol(2:5,1) = hfStyleVol; 
E_rtn(1,1) = E_rtn(2:5,1)'*hfStyleWts(2:5,1);
hfStyleVol(1,1) = (hfStyleWts(2:5,1)'*(hfStyleFactorVarCov+hfAlphaVarCov)*hfStyleWts(2:5,1))^.5;
E_rtn(6,1) = (ones(1,4)/4)*(perfAssTable.E_SR(5:8,:).*perfAssTable.E_vol(5:8,:));
hfStyleVol(6,1) = (wtsARP*omega(5:8,5:8)*wtsARP')^.5;
xx2(1:6,3) = (E_rtn)./hfStyleVol; % Sharpe ratio; E_rtn is actually expected excess return, built up from E[SR]
xx2(7:14,3) = [perfAssTable.E_SR(5:8,:); perfAssTable.E_SR(1:4,:)];

% now E[vol] column 7: total
xx2(1:6,7) = hfStyleVol; 
xx2(7:14,7) = [perfAssTable.E_vol(5:8,:); perfAssTable.E_vol(1:4,:)];

% now E[SR_?] column 4: market betas
hIndx = mapStrings({'lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},hHeader); 
fIndx = mapStrings({'MSCIworld','US_CDX_IG_5yr','BarcGlobalTreas','US_Agency_MBS'},fHeader); 
E_rtn = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR(fIndx,1).*perfAssTable.E_vol(fIndx,1)); 
hfStyleFactorVarCov = fExpos.beta(hIndx,fIndx)*omega(fIndx,fIndx)*fExpos.beta(hIndx,fIndx)';
hfStyleVol = (diag(hfStyleFactorVarCov)).^.5;
clear hIndx fIndx;

E_rtn(2:5,1) = E_rtn; 
hfStyleVol(2:5,1) = hfStyleVol; 
E_rtn(1,1) = E_rtn(2:5,1)'*hfStyleWts(2:5,1);
hfStyleVol(1,1) = (hfStyleWts(2:5,1)'*(hfStyleFactorVarCov)*hfStyleWts(2:5,1))^.5;
xx2(1:5,4) = E_rtn./hfStyleVol; % Sharpe ratio; E_rtn is actually expected excess return, built up from E[SR]
xx2(6:10,4) = NaN; 
xx2(11:14,4) = perfAssTable.E_SR(1:4,1); 

% now E[vol] column 8: vol due to market beta
xx2(1:5,8) = hfStyleVol; 
xx2(6:10,8) = NaN; 
xx2(11:14,8) = perfAssTable.E_vol(1:4,1); 

% now E[SR_ARS] column 5: ARP betas
hIndx = mapStrings({'lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},hHeader); 
fIndx = mapStrings({'dbQuality','dbValue','dbMomentum','dbLowBeta'},fHeader); 
E_rtn = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR(fIndx,1).*perfAssTable.E_vol(fIndx,1)); 
hfStyleFactorVarCov = fExpos.beta(hIndx,5:8)*omega(5:8,5:8)*fExpos.beta(hIndx,5:8)';
hfStyleVol = (diag(hfStyleFactorVarCov)).^.5;
clear hIndx fIndx;

E_rtn(2:5,1) = E_rtn; 
hfStyleVol(2:5,1) = hfStyleVol; 
E_rtn(1,1) = E_rtn(2:5,1)'*hfStyleWts(2:5,1);
hfStyleVol(1,1) = (hfStyleWts(2:5,1)'*(hfStyleFactorVarCov)*hfStyleWts(2:5,1))^.5;
E_rtn(6,1) = wtsARP*(perfAssTable.E_SR(5:8,:).*perfAssTable.E_vol(5:8,:));
hfStyleVol(6,1) = (wtsARP*omega(5:8,5:8)*wtsARP')^.5;
xx2(1:6,5) = E_rtn./hfStyleVol; % Sharpe ratio; E_rtn is actually expected excess return, built up from E[SR]
xx2(7:10,5) = perfAssTable.E_SR(5:8,:); 
xx2(11:14,5) =  NaN;

% now E[vol] column 9: vol due to ARP beta
xx2(1:6,9) = hfStyleVol; 
xx2(7:10,9) = perfAssTable.E_vol(5:8,1); 
xx2(11:14,9) =  NaN;

% now E[SR_?] column 6: alpha
E_rtn = alphaDecay*12*fExpos.alpha(2:5,1);
hfStyleVol = (diag(hfAlphaVarCov)).^.5; 
E_rtn(2:5,1) = E_rtn; 
hfStyleVol(2:5,1) = hfStyleVol; 
hfStyleVol(1,1) = (hfStyleWts(2:5,1)'*(hfAlphaVarCov)*hfStyleWts(2:5,1))^.5;
xx2(1:5,6) = E_rtn./hfStyleVol; 
xx2(6:14,6) = NaN;

% now E[vol] column 10: vol due to alpha
xx2(1:5,10) = hfStyleVol; 
xx2(6:14,10) = NaN;

expPerformanceTable1 = array2table(xx2,'RowNames',rNames','VariableNames',vNames); 

% Table 2b: exposure analysis for individual managers
% Computations for Table 2b: cols RelWt, mktVal($mm) E[SR]	E[SR_beta]	E[SR_ARP] E[SR_alpha] E[vol] E[vol_beta] E[vol_ARP] E[vol_alpha]
tempSet = setdiff(hHeader,{'aigHFhist','aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},'stable'); 
hIndx = mapStrings(tempSet,hHeader); 
%H = length(hIndx); 
rNames = hHeader(hIndx); 
vNames = {'RelWts','MktVal','E_SR_tot','SR_tot_Smpl','SR_tot_2y','E_SR_beta','E_SR_ARP','SR_alpha_Smpl','SR_alpha_Last2y','E_SR_alpha',...
          'E_vol_tot','E_vol_beta','E_vol_ARP','E_vol_alpha',...
          'B_msciWrld','B_usCDX','B_us10y','B_usMtg','B_quality','B_value','B_mom','B_lowVol',...
          'alphaHist','corrHist','diversifyingAlpha','alpha2y','corr2y','diversifyingAlpha2yr'}; 
xx3 = zeros(length(hIndx),26);
% cols 1 and 2: rel weight in current portfolio, $ mkt value in current portfolio:
hhIndx = mapStrings(tempSet,mktValue.header,false); % re-map, just in case headers are differently ordered in mktValue data structure
tempMktVal = mktValue.values(end,hhIndx); 
hfWts = tempMktVal(1,:)/sum(tempMktVal(1,:)); 
xx3(:,1) = hfWts'; 
xx3(:,2) = tempMktVal'; 
tempRtns = rtns(:,hIndx); 
tempRtns(tempRtns==0) = NaN;
rtn_tot_smpl = 12*nanmean(tempRtns); 
rtn_tot_2y = 12*nanmean(tempRtns(end-23:end,:)); 
vol_tot_smpl = sqrt(12)*nanstd(tempRtns); 
vol_tot_2y = sqrt(12)*nanstd(tempRtns(end-23:end,:)); 
% Raw historical SRs, columns 3,4:
xx3(:,3) = rtn_tot_smpl./vol_tot_smpl;
xx3(:,4) = rtn_tot_2y./vol_tot_2y; 

% E_SR column overall, 5:
%fIndx = 1:8; 
fIndx = mapStrings({'MSCIworld','US_CDX_IG_5yr','BarcGlobalTreas','US_Agency_MBS','dbQuality','dbValue','dbMomentum','dbLowBeta'},fHeader); 
E_rtn = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR.*perfAssTable.E_vol)+alphaDecay*12*fExpos.alpha(hIndx,1); 
hfStyleFactorVarCov = fExpos.beta(hIndx,fIndx)*omega(fIndx,fIndx)*fExpos.beta(hIndx,fIndx)'; 
aTemp = fExpos.alphaTS(:,hIndx); aTemp(aTemp==0) = NaN; 
hfAlphaVarCov = 12*nancov(aTemp); 
hfEvol = (diag(hfStyleFactorVarCov+hfAlphaVarCov)).^.5; 
xx3(:,5) = E_rtn./hfEvol; 
clear fIndx;

% E[SR_beta], columns 6: 
fIndx = mapStrings({'MSCIworld','US_CDX_IG_5yr','BarcGlobalTreas','US_Agency_MBS'},fHeader); 
E_rtn_beta = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR(fIndx,1).*perfAssTable.E_vol(fIndx,1)); 
%E_rtn = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR.*perfAssTable.E_vol); 
hfStyleFactorVarCov = fExpos.beta(hIndx,fIndx)*omega(fIndx,fIndx)*fExpos.beta(hIndx,fIndx)'; 
hfFactorVol = (diag(hfStyleFactorVarCov)).^.5; 
xx3(:,6) = E_rtn_beta./hfFactorVol; 
clear fIndx;

% E_vol overall, column 11:
xx3(:,11) = hfEvol;
% E_vol market betas, column 12:
xx3(:,12) = hfFactorVol;
% Betas, cols 15-22: 
fIndx = 1:8; 
xx3(:,15:22) = fExpos.beta(hIndx,fIndx); 
clear fIndx;

% now E[SR_ARS] column 7: ARP betas 
fIndx = mapStrings({'dbQuality','dbValue','dbMomentum','dbLowBeta'},fHeader); 
E_rtn_arp = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR(fIndx,1).*perfAssTable.E_vol(fIndx,1)); 
hfStyleFactorVarCov = fExpos.beta(hIndx,fIndx)*omega(fIndx,fIndx)*fExpos.beta(hIndx,fIndx)';
hfStyleVol = (diag(hfStyleFactorVarCov)).^.5;
xx3(:,7) = E_rtn_arp./hfStyleVol; 
% E_vol ARP factors, column 13:
xx3(:,13) = hfStyleVol;
clear fIndx;

% hist SR_alpha and E[SR_alpha] column 8:
%E_rtn = alphaDecay*12*fExpos.alpha(hIndx,1); 
temp1 = 12*mean(fExpos.alphaTS(:,hIndx))'; 
temp2 = 12*mean(fExpos.alphaTS(end-23:end,hIndx))'; 
if temp2 > temp1
   E_rtn_alpha = alphaDecay*temp1;
else
   E_rtn_alpha = alphaDecay*(temp1+temp2)/2;
end 
hfEalphaVol = (diag(hfAlphaVarCov)).^.5; 
xx3(:,8) = temp1./hfEalphaVol; 
xx3(:,9) = temp2./hfEalphaVol; 
xx3(:,10) = E_rtn_alpha./hfEalphaVol; 
% E[SR_alpha] column 12:
xx3(:,14) = hfEalphaVol; 

% divAlpha, column 23-28: SR_alpha_i - rho(i,restOfPort)*SR_restOfPort
% first, compute correlation of i-th alpha to restOfPort: 
hh=find(strcmp(hHeader,{'aigHFbkcst'}));
temp = fExpos.alphaTS(:,[hh,hIndx]);
tempCorr = corrcoef(temp);
tempCorr2y = corrcoef(temp(end-23:end,:)); clear temp;
tempSRi = sqrt(12)*mean(fExpos.alphaTS(:,hIndx))./std(fExpos.alphaTS(:,hIndx)); 
tempSRport = sqrt(12)*mean(fExpos.alphaTS(:,hh))./std(fExpos.alphaTS(:,hh)); 
tempSRi2y = sqrt(12)*mean(fExpos.alphaTS(end-23:end,hIndx))./std(fExpos.alphaTS(end-23:end,hIndx)); 
tempSRport2y = sqrt(12)*mean(fExpos.alphaTS(end-23:end,hh))./std(fExpos.alphaTS(end-23:end,hh)); 
tempDivAlpha = tempSRi' - tempCorr(2:end,1)*tempSRport;
tempDivAlpha2y = tempSRi2y' - tempCorr2y(2:end,1)*tempSRport2y;
xx3(:,23:28) = [tempSRi',tempCorr(2:end,1),tempDivAlpha, tempSRi2y', tempCorr2y(2:end,1), tempDivAlpha2y];

expPerformanceTable2 = array2table(xx3,'RowNames',rNames','VariableNames',vNames); 
hhIndx = mapStrings(rNames,mktValue.header); 
Strategy = mktValue.style(1,hhIndx)'; 
expPerformanceTable2 = addvars(expPerformanceTable2,Strategy,'Before',vNames{1});
expPerformanceTable2 = sortrows(expPerformanceTable2,'RowNames');
expPerformanceTable2 = sortrows(expPerformanceTable2,{'Strategy'},{'ascend'});

% vNames2 = hHeader(hIndx);
% rNames2 = {'Loading_MSCI_W','Loading_US_CDX','Loading_US10y','Loading_MBS','Loading_Qual','Loading_Value','Loading_Mom','Loading_hiVol',...
%            'CombinedRank','ExpectedSharpe','VolImpliedMaxPositionSize',...
%            'YTD_ROR','2018_ROR','2017_ROR','AnnualizedReturn(24mos)','AnnualizedReturnVol(24mos)','SharpeRatio(24mos)','ExpectedAlphaVol',...
%            'InceptionDate','AnnualizedROR(sinceInception)','AnnualizedSTDEV(sinceInception)','SharpeRatio(sinceInception)','AnnualizedReturn(last24mos)','AnnualizedVol(last24mos)','SharpeRatio(last24mos)','ExpectedAlphaVol',...
%            'InceptionDate','AnnualizedROR(sinceInception)','AnnualizedSTDEV(sinceInception)','SharpeRatio(sinceInception)'}; 
% fIndx = 1:8; 
% xx3b = zeros(length(rNames2),length(hHeader(hIndx)));
% xx3b(1:8,:) = fExpos.beta(hIndx,fIndx)'; 
% E_rtn = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR.*perfAssTable.E_vol)+alphaDecay*12*fExpos.alpha(hIndx,1); 
% hfStyleFactorVarCov = fExpos.beta(hIndx,fIndx)*omega(fIndx,fIndx)*fExpos.beta(hIndx,fIndx)'; 
% aTemp = fExpos.alphaTS(:,hIndx); aTemp(aTemp==0) = NaN; 
% hfAlphaVarCov = 12*nancov(aTemp); 
% hfEvol = (diag(hfStyleFactorVarCov+hfAlphaVarCov)).^.5; 
% xx3b(9,:) = (E_rtn./hfEvol)'; % Expected SR
% expPerformanceTable2b = array2table(xx3b,'RowNames',rNames2','VariableNames',vNames2); 
       

% NOTE: double check this logic for risk-adjusting notional weights:
totRtns = fExpos.totRtns;
totRtns(totRtns==0) = NaN;
alphaRtns = fExpos.alphaTS;
alphaRtns(alphaRtns==0) = NaN;
xx4 = zeros(length(hIndx),12); 
xx4(:,1) = tempMktVal';
xx4(:,2) = 100*hfWts';
xx4(:,3) = 100*sqrt(12)*nanstd(totRtns(end-23:end,hIndx))'; 
xx4(:,4) = 100*sqrt(12)*nanstd(alphaRtns(end-23:end,hIndx))'; 
xx4(:,5) = 100*sqrt(12)*nanstd(totRtns(:,hIndx))'; 
xx4(:,6) = 100*sqrt(12)*nanstd(alphaRtns(:,hIndx))'; 
xx4(:,7) = sqrt(12)*(nanmean(totRtns(:,hIndx))./nanstd(totRtns(:,hIndx)))'; 
xx4(:,8) = sqrt(12)*(nanmean(alphaRtns(:,hIndx))./nanstd(alphaRtns(:,hIndx)))'; 
xx4(:,9) = sqrt(12)*(nanmean(totRtns(end-23:end,hIndx))./nanstd(totRtns(end-23:end,hIndx)))'; 
xx4(:,10) = sqrt(12)*(nanmean(alphaRtns(end-23:end,hIndx))./nanstd(alphaRtns(end-23:end,hIndx)))'; 
a = 0.6;
xx4(:,11) = (xx4(:,5).^a).*(xx4(:,9).^(2-a));
xx4(:,12) = (xx4(:,6).^a).*(xx4(:,10).^(2-a));
vNames = {'marketValue','notionalWeight','volHFtotFullSmpl','volHFtotLast2y','volHFalphaFullSmpl',...
          'volHFalphaLast2y','SRtotFullSmpl','SRHFtotLast2y','SRalphaFullSmpl','SRalphaLast2y',...
          'qualAdjAlphaFullSmpl','qualAdjAlphaLast2y'};
expPerformanceTable3 = array2table(xx4,'RowNames',rNames,'VariableNames',vNames); 
indx = find(expPerformanceTable3.marketValue~=0);
temp = sortrows(expPerformanceTable3(indx,:),'RowNames');
temp  %#ok<NOPTS>
clear hIndx;

% Computations for Table 3a, cols: 
%     		?s all-in					    Correlations all-in				Correlations to alpha			
%  Item		MSCI_W	US_CDX  MBS  US_10y     MSCI_W	US_CDX	MBS	US_10y      MSCI_W	US_CDX	MBS	US_10y
rNames = {'FullHFportfolio','EquityLS_HFs','GlobMacroQuant_HFs','EventDriven_HFs','Opportunistic_HFs'}; % hHeader(nn)';
vNames = {'betaMSCI','beta5yrCDX','beta10yr','betaMBS','corrMSCI','corr5yrCDX','corr10yr','corrMBS','corrAlphMSCI','corrAlph5yrCDX','corrAlph10yr','corrAlphMBS'};

% betas:
hIndx = mapStrings({'aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},hHeader); 
yy0 = fExpos.beta(hIndx,1:4);

% compute correlations:
yy = [rtns(:,2:6), factors(:,1:4)]; % all-in correlations
yy1 = corrcoef(yy);
yy1 = yy1(1:5,6:9);

yy = [fExpos.alphaTS(:,2:6), factors(:,1:4)]; % alpha correlations
yy2 = corrcoef(yy); 
yy2 = yy2(1:5,6:9); 

expsrTable1 = array2table([yy0,yy1,yy2],'RowNames',rNames','VariableNames', vNames); 

% computations for Table 3b, cols: 
%     		?s all-in					    Correlations all-in				Correlations to alpha			
%  Item     Value  Mom  Quality	Low-vol     Value  Mom  Quality	Low-vol     Value  Mom	Quality	Low-vol
vNames = {'betaEqQual','betaEqVal','betaEqMom','betaEqLowVol','corrEqQual','corrEqVal','corrEqMom','corrEqLowVol','corrAlphEqQual','corrAlphEqVal','corrAlphEqMom','corrAlphEqLowVol'};
% betas:
yy0 = fExpos.beta(hIndx,5:8);

% compute correlations:
yy = [rtns(:,2:6), factors(:,5:8)]; % all-in correlations
yy1 = corrcoef(yy);
yy1 = yy1(1:5,6:9);

yy = [fExpos.alphaTS(:,2:6), factors(:,5:8)]; % alpha correlations
yy2 = corrcoef(yy); 
yy2 = yy2(1:5,6:9);

expsrTable2 = array2table([yy0,yy1,yy2],'RowNames',rNames','VariableNames', vNames); 

% tables to print, export to Excel
% perfAssTable
% expPerformanceTable1
% expPerformanceTable2
% expsrTable1
% expsrTable2

% computations for Table 4, cols:
% 	Mkt Val	 Rel Wt     Expected performance                                                      ?s all-in							
%    ($mm)    (%)	    E[SR]  E[SR_?]  E[ARP]  E[SR_?]  E[vol]  E[vol_?]  E[vol_ARP]  E[vol_?]   MSCI_W	US_CDX	MBS	US_10y Value Mom Quality	Low-vol
tmpIndx1 = find(strcmp(mktValue.style,{'L-S_equity'})); 
header4_1 = mktValue.header(tmpIndx1); 
xx4_1 = zeros(length(tmpIndx1),18); 
xx4_1(:,1) = mktValue.values(end,tmpIndx1)'; 
xx4_1(:,2) = hfWts(1,tmpIndx1)'; 

tmpIndx2 = find(strcmp(mktValue.style,{'GlobalMacro'})); 
header4_2 = mktValue.header(tmpIndx2); 
xx4_2 = zeros(length(tmpIndx2),18); 
xx4_2(:,1) = mktValue.values(end,tmpIndx2)'; 
xx4_2(:,2) = hfWts(1,tmpIndx2)'; 

tmpIndx3 = find(strcmp(mktValue.style,{'EventDriven'})); 
header4_3 = mktValue.header(tmpIndx3); 
xx4_3 = zeros(length(tmpIndx3),18); 
xx4_3(:,1) = mktValue.values(end,tmpIndx3)'; 
xx4_3(:,2) = hfWts(1,tmpIndx3)'; 

tmpIndx4 = find(strcmp(mktValue.style,{'Opportunistic'})); 
header4_4 = mktValue.header(tmpIndx4); 
xx4_4 = zeros(length(tmpIndx4),18); 
xx4_4(:,1) = mktValue.values(end,tmpIndx4)'; 
xx4_4(:,2) = hfWts(1,tmpIndx4)'; 

disp(fExpos.beta(1:6,1))

% compute vol of alpha component:
xx0 = fExpos.alphaTS(:,2:6); 
disp([12*mean(xx0); sqrt(12)*std(xx0); 12*mean(xx0)./(sqrt(12)*std(xx0))]')

% compute vol of beta component:
xx1 = [sum(fExpos.betaTS(:,2,1:4),3),sum(fExpos.betaTS(:,3,1:4),3),sum(fExpos.betaTS(:,4,1:4),3),sum(fExpos.betaTS(:,5,1:4),3),sum(fExpos.betaTS(:,6,1:4),3)];
disp(sqrt(12)*std(xx1)')

% compute vol of ARP component:
xx2 = [sum(fExpos.arpTS(:,2,1:4),3),sum(fExpos.arpTS(:,3,1:4),3),sum(fExpos.arpTS(:,4,1:4),3),sum(fExpos.arpTS(:,5,1:4),3),sum(fExpos.arpTS(:,6,1:4),3)];
disp(sqrt(12)*std(xx2)')

% total returns (run check):
xx3a = rtns(:,2:6);
xx3b = xx0+xx1+xx2;
disp(sqrt(12)*std(xx3a)')
disp(sqrt(12)*std(xx3b)')


% aggregate exposures, risk percentages into output tables:
% YOU ARE HERE: 
plot(equHFrtns.dates,calcCum(xx0)); datetick('x','mmm-yy'); grid; title({'totalPrtfl'}); legend({'totRtn','betaRtn','altBetaRtn','alphaRtn'})
plot(equHFrtns.dates,calcCum(xx2)); datetick('x','mmm-yy'); grid; title({'totalPrtfl'}); legend({'totRtn','betaRtn','altBetaRtn','alphaRtn'})


%portfolio.header = {'MSCIworld','value','momentum','quality','lowvol','alpha'};

function ret = createExpectedPerformanceTable2(rNames,tempSet,hIndx,outStruct,perfAssTable, cfg)
unpack(outStruct);

vNames = {'RelWts','MktVal','E_SR_tot','SR_tot_Smpl','SR_tot_2y','E_SR_beta','E_SR_ARP','SR_alpha_Smpl','SR_alpha_Last2y','E_SR_refinedAlpha',...
          'E_vol_tot','E_vol_beta','E_vol_ARP','E_vol_refinedAlpha',...
          'B_msciWrld','B_usCDX','B_us10y','B_usMtg','B_quality','B_value','B_mom','B_lowVol',...
          'alphaHist','corrHist','diversifyingAlpha','alpha2y','corr2y','diversifyingAlpha2yr' ...
          , 'E_SR_primaryAlpha', 'E_vol_primaryAlpha', 'timingMean', 'timingVol', 'vol_AlphaHst' ...
          , 'SR_PrimAlpha_Smpl','SR_PrimAlpha_Last2y', 'E_rtn', 'E_rtn_beta', 'E_rtn_primaryAlpha' ...
          , 'E_rtn_arp', 'E_rtn_refinedAlpha', 'regrAlpha'}; 

if cfg.saveToDb
    csn = outStruct.ref.dim.factorClasses.named;
end 

v_1d = containers.Map;

xx3 = NaN(length(hIndx),41);
if cfg.opt.processMV
    % cols 1 and 2: rel weight in current portfolio, $ mkt value in current portfolio:
    hhIndx = mapStrings(tempSet,mktValue.header,false); % re-map, just in case headers are differently ordered in mktValue data structure
    tempMktVal = mktValue.values(end,hhIndx); 
    hfWts = tempMktVal(1,:)/sum(tempMktVal(1,:)); 
    % vNames(1:5): 'RelWts','MktVal','E_SR_tot','SR_tot_Smpl','SR_tot_2y' 
    xx3(:,1) = hfWts'; 
    v_1d("Portfolio Weight") = hfWts';
    xx3(:,2) = tempMktVal'; 
    v_1d("Market Value") = tempMktVal';
end % cfg.opt.processMV

tempRtns = rtns(:,hIndx);   %#ok<IDISVAR,NODEF>
tempRtns = tempRtns - repmat(rfr,[1,size(tempRtns,2)]); % note, NaNs handle suppression of LIBOR subtraction on missing rtn values
szRtns = size(tempRtns);
offset2y = min(23, szRtns(1)-1);

rtn_tot_smpl = 12*nanmean(tempRtns); 
rtn_tot_2y = 12*nanmean(tempRtns(end-offset2y:end,:)); 
vol_tot_smpl = sqrt(12)*nanstd(tempRtns); 
vol_tot_2y = sqrt(12)*nanstd(tempRtns(end-offset2y:end,:)); 
% Raw historical SRs, columns 3,4:
xx3(:,4) = rtn_tot_smpl./vol_tot_smpl;
xx3(:,5) = rtn_tot_2y./vol_tot_2y; 

fullRefinedAlpha = fExpos.refinedAlphaTS;

% E[SR_beta], columns 6: 
% vNames(6): 'E_SR_beta'    
fIndx = mapStrings(cfg.headers.betaHeader,fHeader); 
E_rtn_beta = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR(fIndx,1).*perfAssTable.E_vol(fIndx,1)); 
%E_rtn = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR.*perfAssTable.E_vol); 
hfStyleFactorVarCov = fExpos.beta(hIndx,fIndx)*omega(fIndx,fIndx)*fExpos.beta(hIndx,fIndx)'; 
hfFactorVol = (diag(hfStyleFactorVarCov)).^.5; 
xx3(:,6) = E_rtn_beta./hfFactorVol; 
xx3(:,37) = E_rtn_beta;
clear fIndx;

% E_vol market betas, column 12:
% vNames(12:14): {'E_vol_beta'}    {'E_vol_ARP'}    {'E_vol_refinedAlpha'}
xx3(:,12) = hfFactorVol;
% Betas, cols 15-22: 
% vNames(15:22): {'B_msciWrld'}    {'B_usCDX'}  {'B_us10y'}    {'B_usMtg'}    {'B_quality'}    {'B_value'}    {'B_mom'}    {'B_lowVol'}
fIndx = 1:8; 
xx3(:,15:22) = fExpos.beta(hIndx,fIndx); 
clear fIndx;

% now E[SR_ARS] column 7: ARP betas 
fIndx = mapStrings(cfg.headers.arsHeader,fHeader); 
E_rtn_arp = fExpos.beta(hIndx,fIndx)*(perfAssTable.E_SR(fIndx,1).*perfAssTable.E_vol(fIndx,1)); 
hfStyleFactorVarCov = fExpos.beta(hIndx,fIndx)*omega(fIndx,fIndx)*fExpos.beta(hIndx,fIndx)';
hfStyleVol = (diag(hfStyleFactorVarCov)).^.5;
% vNames(7): 'E_SR_ARP'    
xx3(:,7) = E_rtn_arp./hfStyleVol; 
xx3(:,39) = E_rtn_arp;

% E_vol ARP factors, column 13:
% vNames(12:14): {'E_vol_beta'}    {'E_vol_ARP'}    {'E_vol_refinedAlpha'}
xx3(:,13) = hfStyleVol;
clear fIndx;

% hist SR_alpha and E[SR_alpha] column 8:
%E_rtn = alphaDecay*12*fExpos.alpha(hIndx,1); 
subsetRefAlphaFullSmpl = fullRefinedAlpha(:,hIndx);
subsetRefAlpha24Mo = fullRefinedAlpha(end-offset2y:end,hIndx); 

meanRefAlphaFullSmpl = 12*nanmean(subsetRefAlphaFullSmpl)'; 
meanRefAlpha24Mo = 12*nanmean(subsetRefAlpha24Mo)'; 

volRefAlphaFullSmpl = sqrt(12)*nanstd(subsetRefAlphaFullSmpl)';
volRefAlpha24Mo = sqrt(12)*nanstd(subsetRefAlpha24Mo)'; 
useArch = false; 
if useArch
    E_vol_refinedAlpha = sqrt(12)*calcARCHvol(subsetRefAlphaFullSmpl - nanmean(subsetRefAlphaFullSmpl), 6, 6)';
else    
    % Note, correlation between vol1 and vol2 over a sample of about 200 funds
    % is 0.95; calculation below is informed by this estimate:
    E_vol_refinedAlpha = sqrt( (0.5*volRefAlphaFullSmpl(:,1)).^2 ...
        + (0.5*volRefAlpha24Mo(:,1)).^2 ...
        + 2*0.5*0.5*0.95*volRefAlphaFullSmpl(:,1).*volRefAlpha24Mo(:,1));  
end %if

%  A leftover code that we used to test ARCH (Exponential average) vs 
%  combination of simple averages from full sample and last 24 months.
% tryArch = true;
% if tryArch
%   E_vol_refinedAlpha_arch = sqrt(12)*calcARCHvol(temp1 - nanmean(temp1), 6, 6);
%   refAlpVol = NaN(2,length(E_vol_refinedAlpha));
%   refAlpVol(1,:) = E_vol_refinedAlpha';
%   refAlpVol(2,:) = E_vol_refinedAlpha_arch;
%   avgVolIncrease = nanmean(E_vol_refinedAlpha_arch ./ E_vol_refinedAlpha');
%   diffHdr = tblHeader(string(strrep(hHeader(hIndx), ' ', '_')));
%   tblVolDiff = array2table(refAlpVol,'RowNames',["Before", "After"]','VariableNames',diffHdr);
%   % tblVolDiff is the variable to look at: line 1 is old vol, line 2 is new
%   % the new vol is greater, by approx sqrt(2) as expected (avgVolIncrease).
% end %if

useRefAlphaFull = (meanRefAlpha24Mo > meanRefAlphaFullSmpl) | isnan(meanRefAlpha24Mo);

E_rtn_refinedAlpha = meanRefAlphaFullSmpl;
E_rtn_refinedAlpha(~useRefAlphaFull) ...
    = ( meanRefAlphaFullSmpl(~useRefAlphaFull) + meanRefAlpha24Mo(~useRefAlphaFull) ) * 0.5;

% new logic
E_rtn_refinedAlpha(E_rtn_refinedAlpha>0) = ... 
    E_rtn_refinedAlpha(E_rtn_refinedAlpha>0) * alphaDecay;

% equivalent of the old logic
%E_rtn_refinedAlpha((E_rtn_refinedAlpha>0) | useRefAlphaFull) = ... 
%    E_rtn_refinedAlpha((E_rtn_refinedAlpha>0) | useRefAlphaFull) * alphaDecay;


% vNames(8:10): 'SR_alpha_Smpl','SR_alpha_Last2y','E_SR_alpha'
xx3(:,8) = meanRefAlphaFullSmpl./volRefAlphaFullSmpl; 
xx3(:,9) = meanRefAlpha24Mo./volRefAlpha24Mo; 
xx3(:,33) = volRefAlphaFullSmpl;
xx3(:,10) = E_rtn_refinedAlpha./E_vol_refinedAlpha; 
% vNames(12:14): {'E_vol_beta'}    {'E_vol_ARP'}    {'E_vol_refinedAlpha'}
xx3(:,14) = E_vol_refinedAlpha; 
xx3(:,40) = E_rtn_refinedAlpha;
xx3(:,41) = fExpos.alpha(hIndx,1);

primaryAlpha = fExpos.primaryAlphaTS(:,hIndx);

% Always use ARCH for primary alpha, as we don't have old formula, and we
% cannot simply copy-paste refined alpha formula for lack of correlation 
% estimate for primary alpha (full sample vs 24mo). We will soon remove the
% old formula completely (always do ARCH) so this asymmetry between primary 
% and refined alpha calc is temporary.
%E_vol_primaryAlpha = sqrt(12)*calcARCHvol(primaryAlpha - nanmean(primaryAlpha), 6, 6)';

primaryAlphaMean = 12*nanmean(primaryAlpha)';  
primaryAlphaVol = sqrt(12)*nanstd(primaryAlpha)';
E_vol_primaryAlpha = primaryAlphaVol;

temp2_prim = primaryAlpha(end-offset2y:end,:); 
temp_mean2_prim = 12*nanmean(temp2_prim)'; 
temp_vol2_prim = sqrt(12)*nanstd(temp2_prim)'; 

xx3(:,34) = primaryAlphaMean./primaryAlphaVol; 
xx3(:,35) = temp_mean2_prim./temp_vol2_prim; 

% Work out total return and vol from primary alpha and beta
fBetaIndx = mapStrings(cfg.headers.betaHeader,fHeader); 
E_rtn = fExpos.beta(hIndx,fBetaIndx)*(perfAssTable.E_SR(fBetaIndx) ...
    .* perfAssTable.E_vol(fBetaIndx)) + primaryAlphaMean; 
hfBetaVarCov = fExpos.beta(hIndx,fBetaIndx)*omega(fBetaIndx,fBetaIndx) ...
    * fExpos.beta(hIndx,fBetaIndx)'; 

hfEvol = (diag(hfBetaVarCov) + E_vol_primaryAlpha.^2).^.5; 
xx3(:,3) = E_rtn./hfEvol; 
xx3(:,36) = E_rtn;
% E_vol overall, column 11:
xx3(:,11) = hfEvol;

%primaryAlphaMean24mo = 12*nanmean(primaryAlpha(end-offset2y:end,:))'; 
%primaryAlphaVol24mo = sqrt(12)*nanstd(primaryAlpha(end-offset2y:end,:))';

% Please note asymmetry between E[return of Primary alpha] and 
% E[return of Refined alpha]. (For primary alpha we don't do averaging of 
% means over full sample and 24mo, and we don't apply alpha decay.)
% We are studying alpha decay on EurekaHedge dataset, and will revisit 
% these formulas when we have results from the study.
E_rtn_primaryAlpha = primaryAlphaMean;
eSrPrimaryAlpha = E_rtn_primaryAlpha ./ E_vol_primaryAlpha;
%eSrPrimaryAlpha24mo = primaryAlphaMean24mo ./ primaryAlphaVol24mo;
%disp(eSrPrimaryAlpha24mo)

if cfg.saveToDb
    factorIds = cellfun(@(x) outStruct.ref.factors.idMap(x), cfg.factors.flat);
    betas.header = arrayfun(@(x) outStruct.ref.dim.instruments(x), factorIds);
    betas.data = xx3(:,15:22); 
    
    eSR.header = [csn.primaryAlpha, csn.refinedAlpha, csn.beta, csn.arp, csn.total];
    eSR.data = [eSrPrimaryAlpha, xx3(:,10) xx3(:,6) xx3(:,7) xx3(:,3)];

    srSmpl.header = [csn.primaryAlpha, csn.refinedAlpha, csn.total];
    srSmpl.data = [xx3(:,34) xx3(:,8) xx3(:,4)];
    sr2y.header = [csn.primaryAlpha, csn.refinedAlpha, csn.total];
    sr2y.data = [xx3(:,35) xx3(:,9) xx3(:,5)];

    eVol.header = [csn.primaryAlpha, csn.refinedAlpha, csn.beta, csn.arp, csn.total];
    eVol.data = [E_vol_primaryAlpha, xx3(:,14) xx3(:,12) xx3(:,13) xx3(:,11)];
end % if cfg.saveToDb

xx3(:,29) = eSrPrimaryAlpha;
xx3(:,30) = E_vol_primaryAlpha;
xx3(:,38) = E_rtn_primaryAlpha;

if cfg.adjustForTiming
    xx3(:,31) = nanmean( fExpos.timingRtnMatrix(:,hIndx), 1 );
    xx3(:,32) = nanstd ( fExpos.timingRtnMatrix(:,hIndx), 1 );
end %

% divAlpha, column 23-28: SR_alpha_i - rho(i,restOfPort)*SR_restOfPort
% first, compute correlation of i-th alpha to restOfPort: 
hh=find(strcmp(hHeader,{'aigHFbkcst'}));
temp = fullRefinedAlpha(:,[hh,hIndx]);
tempCorr = corrcoef(temp,'Rows','pairwise');
tempCorr2y = corrcoef(temp(end-offset2y:end,:),'Rows','pairwise'); 
clear temp;
tempSRi = sqrt(12)*nanmean(fullRefinedAlpha(:,hIndx))./nanstd(fullRefinedAlpha(:,hIndx)); 
tempSRi2y = sqrt(12)*nanmean(fullRefinedAlpha(end-offset2y:end,hIndx))./nanstd(fullRefinedAlpha(end-offset2y:end,hIndx)); 

if cfg.opt.processMV
    tempSRport = sqrt(12)*nanmean(fullRefinedAlpha(:,hh))./nanstd(fullRefinedAlpha(:,hh)); 
    tempSRport2y = sqrt(12)*nanmean(fullRefinedAlpha(end-offset2y:end,hh))./nanstd(fullRefinedAlpha(end-offset2y:end,hh)); 
    tempDivAlpha = tempSRi' - tempCorr(2:end,1)*tempSRport;
    tempDivAlpha2y = tempSRi2y' - tempCorr2y(2:end,1)*tempSRport2y;
    xx3(:,[25 28]) = [tempDivAlpha, tempDivAlpha2y];
    corrStartIdx = 2; % to account for portfolio total "fund"
else    
    corrStartIdx = 1;
end % if cfg.opt.processMV

% vNames(23:28): {'alphaHist'} {'corrHist'} {'diversifyingAlpha'} {'alpha2y'} {'corr2y'} {'diversifyingAlpha'}
xx3(:,[23 24 26 27]) = [tempSRi',tempCorr(corrStartIdx:end,1),tempSRi2y', tempCorr2y(corrStartIdx:end,1)];

table = array2table(xx3,'RowNames',rNames','VariableNames',vNames); 

if cfg.opt.processStrategy
    Strategy = style.funds(:,hIndx)'; 
    table = addvars(table,Strategy,'Before',vNames{1});
    table = sortrows(table,'RowNames');
    table = sortrows(table,{'Strategy'},{'ascend'});
end % cfg.opt.processStrategy

ret.table = table;
ret.var.v_1d = v_1d;

if cfg.saveToDb
    ret.var.v_2d = containers.Map;
    ret.var.v_2d("E[SR]") = eSR;
    ret.var.v_2d("E[vol]") = eVol;

    ret.var.v_2d("SR Full") = srSmpl;
    ret.var.v_2d("SR 2yr") = sr2y;
    ret.var.v_2d("Beta") = betas;
end % if cfg.saveToDb

end
function table = createExpectedPerformanceTable1(rNames,vNames,outStruct,perfAssTable, cfg)
unpack(outStruct);
xx2 = zeros(length(rNames),length(vNames));
xx2(1:5,1) = hfStyleWts'; 
xx2(1:5,2) = hfStyleMktVal';

% now E_SR column 3: overall
hIndxStyle = mapStrings({'lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},hHeader); 
fIndx = 1:8; 
E_rtn = fExpos.beta(hIndxStyle,fIndx)*(perfAssTable.E_SR.*perfAssTable.E_vol)+alphaDecay*12*fExpos.alpha(hIndxStyle,1); 
hfStyleFactorVarCov = fExpos.beta(hIndxStyle,fIndx)*omega*fExpos.beta(hIndxStyle,fIndx)'; 
aTemp = fExpos.refinedAlphaTS(:,hIndxStyle); aTemp(aTemp==0) = NaN; 
hfAlphaVarCov = 12*nancov(aTemp); 
hfStyleVol = (diag(hfStyleFactorVarCov+hfAlphaVarCov)).^.5; 
clear fIndx;

fARPIndx = mapStrings(cfg.headers.arsHeader,fHeader); 
fBetaIndx = mapStrings(cfg.headers.betaHeader,fHeader); 

E_rtn(2:5,1) = E_rtn; 
hfStyleVol(2:5,1) = hfStyleVol; 
E_rtn(1,1) = E_rtn(2:5,1)'*hfStyleWts(2:5,1);
hfStyleVol(1,1) = (hfStyleWts(2:5,1)'*(hfStyleFactorVarCov+hfAlphaVarCov)*hfStyleWts(2:5,1))^.5;
E_rtn(6,1) = (ones(1,4)/4)*(perfAssTable.E_SR(fARPIndx,:).*perfAssTable.E_vol(fARPIndx,:));
hfStyleVol(6,1) = (wtsARP*omega(fARPIndx,fARPIndx)*wtsARP')^.5;
xx2(1:6,3) = (E_rtn)./hfStyleVol; % Sharpe ratio; E_rtn is actually expected excess return, built up from E[SR]
xx2(7:14,3) = [perfAssTable.E_SR(fARPIndx,:); perfAssTable.E_SR(fBetaIndx,:)];

% now E[vol] column 7: total
xx2(1:6,7) = hfStyleVol; 
xx2(7:14,7) = [perfAssTable.E_vol(fARPIndx,:); perfAssTable.E_vol(fBetaIndx,:)];

% now E[SR_?] column 4: market betas
E_rtn = fExpos.beta(hIndxStyle,fBetaIndx)*(perfAssTable.E_SR(fBetaIndx,1).*perfAssTable.E_vol(fBetaIndx,1)); 
hfStyleFactorVarCov = fExpos.beta(hIndxStyle,fBetaIndx)*omega(fBetaIndx,fBetaIndx)*fExpos.beta(hIndxStyle,fBetaIndx)';
hfStyleVol = (diag(hfStyleFactorVarCov)).^.5;

E_rtn(2:5,1) = E_rtn; 
hfStyleVol(2:5,1) = hfStyleVol; 
E_rtn(1,1) = E_rtn(2:5,1)'*hfStyleWts(2:5,1);
hfStyleVol(1,1) = (hfStyleWts(2:5,1)'*(hfStyleFactorVarCov)*hfStyleWts(2:5,1))^.5;
xx2(1:5,4) = E_rtn./hfStyleVol; % Sharpe ratio; E_rtn is actually expected excess return, built up from E[SR]
xx2(6:10,4) = NaN; 
xx2(11:14,4) = perfAssTable.E_SR(fBetaIndx,1); 

% now E[vol] column 8: vol due to market beta
xx2(1:5,8) = hfStyleVol; 
xx2(6:10,8) = NaN; 
xx2(11:14,8) = perfAssTable.E_vol(fBetaIndx,1); 

% now E[SR_ARS] column 5: ARP betas
E_rtn = fExpos.beta(hIndxStyle,fARPIndx)*(perfAssTable.E_SR(fARPIndx,1).*perfAssTable.E_vol(fARPIndx,1)); 
hfStyleFactorVarCov = fExpos.beta(hIndxStyle,fARPIndx)*omega(fARPIndx,fARPIndx)*fExpos.beta(hIndxStyle,fARPIndx)';
hfStyleVol = (diag(hfStyleFactorVarCov)).^.5;

E_rtn(2:5,1) = E_rtn; 
hfStyleVol(2:5,1) = hfStyleVol; 
E_rtn(1,1) = E_rtn(2:5,1)'*hfStyleWts(2:5,1);
hfStyleVol(1,1) = (hfStyleWts(2:5,1)'*(hfStyleFactorVarCov)*hfStyleWts(2:5,1))^.5;
E_rtn(6,1) = wtsARP*(perfAssTable.E_SR(fARPIndx,:).*perfAssTable.E_vol(fARPIndx,:));
hfStyleVol(6,1) = (wtsARP*omega(fARPIndx,fARPIndx)*wtsARP')^.5;
xx2(1:6,5) = E_rtn./hfStyleVol; % Sharpe ratio; E_rtn is actually expected excess return, built up from E[SR]
xx2(7:10,5) = perfAssTable.E_SR(fARPIndx,:); 
xx2(11:14,5) =  NaN;

% now E[vol] column 9: vol due to ARP beta
xx2(1:6,9) = hfStyleVol; 
xx2(7:10,9) = perfAssTable.E_vol(fARPIndx,1); 
xx2(11:14,9) =  NaN;

% now E[SR_?] column 6: alpha
E_rtn = alphaDecay*12*fExpos.alpha(hIndxStyle,1);
hfStyleVol = (diag(hfAlphaVarCov)).^.5; 
E_rtn(2:5,1) = E_rtn; 
E_rtn(1,1) = E_rtn(2:5,1)'*hfStyleWts(2:5,1);
hfStyleVol(2:5,1) = hfStyleVol; 
hfStyleVol(1,1) = (hfStyleWts(2:5,1)'*(hfAlphaVarCov)*hfStyleWts(2:5,1))^.5;
xx2(1:5,6) = E_rtn./hfStyleVol; 
xx2(6:14,6) = NaN;

% now E[vol] column 10: vol due to alpha
xx2(1:5,10) = hfStyleVol; 
xx2(6:14,10) = NaN;

table = array2table(xx2,'RowNames',rNames','VariableNames',vNames); 

end
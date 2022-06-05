% Older code from the ehMine notebook, which we are not ready to delete completely yet

% Fixed effects removal does not appear idempotent. 
% Not sure if this is a sign of a problem or not.
% The correlations don't change that much, so the 
% answer to why this is not idempotent probably 
% doesn't matter that much, at least for now
%------------------------------
tbl_1_reFE2 = tbl_1_reFE;
tbl_1_reFE2.YMo = tbl_1.YMo;
tbl_1_reFE2.FundId = categorical(tbl_1.FundId);
tbl_1_reFE3 = removeFixedEffects(tbl_1_reFE2, ["YMo", "FundId"]);

R2=corrcoef(table2array(tbl_1_reFE3), 'Rows', 'pairwise');
rTbl = array2table(R2, "RowNames", tbl_1_reFE.Properties.VariableNames,"VariableNames", tbl_1_reFE.Properties.VariableNames)
%------------------------------
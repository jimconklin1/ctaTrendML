chosenFunds = { 'DE Shaw Composite', 'DE Shaw Multi-Asset Fund', 'Gemsstock Fund', 'Hondius', 'Iron Triangle Fund', 'JPM HLX 3 USD', 'JPM NEO Commodity Curve Alpha', 'JPM Short Term Rates Trend', 'Noviscient', 'Polymer Asia Fund L.P.', 'Schonfeld Strategic Partners Fund', 'Segantii', 'Sio Partners LP', 'The Valent Fund', 'Twin Tree'};
chosenFields = {'E_rtn', 'E_rtn_beta', 'E_rtn_primaryAlpha' ...
    , 'E_vol_tot','E_vol_beta','E_vol_primaryAlpha' ...
    , 'E_SR_tot', 'E_SR_beta', 'E_SR_primaryAlpha'};
cfIdx = ismember(fundPerformance.table.Properties.RowNames, chosenFunds);
cfTbl = fundPerformance.table(cfIdx, chosenFields);
cfTbl = sortrows(cfTbl, 'RowNames');
cfTbl.E_volCalc = sqrt( cfTbl{:, 'E_vol_beta'} .^2 + cfTbl{:, 'E_vol_primaryAlpha'} .^2 );

writetable(cfTbl, fullfile(outDataDir, 'dbgPerf.xlsx'), 'WriteRowNames', true);
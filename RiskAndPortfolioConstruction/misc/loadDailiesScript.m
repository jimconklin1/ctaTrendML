clear;
in_dir = 'C:\Data\PubEq\Projects\RAPC\Delphia';
tickers = readtable(fullfile(in_dir, 'tickers.csv'));
tot_ret = readtable(fullfile(in_dir, 'tot_ret.csv'), 'PreserveVariableNames', true);
tot_ret = tot_ret(~isnat(tot_ret.Date), :);
tot_ret.mlDate = datenum(tot_ret{:, 'Date'});
clear 'in_dir';
save('M:\Manager of Managers\Public Equity\hedgeFundPortfolio\3 - Prospects\1 - ActiveAnalysis\delphia_quant\returns.mat');

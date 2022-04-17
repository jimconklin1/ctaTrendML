function performance_metrics = GeneratePerformanceMetrics(TradeHistory)

% NOTE: This function returns a 2x7 cell arrays with the following information.
%
% NOTE: Trade History must have the following columns!

TradeHistory = TradeHistory(2:end,:); % We only use the trade history starting from the second row

if size(TradeHistory,1) < 2	% To calculate the trading performance, we need at least two trades to run the following calculation.

	disp('Too less trades history! Need at least two trades!');
	
	performance_metrics = cell(2,7);
	
	return;
	
end

column_name 		= 1;

column_entrydate 	= 2;

column_exitdate 	= 3;

column_entryprice 	= 4;

column_exitprice 	= 5;

column_longorshort 	= 6;

column_pnl 			= 7;

column_hitormiss 	= 8;


Security_Name 			= TradeHistory(1, column_name);

No_of_Trades 			= size(TradeHistory,1);

Average_Holding_Period 	= mean(datenum(TradeHistory(:, column_exitdate)) - datenum(TradeHistory(:, column_entrydate)));

Hit_Rate 				= mean(cell2mat(TradeHistory(:, column_hitormiss)));

Average_PnL 			= mean(cell2mat(TradeHistory(:, column_pnl)));

Interval_Period 		= mean(datenum(TradeHistory(2:end, column_entrydate)) - datenum(TradeHistory(1:end-1, column_exitdate)));

if Interval_Period == 0

	Interval_Period = 1;	% This is to avoid the case where trades are back-to-back.

end

Annualized_Sharpe_Ratio = sqrt(252/Interval_Period) * Average_PnL / std(cell2mat(TradeHistory(:, column_pnl)));

Maximum_Drawdown 		= maxdrawdown(cumsum(cell2mat(TradeHistory(:, column_pnl))), 'arithmetic');

Trade_PnL				= cell2mat(TradeHistory(:, column_pnl));

Profit_Factor			= sum(Trade_PnL(Trade_PnL > 0)) / sum(abs(Trade_PnL(Trade_PnL < 0)));



columnName(1) = {'Security'};

columnName(2) = {'No. of Trades'};

columnName(3) = {'Average Holding Period'};

columnName(4) = {'Hit Rate'};

columnName(5) = {'Average P&L'};

columnName(6) = {'Annualized Sharpe Ratio'};

columnName(7) = {'Maximum Drawdown'};

columnName(8) = {'Profit Factor'};

performance_metrics(1) = Security_Name;

performance_metrics(2) = num2cell(No_of_Trades);

performance_metrics(3) = num2cell(Average_Holding_Period);

performance_metrics(4) = num2cell(Hit_Rate);

performance_metrics(5) = num2cell(Average_PnL);

performance_metrics(6) = num2cell(Annualized_Sharpe_Ratio);

performance_metrics(7) = num2cell(Maximum_Drawdown);

performance_metrics(8) = num2cell(Profit_Factor);

performance_metrics = [columnName ; performance_metrics];
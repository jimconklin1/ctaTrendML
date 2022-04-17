function [performance_metrics, Consecutive_Daily_Losses] = GeneratePerformanceMetricsFromDailyPnlHistory(connection, pnl_history)

% NOTE: This function returns performance statistics cell array with the following information.
%
% The outputs: performance_metrics is a 29x2 cell arrays with the metrics [metric name | value], Consecutive_Daily_Losses is a Nx2 matrix with [number of down days | down return] in descending order.
%
% NOTE: The input is a cell array Nx2 with daily pnl history.

if cellfun('isempty', pnl_history)
	disp('No Daily PnL History!');
	performance_metrics = cell(30,2);
	return;
end

if ~any(cell2mat(pnl_history(:,2)))
	Total_PnL = 0; Average_PnL = 0; StDev_PnL = 0; MaxDrawDown = 0; Profit_Drawdown = 0;
	Max_PnL = 0; Min_PnL = 0; Sharpe_Ratio = 0; Market_Correlation = 0; Model_Beta = 0;
	Annualized_Ret = 0; Annualized_Vol = 0; Sortino_Ratio = 0;
	Winning_Percentage = 0; Average_Daily_Gain = 0; Average_Daily_Loss = 0;
	Daily_Gain_Vol = 0; Daily_Loss_Vol = 0; PnL_Skewness = 0; PnL_Kurtosis = 0;
	Best_5Day_Return = 0; Best_10Day_Return = 0; Best_20Day_Return = 0;
	Worst_5Day_Return = 0; Worst_10Day_Return = 0; Worst_20Day_Return = 0;
	WinRate_5Day_Returns = 0; WinRate_10Day_Returns = 0; WinRate_20Day_Returns = 0;
	BUS_Number = 0;
else
	pnl_series							= cell2mat(pnl_history(:,2));
	Total_PnL 							= sum(pnl_series);
	Average_PnL 						= mean(pnl_series);
	StDev_PnL 							= std(pnl_series);
	MaxDrawDown 						= maxdrawdown(cumsum(pnl_series), 'arithmetic');
	Profit_Drawdown 					= Total_PnL / MaxDrawDown;	
	Max_PnL 							= max(pnl_series);
	Min_PnL 							= min(pnl_series);
	Sharpe_Ratio 						= Average_PnL / StDev_PnL * sqrt(252);	
	[Market_Correlation, Model_Beta] 	= GenerateMarketModelCorrelation(connection, pnl_history);
	
	Annualized_Ret						= Average_PnL * 252;
	Annualized_Vol						= StDev_PnL * sqrt(252);
	Sortino_Ratio						= Average_PnL / std(pnl_series(pnl_series < 0)) * sqrt(252);
	Winning_Percentage					= sum(pnl_series >= 0) / length(pnl_series);
	Average_Daily_Gain					= mean(pnl_series(pnl_series > 0));
	Average_Daily_Loss					= mean(pnl_series(pnl_series < 0));
	Daily_Gain_Vol						= std(pnl_series(pnl_series > 0));
	Daily_Loss_Vol						= std(pnl_series(pnl_series < 0));
	PnL_Skewness						= skewness(pnl_series);
	PnL_Kurtosis						= kurtosis(pnl_series);
	
	Consecutive_Daily_Losses = [];
	down_days = 0; down_rets = 0;
	for i = 1:length(pnl_series)
		if pnl_series(i) < 0 	
			down_days = down_days + 1;		
			down_rets = down_rets + pnl_series(i);	
			if i == length(pnl_series)
				Consecutive_Daily_Losses = [Consecutive_Daily_Losses ; down_days, down_rets];
			end
		elseif i > 1 && pnl_series(i) >= 0 && pnl_series(i-1) < 0
			Consecutive_Daily_Losses = [Consecutive_Daily_Losses ; down_days, down_rets];
			down_days = 0;
			down_rets = 0;
		end
	end

	if ~isempty(Consecutive_Daily_Losses)
		[~, sorted_idx] = sort(Consecutive_Daily_Losses(:,1), 'descend');
		Consecutive_Daily_Losses = Consecutive_Daily_Losses(sorted_idx, :);
	end
	if length(pnl_series) >= 5
		FiveDay_Returns = [];
		for i = 5:length(pnl_series)
			FiveDay_Returns = [FiveDay_Returns ; sum(pnl_series(i-5+1:i))];	
		end
		Best_5Day_Return = max(FiveDay_Returns);
		Worst_5Day_Return = min(FiveDay_Returns);
		WinRate_5Day_Returns = sum(FiveDay_Returns >= 0) / length(FiveDay_Returns);
	else
		Best_5Day_Return = NaN;
		Worst_5Day_Return = NaN;
		WinRate_5Day_Returns = NaN;
	end
	if length(pnl_series) >= 10
		TenDay_Returns = [];
		for i = 10:length(pnl_series)
			TenDay_Returns = [TenDay_Returns ; sum(pnl_series(i-10+1:i))];	
		end
		Best_10Day_Return = max(TenDay_Returns);
		Worst_10Day_Return = min(TenDay_Returns);
		WinRate_10Day_Returns = sum(TenDay_Returns >= 0) / length(TenDay_Returns);
	else
		Best_10Day_Return = NaN;
		Worst_10Day_Return = NaN;
		WinRate_10Day_Returns = NaN;
	end
	
	if length(pnl_series) >= 20
		TwentyDay_Returns = [];
		for i = 20:length(pnl_series)
			TwentyDay_Returns = [TwentyDay_Returns ; sum(pnl_series(i-20+1:i))];	
		end
		Best_20Day_Return = max(TwentyDay_Returns);
		Worst_20Day_Return = min(TwentyDay_Returns);
		WinRate_20Day_Returns = sum(TwentyDay_Returns >= 0) / length(TwentyDay_Returns);
	else
		Best_20Day_Return = NaN;
		Worst_20Day_Return = NaN;
		WinRate_20Day_Returns = NaN;
	end
	
	% compute BUS number
	sorted_pnl = sort(pnl_series, 'descend');
	sum_pnl = Total_PnL;
	idx = 1;
	while (sum_pnl >= 0 & idx <= length(sorted_pnl))
		sum_pnl = sum_pnl - sorted_pnl(idx);
		idx = idx + 1;
	end
	BUS_Number = (idx - 1) / length(pnl_series);
end

rowName(1)  = {'Total P&L'};
rowName(2)  = {'Average P&L'};
rowName(3)  = {'StDev'};
rowName(4)  = {'Max Drawdown'};
rowName(5)  = {'Profit/Drawdown'};
rowName(6)  = {'Max Daily P&L'};
rowName(7)  = {'Min Daily P&L'};
rowName(8)  = {'Sharpe Ratio'};
rowName(9)  = {'Correlation to Market'};
rowName(10) = {'Model Beta'};
rowName(11) = {'Annualized Return'};
rowName(12) = {'Annualized Vol'};
rowName(13) = {'Sortino Ratio'};
rowName(14) = {'Winning Percentage'};
rowName(15) = {'Average Daily Gain'};
rowName(16) = {'Average Daily Loss'};
rowName(17) = {'Daily Gain Vol'};
rowName(18) = {'Daily Loss Vol'};
rowName(19) = {'PnL Skewness'};
rowName(20) = {'PnL Kurtosis'};
rowName(21) = {'Best 5 Day Return'};
rowName(22) = {'Best 10 Day Return'};
rowName(23) = {'Best 20 Day Return'};
rowName(24) = {'Worst 5 Day Return'};
rowName(25) = {'Worst 10 Day Return'};
rowName(26) = {'Worst 20 Day Return'};
rowName(27) = {'Win Rate of 5 Day Returns'};
rowName(28) = {'Win Rate of 10 Day Returns'};
rowName(29) = {'Win Rate of 20 Day Returns'};
rowName(30) = {'BUS Number'};

performance_metrics = cell(length(rowName),2);
performance_metrics(:,1)  = rowName';
performance_metrics(1,2)  = num2cell(Total_PnL);
performance_metrics(2,2)  = num2cell(Average_PnL);
performance_metrics(3,2)  = num2cell(StDev_PnL);
performance_metrics(4,2)  = num2cell(MaxDrawDown);
performance_metrics(5,2)  = num2cell(Profit_Drawdown);
performance_metrics(6,2)  = num2cell(Max_PnL);
performance_metrics(7,2)  = num2cell(Min_PnL);
performance_metrics(8,2)  = num2cell(Sharpe_Ratio);
performance_metrics(9,2)  = num2cell(Market_Correlation);
performance_metrics(10,2) = num2cell(Model_Beta);
performance_metrics(11,2) = num2cell(Annualized_Ret);
performance_metrics(12,2) = num2cell(Annualized_Vol);
performance_metrics(13,2) = num2cell(Sortino_Ratio);
performance_metrics(14,2) = num2cell(Winning_Percentage);
performance_metrics(15,2) = num2cell(Average_Daily_Gain);
performance_metrics(16,2) = num2cell(Average_Daily_Loss);
performance_metrics(17,2) = num2cell(Daily_Gain_Vol);
performance_metrics(18,2) = num2cell(Daily_Loss_Vol);
performance_metrics(19,2) = num2cell(PnL_Skewness);
performance_metrics(20,2) = num2cell(PnL_Kurtosis);
performance_metrics(21,2) = num2cell(Best_5Day_Return);
performance_metrics(22,2) = num2cell(Best_10Day_Return);
performance_metrics(23,2) = num2cell(Best_20Day_Return);
performance_metrics(24,2) = num2cell(Worst_5Day_Return);
performance_metrics(25,2) = num2cell(Worst_10Day_Return);
performance_metrics(26,2) = num2cell(Worst_20Day_Return);
performance_metrics(27,2) = num2cell(WinRate_5Day_Returns);
performance_metrics(28,2) = num2cell(WinRate_10Day_Returns);
performance_metrics(29,2) = num2cell(WinRate_20Day_Returns);
performance_metrics(30,2) = num2cell(BUS_Number);


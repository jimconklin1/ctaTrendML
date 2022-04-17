function [pnl_year_by_year, performance_year_by_year] = BreakDownDailyPnlHistoryYearByYear(pnl_history)

% NOTE: This function breaks down a daily pnl history into pnl time series year by year.
%
% NOTE: The outputs pnl_year_by_year is a struct containing pnl history for each year, which is in cell array format.
%
% NOTE: The output performance_year_by_year is also a struct containing performance for each year, also in cell array format.
%
% NOTE: The input pnl_history is in cell format with [date | daily pnl]. The date has to be in the ascending order, which is normally the case.

pnl_year_by_year = struct();
	
performance_year_by_year = struct();

if cellfun('isempty', pnl_history)

	disp('No Daily PnL History!');

	return;

end

date_vector = datevec(pnl_history(:,1));

year_column = 1;	% column of year information

[unique_date, unique_start_index, repeat_index] = unique(date_vector(:,year_column));

for i = 1:length(unique_start_index)

	if i ~= length(unique_start_index)
	
		current_year_pnl_history = pnl_history(unique_start_index(i):unique_start_index(i+1)-1,:);
		
	else
	
		current_year_pnl_history = pnl_history(unique_start_index(i):end,:);
	
	end

	current_year_performance = GeneratePerformanceMetricsFromDailyPnlHistory(current_year_pnl_history);
		
	pnl_year_by_year.(['year_',num2str(unique_date(i))]) = current_year_pnl_history;
		
	performance_year_by_year.(['year_',num2str(unique_date(i))]) = current_year_performance;

	figure(i)
	
	PlotCumulativeSeries(current_year_pnl_history, 'PnL');

end









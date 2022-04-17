function [correlation_series, beta_series] = GenerateCorrelationAndBetaSeries(connection, return_series, index_name, rolling_window)

% NOTE: This function calculates the correlation and beta series between a return series and return of a specified index, based on rolling_window.
%
% NOTE: The output: both are cell arrays, [date | data], starting from the first rolling window day.
%
% NOTE: The input connection is from config file, return_series is a cell array, [date | data]. index_name is a string, rolling_window is a number, in terms of trading days.
%
% NOTE: Here index can be any index we want to look at.
%
% NOTE: The return series has to be in percentage, otherwise beta is a huge number.


if size(return_series,1) < rolling_window

	error('Not Enough Return Data. Cannot Calculate Correlation or Beta.');
	
end


index_ret		   = GeneratePastPriceReturnSeries(connection, {index_name}, return_series(1,1), return_series(end,1), 1);

return_index.data1 = return_series;

return_index.data2 = index_ret;

return_index_total = FillIncompleteData_New(return_index, 1);

return_index	   = RemoveRowsWithInvalidPrices(return_index_total);

return_index_date  = return_index(:,1);

return_index_data  = cell2mat(return_index(:,[2,3]));


correlation_series = cell(0);

beta_series = cell(0);

if isempty(return_index_data) | size(return_index_data,1) < rolling_window

	disp('No Data Point or Not Enough Data to Calculate Correlation.');
	
	return;
	
else

	for i = rolling_window : size(return_index_data,1)

		return_index_correlation_matrix = corr(return_index_data(i-rolling_window+1:i,:));

		correlation_series = [correlation_series ; return_index_date(i) num2cell(return_index_correlation_matrix(1,2))];

		return_index_covariance_matrix = cov(return_index_data(i-rolling_window+1:i,:));
		
		return_index_beta = return_index_covariance_matrix(1,2) / return_index_covariance_matrix(2,2);
		
		beta_series = [beta_series ; return_index_date(i) num2cell(return_index_beta)];
		
	end
	
end
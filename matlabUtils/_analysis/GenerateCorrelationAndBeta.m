function [return_index_correlation, return_index_beta] = GenerateCorrelationAndBeta(connection, return_series, index_name)

% NOTE: This function calculates the correlation and beta between a return series and return of a specified index. The outputs are two numbers.
%
% NOTE: The input connection is from config file, return_series is a cell array, [date | data]. index_name is a string. 
%
% NOTE: Here index can be any index we want to look at.
%
% NOTE: The return series has to be in percentage, otherwise beta is a huge number.


buffer_days 	= 5;

data_start_date = cellstr(datestr(addtodate(datenum(return_series(1,1)), - buffer_days, 'day')));

data_end_date 	= return_series(end,1);

index_ret		= GeneratePastPriceReturnSeries(connection, {index_name}, data_start_date, data_end_date, 1);

start_index 	= find(datenum(cell2mat(index_ret(:,1))) >= datenum(return_series(1,1)),1);

index_ret		= index_ret(start_index:end,:);

return_index.data1 = return_series;

return_index.data2 = index_ret;

return_index_total = FillIncompleteData_New(return_index, 1);

return_index_data  = RemoveRowsWithInvalidNumbers(cell2mat(return_index_total(:,[2,3])));

if isempty(return_index_data)

	disp('No Data Point to Calculate Correlation Matrix.');
	
	return_index_correlation = NaN;
	
	return_index_beta = NaN;
	
	return;
	
else

	return_index_correlation_matrix = corr(return_index_data);

	return_index_correlation = return_index_correlation_matrix(1,2);

	return_index_covariance_matrix = cov(return_index_data);
	
	return_index_beta = return_index_covariance_matrix(1,2) / return_index_covariance_matrix(2,2);

end
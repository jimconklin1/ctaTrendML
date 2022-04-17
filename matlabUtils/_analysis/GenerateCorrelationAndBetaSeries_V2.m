function [correlation_series, beta_series] = GenerateCorrelationAndBetaSeries_V2(return_series, index_return, rolling_window)

% This function calculates the correlation and beta series between a return series and return of a specified index, based on rolling_window.
%
% Outputs: both are cell arrays, [date | data], starting from the first rolling window day.
%
% Inputs: return_series, a cell array, [date | data]. 
%		  index_return, a cell array, [date | data]
%		  rolling_window, a number, in terms of trading days.
%
% NOTE: The return series has to be in percentage, otherwise beta is a huge number.

if size(return_series,1) < rolling_window
	error('Not Enough Return Data. Cannot Calculate Correlation or Beta.');	
end

return_index.data1 = return_series;
return_index.data2 = index_return;
return_index_total = FillIncompleteData_New(return_index, 1);
return_index	   = RemoveRowsWithInvalidPrices(return_index_total);
return_index_date  = return_index(:,1);
return_index_data  = cell2mat(return_index(:,[2,3]));

correlation_series 	= cell(length(return_index_date)-rolling_window+1,2);
beta_series 		= cell(length(return_index_date)-rolling_window+1,2);

for i = rolling_window : size(return_index_data,1)
	return_index_correlation_matrix = corr(return_index_data(i-rolling_window+1:i,:));
	correlation_series(i-rolling_window+1,:) = [return_index_date(i) num2cell(return_index_correlation_matrix(1,2))];
	return_index_covariance_matrix = cov(return_index_data(i-rolling_window+1:i,:));
	return_index_beta = return_index_covariance_matrix(1,2) / return_index_covariance_matrix(2,2);
	beta_series(i-rolling_window+1,:) = [return_index_date(i) num2cell(return_index_beta)];
end

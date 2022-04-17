function [market_model_correlation, market_model_beta] = GenerateMarketModelCorrelation(connection, model_history)

% NOTE: This function calculates the correlation between model and the market, and the beta of the model. The outputs are two numbers.
%
% NOTE: The input connection is from config file, model_history is a cell array of daily model pnl with the format [date | data]. 
%
% NOTE: Here we are using SPX as the market.
%
% NOTE: When calculating model beta, the pnl history has to be in terms of percentage. Otherwise, beta will be a huge number.

market = 'SPX Index';

buffer_days 	= 5;

data_start_date = cellstr(datestr(addtodate(datenum(model_history(1,1)), - buffer_days, 'day')));

data_end_date 	= model_history(end,1);

market_ret		= GeneratePastPriceReturnSeries(connection, {market}, data_start_date, data_end_date, 1);

start_index 	= find(datenum(cell2mat(market_ret(:,1))) >= datenum(model_history(1,1)),1);	% these two lines seem unnecessary

market_ret		= market_ret(start_index:end,:);

market_model.data1 = model_history;

market_model.data2 = market_ret;

market_model_total = FillIncompleteData_New(market_model, 1);

market_model_data  = RemoveRowsWithInvalidNumbers(cell2mat(market_model_total(:,[2,3])));

if isempty(market_model_data)

	disp('No Data Point to Calculate Correlation Matrix.');
	
	market_model_correlation = nan;
	
	return;
	
else

	market_model_correlation_matrix = corr(market_model_data);

	market_model_correlation = market_model_correlation_matrix(1,2);

	%disp(['Correlation bewteen the model and market is: ',num2str(market_model_correlation)]);
	
	market_model_covariance_matrix = cov(market_model_data);
	
	market_model_beta = market_model_covariance_matrix(1,2) / market_model_covariance_matrix(2,2);
	
	%disp(['Beta of the model is: ',num2str(market_model_beta)]);
	
end
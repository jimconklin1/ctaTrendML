function historical_vol_series = GenerateHistoricalReturnVolatilitySeries(connection, security_name, start_date, end_date, return_period, lookback_days)

% NOTE: This function generates a historical volatility of a security based on lookback_days.
%
% NOTE: The output is a cell array with the format [date | data].
%
% NOTE: The inputs connection is from config file, security_name, start_date and end_date are cells and lookback_days is a number.
%
% NOTE: The historical volatility in this calculation is Annualized.

buffer_days 	= lookback_days * 3;	% this number should be large enough to ensure we have data from lookback_days ago.

data_start_date = cellstr(datestr(addtodate(datenum(cell2mat(start_date)), - buffer_days, 'day')));

data_end_date	= end_date;

return_series	= GeneratePastPriceReturnSeries(connection, security_name, data_start_date, data_end_date, return_period);

historical_vol_series = cell(0);

% if there is no data, just return a nil cell

if cellfun('isempty', return_series)

	disp(['There is NO Return Data for ', cell2mat(security_name), ' during time period ', datestr(data_start_date,'mm-dd-yyyy'), ' to ', datestr(data_end_date,'mm-dd-yyyy')]);
	
	disp('Cannot Calculate Historical Return Volatility ... ');
	
	return;
	
end

return_date	= return_series(~isnan(cell2mat(return_series(:,2))),1);	% remove NaN values in the price data

return_data = cell2mat(FillNaNDataWithEmptyCell(return_series(:,2)));

start_index = find(datenum(return_date) >= datenum(start_date),1);	% find the start index based on the actual start date


for i = start_index : length(return_date);
    
	current_vol = std(return_data(i - lookback_days + 1 : i));	% annualize the volatility
	
	historical_vol_series = [historical_vol_series ; return_date(i) num2cell(current_vol)];
	
end
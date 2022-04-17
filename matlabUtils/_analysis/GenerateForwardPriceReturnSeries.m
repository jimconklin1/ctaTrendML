function security_return_series = GenerateForwardPriceReturnSeries(connection, security_name, start_date, end_date, return_period)

% NOTE: This function returns the forward return series of a security using daily data. security_return_series is in the CELL format [date | data].
%
% NOTE: in security_return_series, date is updated till end_date - return_period.
%
% NOTE: connection is from config file, security_name, start_date, and end_date are cells, return_period is a number indicating number of days.
%
% NOTE: large return_period requires large buffer_days, 500 buffer days is good for return_period 1000 days.

if datenum(start_date) + return_period > now

	security_return_series = cell(0);
	
	return

end

buffer_days 	= 500;

data_start_date = start_date;

data_end_date 	= cellstr(datestr(addtodate(datenum(cell2mat(end_date)), return_period + buffer_days, 'day')));

field			= {'LAST_PRICE'};

security_data 	= GetGeneralDailyDataFromBloomberg(connection, security_name, data_start_date, data_end_date, field);

% if no data, just return an empty cell

if cellfun('isempty',security_data)

	disp(['There is NO Data for ', cell2mat(security_name), ' during time period ', datestr(start_date,'mm-dd-yyyy'), ' to ', datestr(end_date,'mm-dd-yyyy')]);

	security_return_series = cell(0);
	
	return;
	
end

date_series 	= security_data(:,2);	% date

price_series 	= security_data(:,3);	% close price

date_return 	= date_series(1:end-return_period);	% date for forward return series

data_return		= CalculateReturn(cell2mat(price_series(1:end-return_period)), cell2mat(price_series(1+return_period:end)));	% data for return series

end_index 		= find(datenum(cell2mat(date_return)) > datenum(cell2mat(end_date)),1);	% find the end index based on the actual end date

if isempty(end_index)

	security_return_series = [date_return(1:end) FillNaNDataWithZeroCell(num2cell(data_return(1:end)))];

elseif end_index == 1

	disp(['There is NO Forward Return Series for ', cell2mat(security_name), ' during time period ', datestr(start_date,'mm-dd-yyyy'), ' to ', datestr(end_date,'mm-dd-yyyy')]);

	security_return_series = cell(0);

else

	security_return_series = [date_return(1:end_index-1) FillNaNDataWithZeroCell(num2cell(data_return(1:end_index-1)))];

end
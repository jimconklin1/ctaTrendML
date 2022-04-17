function security_return_series = GeneratePastPriceReturnSeries(connection, security_name, start_date, end_date, return_period)

% NOTE: This function returns the past return series of a security using daily data. security_return_series is in the CELL format [date | data].
%
% NOTE: connection is from config file, security_name, start_date, and end_date are cells, return_period is a number indicating number of days.
%
% NOTE: large return_period requires large buffer_days, 500 buffer days is good for return_period 1000 days.

buffer_days 	= 500;

data_start_date = cellstr(datestr(addtodate(datenum(start_date), - return_period - buffer_days, 'day')));

data_end_date 	= end_date;

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

date_return 	= date_series(1+return_period:end);	% date for past return series

data_return		= CalculateReturn(cell2mat(price_series(1:end-return_period)), cell2mat(price_series(1+return_period:end)));	% data for return series

start_index 	= find(datenum(cell2mat(date_return)) >= datenum(start_date),1);	% find the start index based on the actual start date

security_return_series = [date_return(start_index:end) FillNaNDataWithZeroCell(num2cell(data_return(start_index:end)))];
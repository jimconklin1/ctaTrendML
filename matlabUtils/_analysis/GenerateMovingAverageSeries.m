function MA_series = GenerateMovingAverageSeries(connection, security_name, start_date, end_date, MA_periods, MA_periods_unit, MA_type)

% NOTE: This function generates a moving average series of a security based on MA_periods and MA_type
%
% NOTE: The output is a cell array with the format [date | data].
%
% NOTE: The inputs connection is from config file, security_name, start_date and end_date are cells and MA_periods is a number, MA_periods_unit is a string, MA_type is a string.
%
% The MA_periods_unit has to be consistent with the data sampling frequency.
%
% MA_type: 'Simple', 'Exponential'

if nargin == 4

	MA_type = 'Simple';	% by default, MA_type is simple moving average

end

buffer_days 	= MA_periods * 10;	% this number should be large enough to ensure we have data from MA_periods ago.

data_start_date = cellstr(datestr(addtodate(datenum(cell2mat(start_date)), - buffer_days, MA_periods_unit)));

data_end_date	= end_date;

%field			= {'ACTUAL_RELEASE'};	% this is for economic data

%field			= {'PX_VOLUME'};	% this is for security volume

field			= {'LAST_PRICE'};

security_data	= GetGeneralDailyDataFromBloomberg(connection, security_name, data_start_date, data_end_date, field);

MA_series = cell(0);

% if there is no data, just return a nil cell

if cellfun('isempty', security_data)

	disp(['There is NO Data for ', cell2mat(security_name), ' during time period ', datestr(cell2mat(data_start_date),'mm-dd-yyyy'), ' to ', datestr(cell2mat(data_end_date),'mm-dd-yyyy')]);
	
	disp('Cannot Performance Moving Average Calculation ... ');
	
	return;
	
end

price_date	= security_data(~isnan(cell2mat(security_data(:,3))),2);	% remove NaN values in the price data

price_data 	= cell2mat(FillNaNDataWithEmptyCell(security_data(:,3)));

start_index = find(datenum(price_date) >= datenum(start_date),1);	% find the start index based on the actual start date


switch MA_type

case 'Simple'

	for i = start_index : length(price_date);

		if i < MA_periods
		
			current_MA = price_data(i);
			
		else
		
			current_MA = mean(price_data(i - MA_periods + 1 : i));
			
		end
		
		MA_series = [MA_series ; price_date(i) num2cell(current_MA)];
		
	end
	
case 'Exponential'

	mov_avg = tsmovavg(price_data', 'e', MA_periods);
	
	MA_series = [price_date(start_index:end) num2cell(mov_avg(start_index:end)')];
	
otherwise

	error('Moving Average Type NOT Defined.');
	
end
	

	
	
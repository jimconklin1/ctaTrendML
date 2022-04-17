function current_MA = GenerateCurrentMovingAverage(connection, security_name, current_date, MA_periods, MA_periods_unit, MA_type)

% NOTE: This function generates the current moving average of a security based on MA_periods and MA_type.
%
% NOTE: The output is a number. The inputs connection is from config file, security_name and current_date are cells and MA_periods is a number, MA_periods_unit is a string, MA_type is a string.
%
% The MA_periods_unit has to be consistent with the data sampling frequency.
%
% MA_type: 'Simple', 'Exponential'

if nargin == 4

	MA_type = 'Simple';	% by default, MA_type is simple moving average

end

buffer_days 	= MA_periods * 10;	% this number should be large enough to ensure we have data from MA_periods ago.

data_start_date = cellstr(datestr(addtodate(datenum(cell2mat(current_date)), - buffer_days, MA_periods_unit)));

data_end_date	= current_date;

field 			= {'LAST_PRICE'};	

security_data	= GetGeneralDailyDataFromBloomberg(connection, security_name, data_start_date, data_end_date, field);

% if there is no data, just return zero value

if cellfun('isempty', security_data)

	disp(['There is NO Data for ', cell2mat(security_name), ' during time period ', datestr(data_start_date,'mm-dd-yyyy'), ' to ', datestr(data_end_date,'mm-dd-yyyy')]);
	
	disp('Cannot Performance Moving Average Calculation ... ');
	
	current_MA = 0;
	
	return;
	
end

price	= cell2mat(FillNaNDataWithEmptyCell(security_data(:,3)));	% use the last price


switch MA_type

case 'Simple'

	current_MA	= mean(price(end - MA_periods + 1 : end));
	
case 'Exponential'

	mov_avg = tsmovavg(price', 'e', MA_periods);
	
	current_MA = mov_avg(end);
	
otherwise

	error('Moving Average Type NOT Defined.');
	
end


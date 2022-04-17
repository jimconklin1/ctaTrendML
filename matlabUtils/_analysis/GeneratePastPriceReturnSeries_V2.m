function security_return_series = GeneratePastPriceReturnSeries_V2(security_data, start_date, return_period)

% This function returns the past return series of security data. security_return_series is in the CELL format [date | data].
%
% Output: security_return_series, a cell array of [date | data]
%
% Inputs: security_data, a cell array of [date | data]
%		  start_date, a cell of starting time
%		  return_period, a number of return frequency

date_series 	= security_data(:,1);	% date
price_series 	= security_data(:,2);	% price
date_return 	= date_series(1+return_period:end);	% date for past return series
data_return		= CalculateReturn(cell2mat(price_series(1:end-return_period)), cell2mat(price_series(1+return_period:end)));	% data for return series
start_index 	= find(datenum(cell2mat(date_return)) >= datenum(start_date),1);	% find the start index based on the actual start date

if ~isempty(start_index)
	security_return_series = [date_return(start_index:end) FillNaNDataWithZeroCell(num2cell(data_return(start_index:end)))];
else
	warning('Start date outside of data range.');
	security_return_series = cell(0);
end
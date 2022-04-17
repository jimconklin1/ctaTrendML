function MA_series = GenerateMovingAverageSeries_V2(security_data, start_date, MA_periods, MA_type)

% This function generates a moving average series of a security based on MA_periods and MA_type
%
% Output: MA_series, is a cell array with the format [date | data].
%
% Inputs: security_data, a cell array of [date | data]
% 		  start_date, a cell of starting date
%		  MA_periods, a number of moving average days
%		  MA_type, a string.
%
% MA_type: 'Simple', 'Exponential'

if nargin < 4 || isempty('MA_type'); MA_type = 'Simple'; end	% by default, MA_type is simple moving average

price_date	= security_data(~isnan(cell2mat(security_data(:,2))),1);	% remove NaN values in the price data
price_data 	= cell2mat(FillNaNDataWithEmptyCell(security_data(:,2)));
start_index = find(datenum(price_date) >= datenum(start_date),1);	% find the start index based on the actual start date
MA_series 	= cell(length(price_date)-start_index+1,2);

switch MA_type
case 'Simple'
	for i = start_index : length(price_date);
		if i < MA_periods	
			current_MA = price_data(i);	
		else
			current_MA = mean(price_data(i - MA_periods + 1 : i));	
		end
		MA_series(i-start_index+1,:) = [price_date(i) num2cell(current_MA)];	
	end
case 'Exponential'
	mov_avg = tsmovavg(price_data', 'e', MA_periods);
	MA_series = [price_date(start_index:end) num2cell(mov_avg(start_index:end)')];
otherwise
	warning('Moving Average Type NOT Defined.');
	MA_series = [price_date(start_index:end) num2cell(nan(size(MA_series,1),1))];
end
	

	
	
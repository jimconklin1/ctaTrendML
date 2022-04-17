function historical_vol_series = GenerateHistoricalReturnVolatilitySeries_V2(security_data, start_date, return_period, lookback_days)

% This function generates a historical volatility of security data based on lookback_days.
%
% Output: historical_vol_series, is a cell array with the format [date | data].
%
% Inputs: security_data, a cell array of [date | data], price data itself
%		  start_date, a cell of starting date
%		  return_period, a number of return frequency
%		  lookback_days, a number of lookback days to calculate vol

buffer_days 	= lookback_days * 3;	% this number should be large enough to ensure we have data from lookback_days ago.
data_start_date = cellstr(datestr(addtodate(datenum(cell2mat(start_date)), - buffer_days, 'day')));
return_series	= GeneratePastPriceReturnSeries_V2(security_data, data_start_date, return_period);

% if there is no data, just return a nil cell
if isempty(return_series)
	warning(['There is No Return Data starting from ', datestr(data_start_date,'mm-dd-yyyy'),'. Cannot calculate volatility.']);
	historical_vol_series = cell(0);
	return;
end

return_date	= return_series(~isnan(cell2mat(return_series(:,2))),1);	% remove NaN values in the price data
return_data = cell2mat(FillNaNDataWithEmptyCell(return_series(:,2)));
start_index = find(datenum(return_date) >= datenum(start_date),1);	% find the start index based on the actual start date

historical_vol_series = cell(length(return_date)-start_index+1,2);

if ~isempty(start_index)
	for i = start_index : length(return_date);
		if i - lookback_days + 1 > 0
			current_vol = std(return_data(i - lookback_days + 1 : i));
			historical_vol_series(i-start_index+1,:) = [return_date(i) num2cell(current_vol)];	
		else
			historical_vol_series(i-start_index+1,:)  = [return_date(i) nan];	
		end
	end
end
function trend_magnitude_series = GenerateTrendMagnitudeSeries_V2(security_data, start_date, MA_1, MA_2, MA_type, lookback_days)

% This function generate the trend magnitude for a specific security, given two moving averages.
%
% NOTE: The trend magnitude is on a scale from -5 to 5, -5 being extremely significant downtrend.
%
% Output: trend_magnitude_series, a cell array of  [date | data]
%
% Inputs: security_data, a cell array of [date | data]
%		  start_date, a cell
%		  MA_1, MA_2, lookback_days, all numbers
%		  MA_type, a string, 'Simple' or 'Exponential'

% define some parameters
max_magnitude 	= 5;
buffer_days 	= 100;
data_start_date = cellstr(datestr(addtodate(datenum(cell2mat(start_date)), - lookback_days - buffer_days, 'day')));

% calculate moving average series
MA_series1 	= GenerateMovingAverageSeries_V2(security_data, data_start_date, MA_1, MA_type);
MA_series2 	= GenerateMovingAverageSeries_V2(security_data, data_start_date, MA_2, MA_type);

% align data if not same size
if size(MA_series1,1) ~= size(MA_series2,1)
	disp(['Size of Moving Average Series of ', num2str(MA_1),' days and ', num2str(MA_2),' days DO NOT match.']);
	[~, idx_MA1, idx_MA2] = intersect(datenum(MA_series1(:,1)), datenum(MA_series2(:,1)));
	MA_series1 = MA_series1(idx_MA1,:);
	MA_series2 = MA_series2(idx_MA2,:);
	clear idx_MA1 idx_MA2;
end

% calculate trend magnitude
MA_diff 				= [MA_series1(:,1) num2cell(cell2mat(MA_series1(:,2)) - cell2mat(MA_series2(:,2)))];
data_percentile_short 	= GeneratePercentiledData(MA_diff, start_date, lookback_days);
trend_magnitude_series 	= [data_percentile_short(:,1) num2cell(cell2mat(data_percentile_short(:,4)) * max_magnitude)];




function trend_magnitude_series = GenerateTrendMagnitudeSeries(connection, security_name, start_date, end_date, MA_1, MA_2, MA_type, lookback_days)

% NOTE: This function generate the trend magnitude for a specific security, given two moving averages.
%
% NOTE: The trend magnitude is on a scale from -5 to 5, -5 being extremely significant downtrend.
%
% NOTE: The outputs are cell arrays [date | data]. The inputs connection is from config file, security_name, start_date, end_date are cells.
%
% NOTE: MA_1, MA_2, lookback_days are all numbers, MA_type is a string, 'Simple' or 'Exponential'


buffer_days 	= 100;

data_start_date = cellstr(datestr(addtodate(datenum(cell2mat(start_date)), - lookback_days - buffer_days, 'day')));

data_end_date	= end_date;

max_magnitude 	= 5;


MA_series1 	= GenerateMovingAverageSeries(connection, security_name, data_start_date, data_end_date, MA_1, 'day', MA_type);

MA_series2 	= GenerateMovingAverageSeries(connection, security_name, data_start_date, data_end_date, MA_2, 'day', MA_type);

if isempty(MA_series1) || isempty(MA_series2)

	disp(['Moving Average Can Not Be Calculated for : ', cell2mat(security_name)]);
	
	trend_magnitude_series = cell(0);
	
	return;

end


if size(MA_series1,1) ~= size(MA_series2,1)

	disp(['Size of Moving Average Series of ', num2str(MA_1),' days and ', num2str(MA_2),' days DO NOT match for : ', cell2mat(security_name)]);
	
	[~, idx_MA1, idx_MA2] = intersect(datenum(MA_series1(:,1)), datenum(MA_series2(:,1)));
	
	MA_series1 = MA_series1(idx_MA1,:);
	
	MA_series2 = MA_series2(idx_MA2,:);
	
	clear idx_MA1 idx_MA2;
	
end

MA_diff 				= [MA_series1(:,1) num2cell(cell2mat(MA_series1(:,2)) - cell2mat(MA_series2(:,2)))];

data_percentile_short 	= GeneratePercentiledData(MA_diff, start_date, lookback_days);

trend_magnitude_series 	= [data_percentile_short(:,1) num2cell(cell2mat(data_percentile_short(:,4)) * max_magnitude)];




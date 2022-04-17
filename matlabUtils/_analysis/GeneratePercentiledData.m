function data_percentile = GeneratePercentiledData(originalData, start_date, lookback_period)

% NOTE: This function returns a cell array with the percentiled data. format: [date | percentile_order | percentile_range]
%
% NOTE: The inputs originalData [date | data ] and start_date have to be in the CELL format. lookback_period is a number of calendar days.
%
% NOTE: In this function, we generate percentiled data based on order, range and absolute maximum.

EnoughData = 1;
date_num = datenum(originalData(:,1));

if datenum(start_date) - lookback_period < date_num(1)
	disp('Do not have enough data at the beginning of the original data set. Consider push start date later.');
	EnoughData = 0;
end

start_index = find(date_num >= datenum(start_date),1);
if EnoughData
	lookback_start = addtodate(datenum(originalData(start_index,1)), -lookback_period, 'day');
	lookback_start_index = find(date_num >= lookback_start,1);
end

data_percentile = cell(0);
for i = start_index:size(originalData,1)
	if EnoughData
		lookback_data_current = cell2mat(originalData(lookback_start_index:i,2));
		lookback_start_index = lookback_start_index + 1;
	else
		lookback_start = addtodate(datenum(originalData(start_index,1)), -lookback_period, 'day');
		lookback_start_index = find(date_num >= lookback_start,1);
		lookback_data_current = cell2mat(originalData(lookback_start_index:i,2));
	end
	if ~isempty(lookback_data_current)
		percentile_order_current  = length(lookback_data_current(lookback_data_current < lookback_data_current(end))) / length(lookback_data_current);	% from 0 to 1
		percentile_range_current  = (lookback_data_current(end) - min(lookback_data_current)) / (max(lookback_data_current) - min(lookback_data_current));	% from 0 to 1
		percentile_maxabs_current = lookback_data_current(end) / max(abs(lookback_data_current));	% from -1 to 1
		data_percentile = [data_percentile ; originalData(i,1) num2cell(percentile_order_current) num2cell(percentile_range_current) num2cell(percentile_maxabs_current)];
	end
end



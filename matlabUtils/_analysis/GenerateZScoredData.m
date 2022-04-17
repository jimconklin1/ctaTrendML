function data_zscore = GenerateZScoredData(original_data, start_date, lookback_window)

% NOTE: This function generates the z-score of the original data.
%
% NOTE: The data_zscore has the format [date | data | data | ... ].
%
% NOTE: The input original_data is a cell array [date | data | data | ...], start_date is a cell, lookback_window is a number of calendar days

if datenum(start_date) - lookback_window < datenum(original_data(1,1))

	disp('Do not have enough data at the beginning of the original data set. Consider push start date later.');
	
end

start_index = find(datenum(cell2mat(original_data(:,1))) >= datenum(start_date), 1);

lookback_start = addtodate(datenum(original_data(start_index,1)), -lookback_window, 'day');

lookback_start_index = find(datenum(cell2mat(original_data(:,1))) >= lookback_start, 1);

data_zscore = cell(0);

for i = start_index : size(original_data, 1)

	lookback_data_current = cell2mat(original_data(lookback_start_index:i,2:end));
	
	lookback_start_index = lookback_start_index + 1;
	
	if ~isempty(lookback_data_current)
	
		current_zscore = (lookback_data_current(end, :) - mean(lookback_data_current)) ./ std(lookback_data_current);
	
		data_zscore = [data_zscore ; original_data(i,1) num2cell(current_zscore)];
	
	end

end
	
	


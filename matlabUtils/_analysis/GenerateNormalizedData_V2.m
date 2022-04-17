function data_zscore = GenerateNormalizedData_V2(originalData, start_date, lookback_period)

% This function returns a cell array with the normalized data. 
%
% Output: data_zscore, a cell array of format [date | normal CDF percent | z_score]
%
% Inputs: originalData, a cell array of [date | data]
%		  start_date, a cell of starting date
%		  lookback_period, a number indicating how many calendar days
%
% NOTE: In this function, to generate the probability, we use the normal distribution.

if datenum(start_date) - lookback_period < datenum(originalData(1,1))
	disp('Do not have enough data at the beginning of the original data set. Consider push start date later.');
end

start_index = find(datenum(cell2mat(originalData(:,1))) >= datenum(start_date),1);
data_zscore = cell(size(originalData,1)-start_index+1,3);
date_num	= datenum(originalData(:,1));

for i = start_index:size(originalData,1)	
	% find start index
	lookback_start = addtodate(datenum(originalData(i,1)), -lookback_period, 'day');	
	lookback_start_index = find(date_num >= lookback_start,1);	
	lookback_data_current = cell2mat(originalData(lookback_start_index:i,2));
	
	% calculate norm distribution
	if ~isempty(lookback_data_current)
		lookback_average = mean(lookback_data_current);
		lookback_stdev = std(lookback_data_current);
		current_normcdf_prob = num2cell(normcdf(lookback_data_current(end),lookback_average,lookback_stdev));
		current_zscore = (lookback_data_current(end) - lookback_average) / lookback_stdev;
	else
		disp('No Data In The Lookback Period!');
		current_normcdf_prob = {1};
		current_zscore = {inf};
	end
	data_zscore(i-start_index+1,:) = [originalData(i,1), current_normcdf_prob current_zscore];
end

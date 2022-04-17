function data_zscore = GenerateNormalizedData(connection, name, originalData, lookback_period, field)

% NOTE: This function returns a cell array with the normalized data. format: [date | normal CDF percent | z_score]
%
% NOTE: The inputs connection is from config file, name and originalData [date | data] have to be in the CELL format. lookback_period is a number indicating how many days. field is a cell string.
%
% NOTE: In this function, to generate the probability, we use the normal distribution.


buffer_period = 100;	% This is an arbitrary number that we use to get this more data to avoid any data gap.

data_start_date = cellstr(datestr(addtodate(datenum(cell2mat(originalData(1,1))), -lookback_period - buffer_period, 'day')));

data_end_date = originalData(end,1);

extended_data = GetGeneralDailyDataFromBloomberg(connection, name, data_start_date, data_end_date, field);

for i = 1:size(originalData,1)

	start_date = addtodate(datenum(cell2mat(originalData(i,1))), -lookback_period, 'day');
	
	start_index = find(datenum(cell2mat(extended_data(:,2))) >= start_date,1);
	
	end_date = datenum(cell2mat(originalData(i,1)));
	
	end_index = find(datenum(cell2mat(extended_data(:,2))) >= end_date,1);
	
	lookback_data = extended_data(start_index:end_index,:);
	
	if ~cellfun('isempty',lookback_data)
	
		lookback_average = mean(cell2mat(lookback_data(:,3)));	% Here we only look at the last price.
		
		lookback_stdev = std(cell2mat(lookback_data(:,3)));
		
		current_normcdf_prob = num2cell(normcdf(cell2mat(originalData(i,2)),lookback_average,lookback_stdev));
		
		current_zscore = (cell2mat(originalData(i,2)) - lookback_average) / lookback_stdev;
		
	else
	
		disp('No Data In The Lookback Period!');
		
		current_normcdf_prob = {1};
	
		current_zscore = {inf};
		
	end
		
	data_zscore(i,:) = [originalData(i,1) current_normcdf_prob current_zscore];

end
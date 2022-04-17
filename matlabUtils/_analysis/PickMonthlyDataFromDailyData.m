function data_picked = PickMonthlyDataFromDailyData(original_data, pick_frequency, data_position)

% NOTE: This function picks monthly data from the daily data series on interval based on pick_frequency.
%
% NOTE: The output data_picked is a cell array of format [date | data | data | ...].
%
% NOTE: The input original_data is a cell array of the same format as output. 
%
% NOTE: pick_frequency is a number indicators how many months being the interval.
%
% NOTE: data_position is a string, either 'MonthStart' or 'MonthEnd'. deciding which data to pick, default to 'MonthEnd'.
%
% NOTE: This function won't be good for data already sparse.

data_picked = cell(0);

if cellfun('isempty', original_data)

	disp('No Original Daily Data.');

	return;

end

interval = pick_frequency;

for i = 2:size(original_data,1)

	datevec_current = datevec(original_data(i,1));
	
	datevec_previous = datevec(original_data(i-1,1));
	
	if datevec_current(1) ~= datevec_previous(1) || datevec_current(2) ~= datevec_previous(2)

		if interval == pick_frequency
		
			if strcmp(data_position, 'MonthStart')
			
				data_picked = [data_picked ; original_data(i,:)];
				
			elseif strcmp(data_position, 'MonthEnd')
			
				data_picked = [data_picked ;  original_data(i-1,:)];
				
			else
			
				data_picked = [data_picked ;  original_data(i-1,:)];
				
			end
			
			interval = 1;
			
		else
		
			interval = interval + 1;
			
		end
		
	end
	
end




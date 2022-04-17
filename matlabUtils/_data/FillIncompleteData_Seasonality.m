function filledData = FillIncompleteData_Seasonality(data, seasonality_type)

% This function aligns the seasonal data with different sizes and combine data together.
% Here we use all the non-reptitative dates for a defined season, year, month, or day.
%
% The output: filledData is a cell array with [date | data | data ...], here date depends on the seasonality_type
%
% The input: data is a struct of cell arrays of [date | data], in names data1, data2, data3 ...
%			 seasonality_type is a string, indicating which seasonal effect we are looking at
%
% NOTE: seasonality_type: 'year', we look at same month and day during a year
%						  'month', we look at same day during a month
%						  'day', we look at same time during a day

no_of_data = length(fieldnames(data));

if no_of_data == 0

	error('No Data.');
	
end

filledData = cell(0);

if no_of_data == 1

	filledData = data.data1;
	
	disp('Only one time series. Just return the series itself.');
	
	return;
	
end
	
	
% decide date vector columns to look at and date format	

if strcmp(seasonality_type, 'year')

	datevec_column = [2,3];
	
	date_format = 'mm/dd';
	
elseif strcmp(seasonality_type, 'month')

	datevec_column = [3];
	
	date_format = 'dd';
	
elseif strcmp(seasonality_type, 'day')

	datevec_column = [4,5,6];
	
	date_format = 'HH:MM:SS';
	
else

	error('Seasonality Type is NOT Defined.');
	
end


% get common dates or time

date_vec1 = datevec(data.data1(:,1));

date_vec2 = datevec(data.data2(:,1));

combined_date = union(date_vec1(:,datevec_column), date_vec2(:,datevec_column), 'rows');

if no_of_data > 2

	for i = 3:no_of_data
	
		data_current = data.(['data',num2str(i)]);
		
		date_vec_current = datevec(data_current(:,1));
	
		combined_date = union(combined_date, date_vec_current(:,datevec_column), 'rows');
	
	end

end

combined_date_vec = zeros(size(combined_date,1),6);

combined_date_vec(:,1) = 2015;	% this could be any random number

combined_date_vec(:,datevec_column) = combined_date;

filledData = cellstr(datestr(combined_date_vec, date_format));


% add each entry

for i = 1:no_of_data

	data_current = data.(['data',num2str(i)]);
	
	date_vec_current = datevec(data_current(:,1));

	temp = cell(size(combined_date,1),1);

	[~, idx1, idx2] = intersect(combined_date, date_vec_current(:,datevec_column), 'rows');
	
	temp(idx1) = data_current(idx2, 2);	% this is probably the most important step
	

	temp = FillMissingData(temp);	% these two apply to NaN and empty cells in the middle
		
	temp = FillNaNData(temp);
		
	temp = FillNaNData_Backward(temp);	% these two only apply to NaN and empty cells at the beginning
		
	temp = FillMissingData_Backward(temp);

	
	filledData = [filledData temp];
	
end


	
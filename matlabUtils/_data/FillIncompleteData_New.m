function filledData = FillIncompleteData_New(data, KeepNaN)

% This function aligns the data with different sizes and combine data together.
% Here we use all the non-reptitative dates.
%
% The output: filledData is a cell array with [date | data | data ...]
%
% The input: data is a struct of cell arrays of [date | data], in names of data1, data2,...
%			 KeepNaN, a number, indicating how to handle NaN data
%
% NOTE: If KeepNaN is 0, then do the following:
% 			All missing data and NaN data will carry the values from previous day.
% 			All empty or NaN cells at the beginning will be filled with 0.
%		If KeepNaN is 1, then do the following:
%			All missing data will be replaced by NaN data.
%			All NaN data will be kept.

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


% find common dates

combined_date = union(datenum(data.data1(:,1)),datenum(data.data2(:,1)));

if no_of_data > 2

	for i = 3:no_of_data
	
		data_current = data.(['data',num2str(i)]);
	
		combined_date = union(combined_date, datenum(data_current(:,1)));
	
	end

end

filledData = cellstr(datestr(combined_date));


% add each entry

for i = 1:no_of_data

	data_current = data.(['data',num2str(i)]);

	temp = cell(size(combined_date));

	[~, idx1, idx2] = intersect(combined_date, datenum(data_current(:,1)));
	
	temp(idx1) = data_current(idx2, 2);	% this is probably the most important step
	
	if KeepNaN
	
		temp = FillMissingDataWithNaNCell(temp);
		
	else
	
		temp = FillMissingData(temp);	% these two apply to NaN and empty cells in the middle
		
		temp = FillNaNData(temp);
		
		temp = FillNaNDataWithZeroCell(temp);	% these two only apply to NaN and empty cells at the beginning
		
		temp = FillMissingDataWithZeroCell(temp);
		
	end
	
	filledData = [filledData temp];
	
end


	
function filledData = FillIncompleteData(data_struct)

% NOTE: This function takes a struct as an input with all the entries to be cell arrays with different size.
%
% NOTE: Each cell array has to be in the format of [date | data].
%
% NOTE: It returns a cell array with first column to be date and the rest columns to be the data with all equal sizes.
%
% NOTE: All empty cells will be filled with 0.

for i = 1 : length(fieldnames(data_struct))

	data_size(i) = size(data_struct.(['data',num2str(i)]),1);

end

[max_size, idx] = max(data_size);

data_base = data_struct.(['data',num2str(idx)]);

filledData = cell(0);

filledData(:,1) = data_base(:,1);

filledData(:,1 + idx) = FillNaNData(data_base(:,2));

for j = 1 : length(fieldnames(data_struct))

	if j ~= idx
	
		data_current = data_struct.(['data',num2str(j)]);
		
		temp = cell(size(data_base));
		
		temp(:,1) = data_base(:,1);
		
		[common, idx1, idx2] = intersect(datenum(cell2mat(temp(:,1))), datenum(cell2mat(data_current(:,1))));
		
		temp(idx1,2) = data_current(idx2,2);
		
		temp = FillMissingData(temp);
		
		temp(:,2) = FillNaNData(temp(:,2));
		
		filledData(:,1 + j) = temp(:,2); % only need data; date is on the first column
	
	end
	
end

emptyIndex = cellfun('isempty',filledData);

filledData(emptyIndex) = {0};
function cleanedData = RemoveRowsWithInvalidNumbers(originalData)

% NOTE: This function removes the rows of a matrix with any invalid number, i.e., inf and NaN.
%
% NOTE: The output is a matrix with possibly reduced size of the original matrix.
%
% NOTE: The input originalData is a NxP matrix, where P is the number of different assets.

cleanedData = [];

for i = 1:size(originalData,1)

	if all(isfinite(originalData(i,:)))
	
		cleanedData = [cleanedData ; originalData(i,:)];
		
	end

end
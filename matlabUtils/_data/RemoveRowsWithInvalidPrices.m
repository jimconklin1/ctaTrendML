function cleanedPriceData = RemoveRowsWithInvalidPrices(originalPriceData)

% NOTE: This function removes the rows of a cell array with any invalid number, i.e., inf and NaN.
%
% NOTE: The output is a cell array with possibly reduced size of the original cell array.
%
% NOTE: The input originalPriceData is a cell array [date | price | price | ...].

cleanedPriceData = cell(0);

for i = 1:size(originalPriceData,1)

	if all(isfinite(cell2mat(originalPriceData(i,2:end))))
	
		cleanedPriceData = [cleanedPriceData ; originalPriceData(i,:)];
		
	end

end
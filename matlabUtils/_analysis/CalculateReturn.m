function data_return = CalculateReturn(data_1, data_2)

% NOTE: This generic function will just calculate the return from data_1 to data_2.
%
% NOTE: The output data_return is a NxP matrix, where N is the number of data points, P is the number of assets (securities or index).
%
% NOTE: The inputs data_1 and data_2 have the same format, NxP matrix as data_return.

if size(data_1,1) ~= size(data_2,1) | size(data_1,2) ~= size(data_2,2)

	error('Two Data Sets are NOT in the SAME size. Cannot calculate return. ');
	
end

% Here we just allow invalid return numbers, e.g., inf and NaN. But later we need to remove the rows with invalid numbers.

data_return = (data_2 - data_1) ./ abs(data_1);

data_return(data_2 == data_1) = 0;	% This is taking account into the case where both elements equal to 0.

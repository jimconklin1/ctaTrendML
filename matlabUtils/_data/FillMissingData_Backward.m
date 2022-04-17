function filledPrice = FillMissingData_Backward(price)

% NOTE: This function fills empty data in price cell array, format: [date | data | data ...] or [data | data ...], in a backward basis
%       Essentially, it is filling the missing data at the beginning
% NOTE: Price cell array shouldn't have any empty cell at the end since they won't get filled

filledPrice = price;

for i = size(filledPrice, 1) -1 : -1 : 1

    emptyData = cellfun('isempty', filledPrice(i, :));
	
    filledPrice(i, emptyData) = filledPrice(i + 1, emptyData);
	
end
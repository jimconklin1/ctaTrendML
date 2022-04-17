function filledPrice = FillMissingData(price)

% NOTE: This function fills empty data in price cell array, format: [date | data | data ...] or [data | data ...]
% NOTE: Price cell array shouldn't have any empty cell at the beginning since they won't get filled

filledPrice = price;

for i = 2:size(filledPrice, 1)

    emptyData = cellfun('isempty', filledPrice(i, :));
	
    filledPrice(i, emptyData) = filledPrice(i - 1, emptyData);
	
end
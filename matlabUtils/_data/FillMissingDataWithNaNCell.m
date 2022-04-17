function filledPrice = FillMissingDataWithNaNCell(price)

% NOTE: This function fills empty data in price cell array with NaN cells.
%
% format: [date | data | data ...] or [data | data ...]

filledPrice = price;

for i = 1:size(filledPrice, 1)

    emptyData = cellfun('isempty', filledPrice(i, :));
	
    filledPrice(i, emptyData) = {NaN};
	
end
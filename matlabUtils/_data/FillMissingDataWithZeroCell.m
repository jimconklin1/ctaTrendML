function filledPrice = FillMissingDataWithZeroCell(price)

% NOTE: This function fills empty data with zero cells in price cell array, format: [date | data | data ...] or [data | data ...]
%
% NOTE: We use this function only to fill in empty cells at the beginning of the price data.

filledPrice = price;

emptyIndex = cellfun('isempty', filledPrice);

filledPrice(emptyIndex) = {0};




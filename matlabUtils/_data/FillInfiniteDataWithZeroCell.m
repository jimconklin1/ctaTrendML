function filledPrice = FillInfiniteDataWithZeroCell(price)

% NOTE: This function fills Infinite data in price cell array
% NOTE: The input price data should only contain price information, NOT DATE!

filledPrice = price;

for i = 1:size(filledPrice, 1)

	infData = ~isfinite(cell2mat(filledPrice(i, :)));
	
	filledPrice(i, infData) = {0};
	
end
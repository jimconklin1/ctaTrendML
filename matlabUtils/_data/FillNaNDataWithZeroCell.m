function filledPrice = FillNaNDataWithZeroCell(price)

% NOTE: This function fills NaN data in price cell array [data | data ...]
% NOTE: The input price data should only contain price information, NOT DATE!

filledPrice = price;

for i = 1:size(filledPrice, 1)

	nanData = isnan(cell2mat(filledPrice(i, :)));
	
	filledPrice(i, nanData) = {0};
	
end
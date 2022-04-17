function filledPrice = FillNaNData_Backward(price)

% NOTE: This function fills NaN data in price cell array [data | data ...], on the backward order.
% 		Essentially, it is filling the NaN data at the beginning.
% NOTE: The input price data should only contain price information, NOT DATE!

filledPrice = price;

for i = size(filledPrice, 1)-1 : -1 : 1

	nanData = isnan(cell2mat(filledPrice(i, :)));
	
	filledPrice(i, nanData) = filledPrice(i + 1, nanData);
	
end
function return_series = GenerateReturnSeries(security_name, historical_price, trading_signal)

% NOTE: This function can handle both long and short positions!
%
% NOTE: So far, this function does NOT handle size changing during the trades!
%
% security_name = 1x1 cell
%
% historical_price = nx2 cell array with first column be the price date and second column be the price
%
% trading_signal = nx1 matrix, 0 means no trade, 1 means long, -1 means short

if size(historical_price,1) ~= size(trading_signal,1)

	error('Historical price does NOT match trading signal!');
	
end

column_name 		= 1;

column_date 		= 2;

column_return 		= 3;

% initialization
return_series = cell(0);

for i = 1:length(trading_signal) 

	return_series(i, column_name) = security_name;
	
	return_series(i, column_date) = historical_price(i,1);
	
	if i == 1 || (trading_signal(i) == 0 && trading_signal(i-1) == 0)
	
		return_series(i, column_return) = num2cell(0);
			
	else
		
		return_series(i, column_return) = num2cell(CalculateReturn(cell2mat(historical_price(i-1,2)), cell2mat(historical_price(i,2))) * trading_signal(i-1));	
		
	end	

end
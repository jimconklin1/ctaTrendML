function [trading_history, realized_pnl_history, live_pnl_history] = GenerateTradeHistoryAndPnLSeries(security_name, historical_price, trading_signal, bid_ask_included, commission, execution_time)

% This is a new version of function GenerateLongShortTradeHistory().
%
% NOTE: This function returns a Nx8 cell arrays with the following information.
%		This function also returns a Nx2 cell array with realized pnl information along the trading signal [date | pnl].
%		This function also returns a Nx2 cell array with live pnl information along the trading signal [date | pnl].
%		Both realized and live pnl information handle both bid-ask spread and commission fees.
%		This function can handle both long and short signals.
%		This function can also handle size change during trades. Essentially, when size changes, the trades is treated as a new trade.
%		This function can handle commission fee. Right now only handle stocks, commission fee = $/per share. This can be extended.
%
% The inputs: security_name = 1x1 cell
%		      historical_price = nx3 cell array [ date | price_close | price_open | bid-ask spread]
%			  trading_signal = nx1 matrix, 0 means no trade, x means long, -x means short, x could be any positive number.
%			  bid_ask_included = number, 0 means no spread included, 1 means including bid-ask spread.
%			  commission = 1x1 number, enter "[]" to ignore commission.
%			  execution_time, string indicating time of execution, "close", "next_open", "next_close"

if nargin < 6 || isempty(execution_time)
	execution_time = 'close';
end

if size(historical_price,1) ~= size(trading_signal,1)
	error('Historical price does NOT match trading signal!');
end

column_name 		= 1;
column_entrydate 	= 2;
column_exitdate 	= 3;
column_entryprice 	= 4;
column_exitprice 	= 5;
column_longorshort 	= 6;
column_pnl 			= 7;
column_hitormiss 	= 8;

columnName(column_name) 		= {'Security'};
columnName(column_entrydate) 	= {'Entry Date'};
columnName(column_exitdate) 	= {'Exit Date'};
columnName(column_entryprice) 	= {'Entry Price'};
columnName(column_exitprice) 	= {'Exit Price'};
columnName(column_longorshort) 	= {'Long or Short'};
columnName(column_pnl) 			= {'P&L'};
columnName(column_hitormiss) 	= {'Hit or Miss'};

% initialization
trading_history 		= cell(0);
live_pnl_history 		= [historical_price(:,1) num2cell(zeros(size(historical_price,1),1))];
realized_pnl_history	= live_pnl_history;
in_trade_flag 			= 0;
current_trade 			= 1;
bid_ask_ratio			= 1;	% full spread
bid_ask_column			= 4;

% handle execution time
switch execution_time
case 'close'
	delay = 0;
	exe_px_column = 2;
case 'next_open'
	delay = 1;
	exe_px_column = 3;
case 'next_close'
	delay = 1;
	exe_px_column = 2;
otherwise
	disp('execution time not defined. use close by default.');
	delay = 0;
	exe_px_column = 2;
end

% commission
if isempty(commission)
	commission = 0;
end

% fill in data
for i = 1:length(trading_signal)  
	if in_trade_flag	% in a trade
		if trading_signal(i) ~= trading_signal(i-1) || i == length(trading_signal)	% signal change (both exit a trade or size change) or last day
			if i == length(trading_signal)
				trading_history(current_trade, column_exitdate) 	= historical_price(i,1);
			else
				trading_history(current_trade, column_exitdate) 	= historical_price(i+delay,1);
			end
			if bid_ask_included & ~isnan(cell2mat(historical_price(i,bid_ask_column)))
				if i == length(trading_signal)
					trading_history(current_trade, column_exitprice) = num2cell(cell2mat(historical_price(i,2)) - cell2mat(historical_price(i,bid_ask_column)) * sign(trading_signal(i - 1)) * bid_ask_ratio);
				else
					trading_history(current_trade, column_exitprice) = num2cell(cell2mat(historical_price(i+delay,exe_px_column)) - cell2mat(historical_price(i+delay,bid_ask_column)) * sign(trading_signal(i - 1)) * bid_ask_ratio);
				end
			else
				if i == length(trading_signal)
					trading_history(current_trade, column_exitprice) = historical_price(i,2);	
				else
					trading_history(current_trade, column_exitprice) = historical_price(i+delay,exe_px_column);	
				end
			end
			trading_history(current_trade, column_pnl) = num2cell(CalculateReturn(cell2mat(trading_history(current_trade, column_entryprice)), cell2mat(trading_history(current_trade, column_exitprice))) ...
																* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);												
			if i - 1 == 1 || trading_signal(i-1) ~= trading_signal(i-2)	% only hold for 1 day
				if delay > 0
					if i == length(trading_signal)
						live_pnl_history(i,2)	= num2cell(cell2mat(live_pnl_history(i,2)) + (cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(trading_history(current_trade, column_entryprice))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
												* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
					else
						live_pnl_history(i,2)	= num2cell(cell2mat(live_pnl_history(i,2)) + (cell2mat(historical_price(i,2)) - cell2mat(trading_history(current_trade, column_entryprice))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
												* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
						live_pnl_history(i+1,2)	= num2cell(cell2mat(live_pnl_history(i+1,2)) + (cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(historical_price(i,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
												* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
					end
				else
					live_pnl_history(i,2)	= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(trading_history(current_trade, column_entryprice))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
											* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);	
				end
			else	% hold for more than 1 day
				if delay > 0
					if i == length(trading_signal)
						live_pnl_history(i,2)	= num2cell(cell2mat(live_pnl_history(i,2)) + (cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
												* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
					else
						live_pnl_history(i,2)	= num2cell(cell2mat(live_pnl_history(i,2)) + (cell2mat(historical_price(i,2)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
												* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
						live_pnl_history(i+1,2)	= num2cell(cell2mat(live_pnl_history(i+1,2)) + (cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(historical_price(i,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
												* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
					end
				else
					live_pnl_history(i,2)	= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
											* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);	
				end													
			end								
			trading_history(current_trade, column_hitormiss) 		= num2cell(cell2mat(trading_history(current_trade, column_pnl)) >= 0);
			if i == length(trading_signal)
				realized_pnl_history(i,:) 							= [historical_price(i,1) trading_history(current_trade, column_pnl)];
			else
				realized_pnl_history(i+delay,:) 					= [historical_price(i+delay,1) trading_history(current_trade, column_pnl)];
			end
			in_trade_flag 	 = 0;
			current_trade 	 = current_trade + 1;  
			
			if trading_signal(i) ~= 0 && i ~= length(trading_signal)	% size change, exclude last day
				trading_history(current_trade, column_name) 			= security_name;
				trading_history(current_trade, column_entrydate) 		= historical_price(i+delay,1);
				if bid_ask_included & ~isnan(cell2mat(historical_price(i+delay,bid_ask_column)))
					trading_history(current_trade, column_entryprice) 	= num2cell(cell2mat(historical_price(i+delay,exe_px_column)) + cell2mat(historical_price(i+delay,bid_ask_column)) * sign(trading_signal(i)) * bid_ask_ratio);	
				else
					trading_history(current_trade, column_entryprice) 	= historical_price(i+delay,exe_px_column);	
				end
				trading_history(current_trade, column_longorshort) 		= num2cell(trading_signal(i));
				in_trade_flag 		= 1; 
			end	
		else	% continue the same trade
			if i - 1 == 1 || trading_signal(i-1) ~= trading_signal(i-2)	% first day in trade, should take into account the bid-ask spread
				live_pnl_history(i,2) = num2cell(cell2mat(live_pnl_history(i,2)) + CalculateReturn(cell2mat(trading_history(current_trade, column_entryprice)), cell2mat(historical_price(i,2))) * trading_signal(i-1));	
			else	% start from second day in trade, return should be based on price itself, nominated by the entry price
				live_pnl_history(i,2) = num2cell(cell2mat(live_pnl_history(i,2)) + (cell2mat(historical_price(i,2)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) * trading_signal(i-1));	
			end
		end
	else	% not in a trade
		if i ~= length(trading_signal) && trading_signal(i) ~= 0	% enter a trade
			trading_history(current_trade, column_name) 			= security_name;
			trading_history(current_trade, column_entrydate) 		= historical_price(i+delay,1);	
			if bid_ask_included & ~isnan(cell2mat(historical_price(i+delay,bid_ask_column)))
				trading_history(current_trade, column_entryprice) 	= num2cell(cell2mat(historical_price(i+delay,exe_px_column)) + cell2mat(historical_price(i+delay,bid_ask_column)) * sign(trading_signal(i)) * bid_ask_ratio);	
			else
				trading_history(current_trade, column_entryprice) 	= historical_price(i+delay,exe_px_column);	
			end
			number_of_shares 										= abs(trading_signal(i)) / cell2mat(historical_price(i+delay,exe_px_column));	
			trading_history(current_trade, column_longorshort) 		= num2cell(trading_signal(i));
			in_trade_flag 		= 1; 	
		end
	end
end	
trading_history = [columnName; trading_history];



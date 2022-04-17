function [trading_history, realized_pnl_history, live_pnl_history] = GenerateLongShortTradeHistory(security_name, historical_price, trading_signal, bid_ask_included, commission)

% NOTE: This function returns a Nx8 cell arrays with the following information.
%
% NOTE: This function also returns a Nx2 cell array with realized pnl information along the trading signal [date | pnl].
%
% NOTE: This function also returns a Nx2 cell array with live pnl information along the trading signal [date | pnl].
%
% NOTE: Both realized and live pnl information handle both bid-ask spread and commission fees.
%
% NOTE: This function can handle both long and short signals.
%
% NOTE: This function can also handle size change during trades. Essentially, when size changes, the trades is treated as a new trade.
%
% NOTE: This function can handle commission fee. Right now only handle stocks, commission fee = $/per share. This can be extended.
%
% security_name = 1x1 cell
%
% historical_price = nx3 cell array with first column be the price date and second column be the price, the third column be the bid-ask spread (actual value)
%
% trading_signal = nx1 matrix, 0 means no trade, x means long, -x means short, x could be any positive number.
%
% bid_ask_included = 1x1 number, 0 means no spread included, 1 means including bid-ask spread. Now, we only do HALF-spread in the function.
%
% commission = 1x1 number, enter "[]" to ignore commission.


[trading_history, realized_pnl_history, live_pnl_history] = GenerateTradeHistoryAndPnLSeries(security_name, historical_price, trading_signal, bid_ask_included, commission);


%%%%%%%%%%% Following is the old code. Not in use anymore. %%%%%%%%%%%%%

%if size(historical_price,1) ~= size(trading_signal,1)
%
%	error('Historical price does NOT match trading signal!');
%	
%end
%
%column_name 		= 1;
%
%column_entrydate 	= 2;
%
%column_exitdate 	= 3;
%
%column_entryprice 	= 4;
%
%column_exitprice 	= 5;
%
%column_longorshort 	= 6;
%
%column_pnl 			= 7;
%
%column_hitormiss 	= 8;
%
%columnName(column_name) 		= {'Security'};
%
%columnName(column_entrydate) 	= {'Entry Date'};
%
%columnName(column_exitdate) 	= {'Exit Date'};
%
%columnName(column_entryprice) 	= {'Entry Price'};
%
%columnName(column_exitprice) 	= {'Exit Price'};
%
%columnName(column_longorshort) 	= {'Long or Short'};
%
%columnName(column_pnl) 			= {'P&L'};
%
%columnName(column_hitormiss) 	= {'Hit or Miss'};
%
%% initialization
%trading_history 		= cell(0);
%
%realized_pnl_history 	= cell(0);
%
%in_trade_flag 			= 0;
%
%current_trade 			= 1;
%
%live_pnl_history 		= [historical_price(:,1) num2cell(zeros(size(historical_price,1),1))];
%
%for i = 1:length(trading_signal)  
%
%	% calculate live mark-to-market pnl history, except when a trade is at exit
%	
%	if in_trade_flag == 1 && trading_signal(i) == trading_signal(i-1)
%	
%		if i - 1 == 1 || trading_signal(i-1) ~= trading_signal(i-2)	% first day in trade, should take into account the bid-ask spread
%		
%			live_pnl_history(i,2) = num2cell(CalculateReturn(cell2mat(trading_history(current_trade, column_entryprice)), cell2mat(historical_price(i,2))) * trading_signal(i-1));
%		
%		else	% start from second day in trade, return should be based on price itself, nominated by the entry price
%		
%			live_pnl_history(i,2) = num2cell((cell2mat(historical_price(i,2)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) * trading_signal(i-1));
%	
%		end
%	
%	end
%	
%	
%	% calculate trade history and realized pnl history, and live pnl history when trades are at exit
%   
%    if i ~= length(trading_signal) && trading_signal(i) ~= 0 && in_trade_flag == 0		% clean enter in trade
%	
%		trading_history(current_trade, column_name) 			= security_name;
%		
%        trading_history(current_trade, column_entrydate) 		= historical_price(i,1);
%		
%		if bid_ask_included & ~isnan(cell2mat(historical_price(i,3)))
%		
%			trading_history(current_trade, column_entryprice) 	= num2cell(cell2mat(historical_price(i,2)) + cell2mat(historical_price(i,3)) * sign(trading_signal(i)) / 2);
%	
%		else
%		
%			trading_history(current_trade, column_entryprice) 	= historical_price(i,2);
%		
%		end
%		
%		if ~isempty(commission)
%		
%			number_of_shares = abs(trading_signal(i)) / cell2mat(historical_price(i,2));
%		
%		end
%		
%        trading_history(current_trade, column_longorshort) 		= num2cell(trading_signal(i));
%		
%		realized_pnl_history(i,:) 								= [historical_price(i,1) {0}];
%		
%        in_trade_flag 		= 1; 
%		
%	end
%	
%		
%    if trading_signal(i) == 0 && in_trade_flag == 1 || trading_signal(i) ~= 0 && i == length(trading_signal) && trading_signal(i-1) ~= 0	% clean exit out trade
%	
%        trading_history(current_trade, column_exitdate) 		= historical_price(i,1);
%
%		if bid_ask_included & ~isnan(cell2mat(historical_price(i,3)))
%		
%			trading_history(current_trade, column_exitprice) 	= num2cell(cell2mat(historical_price(i,2)) - cell2mat(historical_price(i,3)) * sign(trading_signal(i - 1)) / 2);
%		
%		else
%	
%			trading_history(current_trade, column_exitprice) 	= historical_price(i,2);
%
%		end
%		
%		
%		trading_history(current_trade, column_pnl) 				= num2cell(CalculateReturn(cell2mat(trading_history(current_trade, column_entryprice)), cell2mat(trading_history(current_trade, column_exitprice))) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)));
%																
%		if ~isempty(commission)
%		
%			trading_history(current_trade, column_pnl)			= num2cell(cell2mat(trading_history(current_trade, column_pnl)) - number_of_shares * commission);
%			
%			if i - 1 == 1 || trading_signal(i-1) ~= trading_signal(i-2)	% only hold for 1 day
%			
%				live_pnl_history(i,2)							= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(trading_history(current_trade, column_entryprice))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
%																
%			else	% hold for more than 1 day
%			
%				live_pnl_history(i,2)							= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
%																
%			end
%			
%		else
%		
%			if i - 1 == 1 || trading_signal(i-1) ~= trading_signal(i-2)	% only hold for 1 day
%	
%				live_pnl_history(i,2)							= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(trading_history(current_trade, column_entryprice))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)));
%																
%			else	% hold for more than 1 day
%			
%				live_pnl_history(i,2)							= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)));
%			
%			end
%			
%		end
%														
%        trading_history(current_trade, column_hitormiss) 		= num2cell(cell2mat(trading_history(current_trade, column_pnl)) >= 0);
%
%		realized_pnl_history(i,:) 								= [historical_price(i,1) trading_history(current_trade, column_pnl)];		
%		
%        in_trade_flag 	 = 0;  
%		
%        current_trade 	 = current_trade + 1;  
%		
%	else
%	
%		realized_pnl_history(i,:) = [historical_price(i,1) {0}];
%		
%    end 
%	
%	
%	if i ~= 1 && i ~= length(trading_signal) && trading_signal(i) ~= trading_signal(i-1) && trading_signal(i) ~= 0 && trading_signal(i-1) ~= 0	% size changes or position flips
%	
%		% take care of the previous trade
%	
%		trading_history(current_trade, column_exitdate) 		= historical_price(i,1);
%
%		if bid_ask_included & ~isnan(cell2mat(historical_price(i,3)))
%		
%			trading_history(current_trade, column_exitprice) 	= num2cell(cell2mat(historical_price(i,2)) - cell2mat(historical_price(i,3)) * sign(trading_signal(i - 1)) / 2);
%		
%		else
%	
%			trading_history(current_trade, column_exitprice) 	= historical_price(i,2);
%
%		end
%		
%		trading_history(current_trade, column_pnl) 				= num2cell(CalculateReturn(cell2mat(trading_history(current_trade, column_entryprice)), cell2mat(trading_history(current_trade, column_exitprice))) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)));
%																
%		if ~isempty(commission)
%		
%			trading_history(current_trade, column_pnl)			= num2cell(cell2mat(trading_history(current_trade, column_pnl)) - number_of_shares * commission);
%			
%			if i - 1 == 1 || trading_signal(i-1) ~= trading_signal(i-2)	% only hold for 1 day
%			
%				live_pnl_history(i,2)							= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(trading_history(current_trade, column_entryprice))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
%																
%			else	% hold for more than 1 day
%			
%				live_pnl_history(i,2)							= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)) - number_of_shares * commission);
%																
%			end
%			
%		else
%		
%			if i - 1 == 1 || trading_signal(i-1) ~= trading_signal(i-2)	% only hold for 1 day
%	
%				live_pnl_history(i,2)							= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(trading_history(current_trade, column_entryprice))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)));
%																
%			else	% hold for more than 1 day
%			
%				live_pnl_history(i,2)							= num2cell((cell2mat(trading_history(current_trade, column_exitprice)) - cell2mat(historical_price(i-1,2))) / cell2mat(trading_history(current_trade, column_entryprice)) ...
%																* cell2mat(trading_history(current_trade, column_longorshort)));
%			
%			end
%		
%		end														
%														
%        trading_history(current_trade, column_hitormiss) 		= num2cell(cell2mat(trading_history(current_trade, column_pnl)) >= 0);
%
%		realized_pnl_history(i,:) 								= [historical_price(i,1) trading_history(current_trade, column_pnl)];		
%		
%        in_trade_flag 	 = 0;  
%		
%        current_trade 	 = current_trade + 1;  
%		
%		% on the same day, a new trade starts
%		
%		trading_history(current_trade, column_name) 			= security_name;
%		
%        trading_history(current_trade, column_entrydate) 		= historical_price(i,1);
%		
%		if bid_ask_included & ~isnan(cell2mat(historical_price(i,3)))
%		
%			trading_history(current_trade, column_entryprice) 	= num2cell(cell2mat(historical_price(i,2)) + cell2mat(historical_price(i,3)) * sign(trading_signal(i)) / 2);
%	
%		else
%		
%			trading_history(current_trade, column_entryprice) 	= historical_price(i,2);
%		
%		end
%	
%        trading_history(current_trade, column_longorshort) 		= num2cell(trading_signal(i));
%		
%        in_trade_flag 		= 1; 
%		
%	end
%	
%end
%
%trading_history = [columnName; trading_history];
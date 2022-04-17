function result = PerformanceSummary(data)

% This function generates the performance metrics and trade history of a particular strategy.
%
% The output: result is a struct of structs of Asset1, Asset2, ... AssetN, and combined_result
%
% Asseti is a struct of: 1) trading_signal
%						 2) trading_history
%						 3) live_pnl_history				
%						 4) performance	
%
% combined_result is a struct of: 1) trading_history_total
%								  2) position_portfolio
%								  3) live_pnl_portfolio
%								  4) live_pnl_percent_portfolio				
%								  5) overall_performance
%
% The input: data is a struct of 1) connection, from config file
%								 2) ticker_names, a cell array
%								 3) price_close, a cell array [date | data]	
%								 4) price_open, a cell array [date | data], could be non-existent, in which case use close price	
%								 5) trading_signal, matrix, size should be same as price_data, no date
%								 6) position_size, matrix, could be date-dependent, 1xN, or MxN, M is the number of observations 
%								 7) bid_ask_included, 1 or 0
%								 8) bid_ask_spread, a cell array same size as price_data, if not existent, set bid_ask_included back to 0.
%								 9) commission_fee, a number or []
%								 10) overall_notional, a number
%								 11) execution_time, a string, if not existent, set execution_time to empty.


% load in field data

connection			= data.connection;
ticker_names 		= data.ticker_names;
price_close 		= data.price_close;
trading_signal 		= data.trading_signal;
position_size 		= data.position_size;
bid_ask_included 	= data.bid_ask_included;
commission_fee 		= data.commission_fee;
overall_notional	= data.overall_notional;

if isfield(data, 'price_open')
	price_open = data.price_open;
else
	price_open = price_close;
end

if bid_ask_included
	if isfield(data, 'bid_ask_spread')
		bid_ask_spread 	= data.bid_ask_spread;
	else
		bid_ask_included = 0;	
	end
end 

if isfield(data, 'execution_time')
	execution_time = data.execution_time;
else
	execution_time = [];
end

% error check
if size(price_close,1) ~= size(trading_signal,1) | size(price_open,1) ~= size(trading_signal,1)
	error('Sizes of Price Data and Trading Signal DO NOT Match.');
elseif bid_ask_included & (size(price_close,1) ~= size(bid_ask_spread) | size(price_open,1) ~= size(bid_ask_spread))
	error('Sizes of Price Data and Spread Data DO NOT Match.');
elseif size(position_size,1) > 1 & size(position_size,1) ~= size(trading_signal,1)
	error('Sizes of Position Size and Trading Signal DO NOT Match.');
end

% some initialization
live_pnl_total 		  = [];
position_total 		  = [];
trading_history_total = cell(0);
result 				  = struct();

for i = 1:length(ticker_names)

	% position size and price data
	current_position_size = position_size(:,i);
	trading_position_size = trading_signal(:,i) .* current_position_size;
	if bid_ask_included
		current_price_data = [price_close(:,[1 1+i]) price_open(:,1+i) bid_ask_spread(:, 1+i)];
	else
		current_price_data = [price_close(:,[1 1+i]) price_open(:,1+i)];
	end
	
	% trade history and individual performance
	[trading_history, ~, live_pnl_history] = GenerateTradeHistoryAndPnLSeries(ticker_names(i), current_price_data, trading_position_size, bid_ask_included, commission_fee, execution_time);
	performance = GeneratePerformanceMetricsFromDailyPnlHistory(connection, live_pnl_history);
	
	% individual result
	result.(['Asset',num2str(i)]).trading_signal	= trading_position_size;
	result.(['Asset',num2str(i)]).trading_history 	= trading_history;
	result.(['Asset',num2str(i)]).live_pnl_history 	= live_pnl_history;
	result.(['Asset',num2str(i)]).performance 		= performance;
	
	% aggregate 
	if size(trading_history,1) > 2
		trading_history_total = [trading_history_total ; trading_history(2:end,:)];
	end
	position_total = [position_total abs(trading_position_size)];
	live_pnl_total = [live_pnl_total cell2mat(live_pnl_history(:,2))];
	disp(['Performance Results for ', cell2mat(ticker_names(i)), ' is finished.']);
end

% aggregate overall results
date 						= price_close(:,1);
position_portfolio 			= [date num2cell(sum(position_total,2))];
live_pnl_portfolio 			= [date num2cell(sum(live_pnl_total,2))];
live_pnl_percent_portfolio 	= [date num2cell(cell2mat(live_pnl_portfolio(:,2)) / overall_notional)];
overall_performance 		= GeneratePerformanceMetricsFromDailyPnlHistory(connection, live_pnl_percent_portfolio);

% combined result
result.combined_result.trading_history_total 		= trading_history_total;
result.combined_result.position_portfolio 			= position_portfolio;
result.combined_result.live_pnl_portfolio 			= live_pnl_portfolio;
result.combined_result.live_pnl_percent_portfolio 	= live_pnl_percent_portfolio;
result.combined_result.overall_performance 			= overall_performance;



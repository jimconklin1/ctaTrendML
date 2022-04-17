function daily_pnl = GenerateDailyPnLfromTrade(ctx, trade)

% This function converts a trade record to a series of daily mark-to-market pnl.
%
% Output: daily_pnl is a cell array of [date | pnl]
%
% Input: 
%		 trade is a struct of 1) ticker, a cell, e.g., 'ES1 Index'
%							  2) signal, a cell 'Long' or 'Short'
%							  3) entry_date, a cell, cannot be empty
%							  4) exit_date, a cell, cannot be empty
%							  5) entry_price, a number, can be empty
%							  6) exit_price, a number, can be empty
%							  7) take_profit, an absolute number of % move if take profit, can be empty
%							  8) stop_loss, an absolute number of % move if stop loss, can be empty
%							  9) position_size, a number, cannot be empty
%							 10) slippage, a number, can be empty
%
% NOTE: When either entry or exit price is empty, check price at those datetime. If no data, then use close price on those days.
% NOTE: When either take-profit or stop-loss is empty, use inf or -inf instead.
% NOTE: in this function, as we use high frequency data, we assume in one price bar, we will not have TP and SL at the same time.

ticker_name = trade.ticker;
signal 		= trade.signal;
start_date 	= trade.entry_date;
end_date 	= trade.exit_date;

if strcmp(signal, 'Long')
	trading_signal = 1;
elseif strcmp(signal, 'Short')
	trading_signal = -1;
else
	trading_signal = 0;
end

% add transaction cost
if isfield(trade, 'slippage') && ~isempty(trade.slippage) && ~isnan(trade.slippage)
	slippage = trade.slippage;
else
	slippage = 0;
end

% define data frequency (minutes)
granular_data_frequency = 10;

% fetch intraday price data
intra_open		= 2;
intra_high 		= 3;
intra_low  		= 4;
intra_close 	= 5;
%intraday_data 	= GetIntradayPriceDatafromBloomberg(ctx.bbgConn, ticker_name, start_date, end_date, granular_data_frequency);
intraday_data	= GetIntradayPriceDatafromTSRP(ticker_name, start_date, end_date);

% if no data within the time period, just return empty cell.
if cellfun('isempty', intraday_data)
	daily_pnl = {[]};
	return
end

intraday_time 	= intraday_data(:,1);
intraday_opens 	= cell2mat(intraday_data(:,intra_open));
intraday_highs 	= cell2mat(intraday_data(:,intra_high));
intraday_lows 	= cell2mat(intraday_data(:,intra_low));
intraday_closes = cell2mat(intraday_data(:,intra_close));

% figure out entry price
if isfield(trade, 'entry_price') && ~isempty(trade.entry_price) && ~isnan(trade.entry_price)
	entry_price 	= trade.entry_price;
	entry_price_tc 	= trade.entry_price + slippage * trading_signal / 2;
else
	%minute_data = GetPriceDataAtParticularTime(ctx.bbgConn, ticker_name, start_date, datestr(cell2mat(start_date),'HH:MM'));
	minute_data = GetPriceDataAtParticularTimefromTSRP(ticker_name, start_date, datestr(cell2mat(start_date),'HH:MM'));
	if ~cellfun('isempty', minute_data)
		entry_price 	= cell2mat(minute_data(end,2));
		entry_price_tc 	= cell2mat(minute_data(end,2)) + slippage * trading_signal / 2;
	else
		entry_price 	= cell2mat(intraday_data(1, intra_open));
		entry_price_tc 	= cell2mat(intraday_data(1, intra_open)) + slippage * trading_signal / 2;
	end
end

% figure out exit price
if isfield(trade, 'exit_price') && ~isempty(trade.exit_price) && ~isnan(trade.exit_price)
	exit_price 		= trade.exit_price;
	exit_price_tc 	= trade.exit_price - slippage * trading_signal / 2;
else
	%minute_data = GetPriceDataAtParticularTime(ctx.bbgConn, ticker_name, end_date, datestr(cell2mat(end_date),'HH:MM'));
	minute_data = GetPriceDataAtParticularTimefromTSRP(ticker_name, end_date, datestr(cell2mat(end_date),'HH:MM'));
	if ~cellfun('isempty', minute_data)
		exit_price 		= cell2mat(minute_data(end,2));
		exit_price_tc 	= cell2mat(minute_data(end,2)) - slippage * trading_signal / 2;
	else
		exit_price 		= cell2mat(intraday_data(end, intra_open));
		exit_price_tc 	= cell2mat(intraday_data(end, intra_open)) - slippage * trading_signal / 2;
	end
end

% figure out take profit level
if isfield(trade, 'take_profit') && ~isempty(trade.take_profit) && ~isnan(trade.take_profit)
	take_profit 	= entry_price * (1 + abs(trade.take_profit) * trading_signal);
	take_profit_tc 	= take_profit - slippage * trading_signal / 2;
else
	take_profit = inf * trading_signal;	
end

% figure out stop loss level
if isfield(trade, 'stop_loss') && ~isempty(trade.stop_loss) && ~isnan(trade.stop_loss)
	stop_loss 		= entry_price * (1 - abs(trade.stop_loss) * trading_signal);
	stop_loss_tc 	= stop_loss - slippage * trading_signal / 2;
else
	stop_loss = -inf * trading_signal;	
end

position_size = trade.position_size;
no_of_shares = position_size / entry_price;

% calculate intraday pnl
intraday_pnl = cell(0);
for i = 1:size(intraday_data,1)
	if i == 1
		pnl = (intraday_opens(i) - entry_price_tc) * no_of_shares * trading_signal;
		intraday_pnl = [intraday_pnl ; intraday_time(i) num2cell(pnl)];
	elseif i == size(intraday_data,1)
		pnl = (exit_price_tc - intraday_opens(i-1)) * no_of_shares * trading_signal;
		intraday_pnl = [intraday_pnl ; intraday_data(i) num2cell(pnl)];
	else
		if hasHitTakeProfit(trading_signal, intraday_highs(i), intraday_lows(i), take_profit)
			pnl = (take_profit_tc - intraday_opens(i-1)) * no_of_shares * trading_signal;
			intraday_pnl = [intraday_pnl ; intraday_data(i) num2cell(pnl)];
			break;
		elseif hasHitStopLoss(trading_signal, intraday_highs(i), intraday_lows(i), stop_loss)
			pnl = (stop_loss_tc - intraday_opens(i-1)) * no_of_shares * trading_signal;
			intraday_pnl = [intraday_pnl ; intraday_data(i) num2cell(pnl)];
			break;
		else
			pnl = (intraday_opens(i) - intraday_opens(i-1)) * no_of_shares * trading_signal;
			intraday_pnl = [intraday_pnl ; intraday_data(i) num2cell(pnl)];
		end
	end
end
%daily_pnl = CombinePnLHistory(intraday_pnl, 'day');
daily_pnl = CombineIntradayPnLHistory(intraday_pnl, 'Asia/Singapore', 'America/New_York', 17);




function tf = hasHitTakeProfit(signal, high, low, take_profit)
% This function tests whether price hits take profit level intrabar.
%
% Output: tf, is a logical variable, 0 or 1
%
% Inputs: signal, a number 1 or -1
%		  high, a number of intrabar high
%		  low, a number of intrabar low
%		  take_profit, a number of take profit level

switch signal
case 1
	tf = high >= take_profit;
case -1
	tf = low <= take_profit;
otherwise
	tf = false;
end


function tf = hasHitStopLoss(signal, high, low, stop_loss)
% This function tests whether price hits stop loss level intrabar.
%
% Output: tf, is a logical variable, 0 or 1
%
% Inputs: signal, a number 1 or -1
%		  high, a number of intrabar high
%		  low, a number of intrabar low
%		  stop_loss, a number of stop_loss level

switch signal
case 1
	tf = low <= stop_loss;
case -1
	tf = high >= stop_loss;
otherwise
	tf = false;
end


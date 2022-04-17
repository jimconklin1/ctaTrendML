function result = GenerateShortSPOverlayResult(model_pnl, model_pnl_percent, model_position, model_notional)

% This function generates the result of overlaying short SP position onto the original model result.
%
% The output: result is a struct of 1) sp_live_pnl, a cell array [date | data]
%						            2) sp_position, a cell array [date | data]
%								    3) combined_live_pnl, a cell array [date | data]
%									4) combined_live_pnl_percent, a cell array [date | data]
%
% The input: connection is from config file, model_pnl, model_pnl_percent, model_position are cell arrays [date | data], model_notional is a number.

% define parameters

market_ticker 			 = {'ES1 Index'};

lookback_period 		 = 1;

lookback_period_unit 	 = 'month';

rebalance_frequency 	 = 7;

rebalance_frequency_unit = 'day';


% get data

start_date 	= model_pnl(1,1);

end_date 	= model_pnl(end,1);

field 		= {'LAST_PRICE'};

data  		= GetGeneralDailyDataFromBloomberg(connection, market_ticker, start_date, end_date, field);

price 		= data(:,[2,3]);


% start the backtest

pnl_date = model_pnl(:,1);

current_start_date = start_date;

trading_signal = [];


while datenum(current_start_date) <= datenum(end_date)

	disp('**************************************************************************');
	
	disp(['Current Start Date is: ', datestr(current_start_date, 'mm-dd-yyyy')]);
	
	lookback_start_date = cellstr(datestr(addtodate(datenum(current_start_date), - lookback_period, lookback_period_unit)));
	
	lookback_data 		= model_pnl_percent(datenum(pnl_date) >= datenum(lookback_start_date) & datenum(pnl_date) < datenum(current_start_date), :);
	
	current_end_date 	= cellstr(datestr(addtodate(datenum(current_start_date), rebalance_frequency, rebalance_frequency_unit)));
	
	lookforward_data 	= model_pnl_percent(datenum(pnl_date) >= datenum(current_start_date) & datenum(pnl_date) < datenum(current_end_date), :);
	
	if size(lookforward_data,1) < 1
	
		disp('This Lookforward Period does NOT have any Model pnl. Will skip this period and proceed to the next one ... ');
		
		disp(['Current End Date is: ', datestr(current_end_date, 'mm-dd-yyyy')]);
		
		disp('******************************************************************************');
		
		disp('         																	    ');
		
		current_start_date = current_end_date;
		
		continue;
		
	end
	
	
	if size(lookback_data, 1) < 2
	
		current_beta = 0;
		
	else
	
		[~, current_beta] = GenerateMarketModelCorrelation(lookback_data);
		
		if ~isfinite(current_beta)
		
			current_beta = 0;
			
		end
	
	end
	
	disp(['Beta during this period is: ', num2str(current_beta)]);
	
	
	lookforward_model_positions = cell2mat(model_position(datenum(pnl_date) >= datenum(current_start_date) & datenum(pnl_date) < datenum(current_end_date), 2));
	
	current_model_position 		= lookforward_model_positions(1);
	
	disp(['Current Model Position Size is: $ ', num2str(current_model_position)]);
	
	current_short_SP_position 	= current_model_position * current_beta * (-1);
	
	disp(['Current Short S&P Position Size is: $ ', num2str(current_short_SP_position)]);
	
	
	current_trading_signal 	= ones(size(lookforward_data,1),1) * current_short_SP_position;
	
	trading_signal 			= [trading_signal ; current_trading_signal];
	
	current_start_date 		= current_end_date;

end


% combine model and short SP pnl

[~, ~, idx_SP] 				= intersect(datenum(pnl_date), datenum(price(:,1)));

price 						= price(idx_SP, :);

[~, ~, sp_live_pnl] 		= GenerateLongShortTradeHistory(market_ticker, price, trading_signal, 0, []);

sp_position 				= [pnl_date num2cell(trading_signal)];

combined_live_pnl 			= [pnl_date num2cell(cell2mat(sp_live_pnl(:,2)) + cell2mat(model_pnl(:,2)))];

combined_live_pnl_percent 	= [pnl_date num2cell(cell2mat(combined_live_pnl(:,2)) ./ model_notional)];


% save the result

result.sp_live_pnl 				 = sp_live_pnl;

result.sp_position 				 = sp_position;

result.combined_live_pnl 		 = combined_live_pnl;

result.combined_live_pnl_percent = combined_live_pnl_percent;





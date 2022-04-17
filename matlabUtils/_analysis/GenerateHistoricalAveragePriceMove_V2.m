function [abs_ave_return, average_return, stdev_return] = GenerateHistoricalAveragePriceMove_V2(security_data, time_scale)

% This function returns the average and standard deviation of historical price returns.
%
% Outputs: abs_ave_return, average_return and stdev_return are all numbers.
%
% Inputs: security_data, a cell array of price data in the format of [date | data]
% 		  time_scale, a number, in terms of trading days, indicating return period.

if isempty(security_data) || size(security_data, 1) < time_scale + 1
	abs_ave_return = NaN; average_return = NaN; stdev_return   = NaN;
	return;
end

security_data 	= [security_data(:,1) FillNaNData(security_data(:,2))];
price_move 		= CalculateReturn(cell2mat(security_data(1:end-time_scale,2)), cell2mat(security_data(1+time_scale:end,2)));
abs_ave_return	= mean(abs(price_move));
average_return 	= mean(price_move);
stdev_return 	= std(price_move);

 
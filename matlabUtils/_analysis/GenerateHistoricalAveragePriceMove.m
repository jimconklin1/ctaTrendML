function [abs_ave_return, average_return, stdev_return] = GenerateHistoricalAveragePriceMove(connection, security_name, start_date, end_date, time_scale)

% NOTE: This function returns the average and standard deviation of historical price returns.
%
% NOTE: The output abs_ave_return, average_return and stdev_return are all numbers.
%
% NOTE: The inputs connection is from config file, security_name, start_date, end_date are cells. time_scale is a number, in terms of trading days, indicating return period.

field 			= {'LAST_PRICE'};

security_data 	= GetGeneralDailyDataFromBloomberg(connection, security_name, start_date, end_date, field);

if cellfun('isempty', security_data) | size(security_data, 1) < time_scale + 1

	disp(['Not Enough Data for ', cell2mat(security_name), ' from ', datestr(start_date), ' to ', datestr(end_date)]);
	
	abs_ave_return = NaN;
	
	average_return = NaN;
	
	stdev_return   = NaN;
	
	return;
	
end

security_data 	= [security_data(:,2) FillNaNData(security_data(:,3))];
	
price_move 		= CalculateReturn(cell2mat(security_data(1:end-time_scale,2)), cell2mat(security_data(1+time_scale:end,2)));


abs_ave_return	= mean(abs(price_move));

average_return 	= mean(price_move);

stdev_return 	= std(price_move);


	

	



 
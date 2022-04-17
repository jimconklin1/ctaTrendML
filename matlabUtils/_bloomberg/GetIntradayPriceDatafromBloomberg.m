function data = GetIntradayPriceDatafromBloomberg(connection, security, start_time, end_time, frequency)

% This function fetches price data at a particular time from Bloomberg.
%
% Output: data is a cell array of [date time | price data]
%
% Inputs: connection, bloomberg connection
%		  security, a cell of ticker
%		  start_time, a cell of start datetime
%		  end_time, a cell of end datetime
%		  frequency, a number indicating data frequency, should be in terms of minutes

start_time_num 	= datenum(cell2mat(start_time));
end_time_num 	= datenum(cell2mat(end_time));

if start_time_num < now	% if try to fetch data in the future, bloomberg will return error
	try
		minute_data = timeseries(connection, cell2mat(security), {start_time_num, end_time_num}, frequency, 'Trade');
	catch
		disp([cell2mat(security), ' is not a valid ticker.']);
		minute_data = [];	
	end
	if ~isempty(minute_data)
		data = [cellstr(datestr(minute_data(:,1))) num2cell(minute_data(:,2:end))];	
	else
		data = {[]};	
	end
else
	data = {[]};
end
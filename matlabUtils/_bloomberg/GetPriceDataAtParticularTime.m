function data = GetPriceDataAtParticularTime(connection, security, data_date, timestring)

% This function fetches price data at a particular time from Bloomberg.
%
% Output: data is a cell array of [date time | price data]
%
% Inputs: connection, bloomberg connection
%		  security, a cell of ticker
%		  data_date, a cell of date
%		  timestring, a string of particular time in the day (currently Singapore time)

time_vec = datevec(timestring);
time_num = datenum(floor(datenum(cell2mat(data_date))) + datenum([0 0 0 time_vec(4) time_vec(5) time_vec(6)]));

if time_num < now	% if try to fetch data in the future, bloomberg will return error
	try
		minute_data = timeseries(connection, cell2mat(security), {time_num-1/24,time_num+1/3600},1,'Trade');	% we take price from 1 hour before		
	catch
		disp([cell2mat(security), ' is not a valid ticker.']);
		minute_data = [];	
	end
	if ~isempty(minute_data)
		data = [cellstr(datestr(minute_data(end,1))) num2cell(minute_data(end,2))];	
	else
		data = {[]};	
	end
else
	data = {[]};
end
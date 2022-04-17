function data = GetPriceDataAtParticularTimefromTSRP(security, data_date, timestring)

% This function fetches price data at a particular time from Bloomberg.
%
% Output: data is a cell array of [date time | price data]
%
% Inputs: security, a cell of ticker
%		  data_date, a cell of date
%		  timestring, a string of particular time in the day (currently Singapore time)

time_vec = datevec(timestring);
time_num = datenum(floor(datenum(cell2mat(data_date))) + datenum([0 0 0 time_vec(4) time_vec(5) time_vec(6)]));

if time_num < now	% cannot fetch data in the future
	try
		minute_data = GetIntradayPriceDatafromTSRP(security, time_num-1/24, time_num+1/3600);	% we take price from 1 hour before		
	catch
		disp([cell2mat(security), ' is not a valid ticker.']);
		minute_data = {[]};	
	end
	if ~cellfun('isempty', minute_data)
		data = minute_data(end,[1,2]);	% use open price during the bar
	else
		data = {[]};	
	end
else
	data = {[]};
end
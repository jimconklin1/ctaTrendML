function data = GetIntradayPriceDatafromTSRP(security, start_time, end_time)

% This function fetches price data from TSRP.
%
% Output: data is a cell array of [date time | open | high | low | close | volume of ticks | number of ticks | total tick value]
%
% Inputs: security, a cell of ticker (must be in the SIM list)
%		  start_time, a cell of datetime format, or just a date string, or datenum
%		  end_time, a cell of datetime format, or just a date string, or datenum

price_ticker = strcat('u.i.intraday_price_', lower(strrep(security, ' ', '_')));
raw_data 	 = tsrp.fetch_user_intraday(price_ticker, datestr(start_time, 'yyyy-mm-dd'), datestr(end_time, 'yyyy-mm-dd'), '%f %f %f %f %f %f %f');

if isempty(raw_data)
	data = {[]};
else
	raw_data = raw_data(raw_data.ts >= datenum(start_time) & raw_data.ts <= datenum(end_time), :);
	if isempty(raw_data)
		data = {[]};
	else
		data = [cellstr(datestr(raw_data.ts)) table2cell(raw_data(:,2:end))];
	end
end


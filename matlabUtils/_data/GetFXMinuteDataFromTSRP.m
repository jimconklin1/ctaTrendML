function data = GetFXMinuteDataFromTSRP(fx_tickers, start_time, end_time, timezone)

% NOTE: This function gets FX minute data from the TSRP server
% NOTE: TSRP does have raw minute data for futures contract. But currently there is no generic way to fetch those data.
%
% Output: data is a cell array of minute bars [timestamp | open | high | low | close | volume | ...]
%		  if there are more than one ticker, data will be appended but there is only one column of timestamp.
%
% Inputs: fx_tickers: a cell or cell array of FX tickers, if it's a cell array, it has to be a row array
%		  start_time: a cell, indicating data start time
%		  end_time: a cell, indicating data end time
%		  timezone: a cell, indicating which time zone the data is for

tickers = cell(0);

for i = 1:length(fx_tickers)

	if cellfun('isempty', strfind(fx_tickers(i), 'Curncy'))
	
		disp(['Ticker Name ', cell2mat(fx_tickers(i)), ' is not Valid.']);
		
	else
	
		tickers = [tickers, strcat('fx.', lower(strrep(fx_tickers(i), ' Curncy', '')))];
		
	end
	
end

if isempty(tickers)

	disp('No Ticker Name is Valid.');
	
	data = {[]};
	
	return;
	
end


start_time_target_tz = datetime(datestr(start_time, 'yyyy-mm-dd HH:MM:SS'), 'TimeZone', cell2mat(timezone));

start_time_utc = datetime(start_time_target_tz, 'TimeZone', 'UTC');	% since TSRP data is all based on UTC time zone


if length(datestr(end_time)) == 11 % means exact time is not specified, in which case we change end time to the end of the day (23:59:00)

	date_vec = datevec(end_time);
	
	date_vec(4) = 23; date_vec(5) = 59;

	end_time = datestr(date_vec);

end 

end_time_target_tz = datetime(datestr(end_time, 'yyyy-mm-dd HH:MM:SS'), 'TimeZone', cell2mat(timezone));

end_time_utc = datetime(end_time_target_tz, 'TimeZone', 'UTC');	% since TSRP data is all based on UTC time zone


raw_data = tsrp.fetch_intraday_ohlc(tickers, datestr(start_time_utc, 'yyyy-mm-dd'), datestr(end_time_utc, 'yyyy-mm-dd'));

if isempty(raw_data)

	data = {[]};
	
	return;
	
end

raw_data = raw_data(raw_data(:,1) >= datenum(start_time_utc) & raw_data(:,1) <= datenum(end_time_utc), :);	% get data within exact time interval

data_date_utc = datetime(datevec(raw_data(:,1)), 'TimeZone', 'UTC');

data_date_target_tz = cellstr(datetime(data_date_utc, 'TimeZone', cell2mat(timezone)));

data = [data_date_target_tz, num2cell(raw_data(:,2:end))];





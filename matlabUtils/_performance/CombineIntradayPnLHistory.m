function pnl_history_combined = CombineIntradayPnLHistory(pnl_history, fromTZ, toTZ, time)

% This function aggregates intraday pnl history into daily pnl based on Timezone and specific time.
%
% NOTE: The output is a cell array that has the format [date | data].
%
% NOTE: The input pnl_history is a cell array with the format [date | data]. fromTZ and toTZ are strings of time zones, and time is a number of which time during the day.

pnl_history_combined = cell(0);

pnl_date = pnl_history(:,1);
pnl_data = cell2mat(pnl_history(:,2));

ts_original = datetime(pnl_date, 'TimeZone', fromTZ);
ts_final = datetime(ts_original, 'TimeZone', toTZ);

bus_days = busdays(floor(datenum(ts_final(1))),floor(datenum(ts_final(end))),1);

if isempty(bus_days)	% if there is no business day in between, just use the next business day
	bus_days = busdate(floor(datenum(ts_final(end))),1);
end
eod_days = bus_days + time / 24;
date_num = datenum(ts_final);

for i = 1:length(eod_days)
	if i == 1
		if ~isempty(pnl_data(date_num <= eod_days(i)))
			pnl_history_combined = [pnl_history_combined ; cellstr(datestr(eod_days(i),'dd-mmm-yyyy')) num2cell(sum(pnl_data(date_num <= eod_days(i))))];
		end
	else
		if ~isempty(pnl_data(date_num <= eod_days(i) & date_num > eod_days(i-1)))
			pnl_history_combined = [pnl_history_combined ; cellstr(datestr(eod_days(i),'dd-mmm-yyyy')) num2cell(sum(pnl_data(date_num <= eod_days(i) & date_num > eod_days(i-1))))];
		end
	end
end

if ~isempty(pnl_data(date_num > eod_days(end)))
	pnl_history_combined = [pnl_history_combined ; cellstr(datestr(busdate(eod_days(end),1),'dd-mmm-yyyy')) num2cell(sum(pnl_data(date_num > eod_days(end))))];
end


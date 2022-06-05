function bbgData = getBbgFundData(config)

oosDates = generateOOSDates(config); % Generate a series of OOS Dates for calendar quarter ends

c = blp;
from = datestr(datenum(config.dataStartDate), 'mm/dd/yyyy');
to = datestr(datenum(config.dataEndDate), 'mm/dd/yyyy');
bbgData = history(c, {'SPX Index'}, {'DVD_SH_12M', 'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', 'EBITDA', 'RETURN_COM_EQY', 'REVENUE_PER_SH'},...
    from, to, {'daily', 'calendar'}, 'USD', 'overridefields', {'FUND_PER', 'Q'});

data = zeros(size(oosDates, 1), size(bbgData, 2) + 1);
for i = 1 : size(oosDates, 1)
    data(i, 1) = oosDates.DataDate(i);
    data(i, 2) = oosDates.OOSDate(i);
    data(i, 3 : end) = bbgData(find(bbgData(:, 1) <= oosDates.OOSDate(i), 1, 'last'), 2 : end);
end

bbgData = array2table(data, 'VariableNames', {'DataDate', 'OOSDate', 'DVD_SH_12M', 'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', 'EBITDA', 'RETURN_COM_EQY', 'REVENUE_PER_SH'});

end
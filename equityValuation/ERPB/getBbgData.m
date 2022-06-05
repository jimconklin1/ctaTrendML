function bbgData = getBbgData(startDate, endDate, frequency)

c = blp;
from = datestr(datenum(startDate), 'mm/dd/yyyy');
to = datestr(datenum(endDate), 'mm/dd/yyyy');
data = history(c, 'SPX Index', {'PX_LAST'}, from, to, {frequency, 'calendar'});

bbgData = array2table(data, 'VariableNames', {'CalcDate', 'PX_LAST'});

end
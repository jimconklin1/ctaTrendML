function f = PlotTimeSeries(series, series_name)

% NOTE: This function plots a time series

% The input series has to be in the CELL format with [date | data], series_name is a string.

series_ts = timeseries(cell2mat(series(:,2)), series(:,1));

series_ts.TimeInfo.Format = 'mm/dd/yyyy';

series_ts.Name = series_name;

plot(series_ts, 'k', 'LineWidth', 3);

xlabel('Time','FontSize',16);

ylabel(series_name,'FontSize',16);

title(series_ts.Name,'FontSize',16);

grid on;


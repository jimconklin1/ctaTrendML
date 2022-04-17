function f = PlotCumulativeSeries(series, series_name)

% NOTE: This function plots a cumulative curve of series

% The input series has to be in the CELL format with [date | data], series_name is a string.

cumulative_ts = timeseries(cumsum(cell2mat(series(:,2))), series(:,1));

cumulative_ts.TimeInfo.Format = 'mm/dd/yyyy';

cumulative_ts.Name = ['Cumulative ', series_name];

plot(cumulative_ts, 'k', 'LineWidth', 3);

xlabel('Time','FontSize',16);

ylabel(series_name,'FontSize',16);

title(cumulative_ts.Name,'FontSize',16);

grid on;


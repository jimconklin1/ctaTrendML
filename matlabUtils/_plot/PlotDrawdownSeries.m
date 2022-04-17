function f = PlotDrawdownSeries(series, series_name)

% NOTE: This function plots a drawdown curve of a return series
%
% The input series has to be in the CELL format with [date | data], series_name is a string.
%
% The input series is the return series itself, NOT the cumulative series. 

cum_ret = cumsum(cell2mat(series(:,2)));

highwatermark = zeros(size(cum_ret));

drawdown = zeros(size(cum_ret));

for i = 2:length(cum_ret)

	highwatermark(i) = max(highwatermark(i-1), cum_ret(i));
	
	drawdown(i) = cum_ret(i) - highwatermark(i);

end

drawdown_ts = timeseries(drawdown, series(:,1));

drawdown_ts.TimeInfo.Format = 'mm/dd/yyyy';

drawdown_ts.Name = ['Drawdown ', series_name];

plot(drawdown_ts, 'k', 'LineWidth', 3);

xlabel('Time','FontSize',16);

ylabel(series_name,'FontSize',16);

title(drawdown_ts.Name,'FontSize',16);

grid on;


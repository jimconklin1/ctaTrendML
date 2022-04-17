function data = GetDailyDataFromBloomberg(connection, security, start_date, end_date)

% NOTE: this function returns a cell matrix containing the following information:
% Nx8 cells with [ security name | date | last price | open price | high price | low price | total value traded | average daily bid ask spread]
%
% NOTE: All the three inputs need to be in the CELL format
%
% the field can always be extended to include more information

field = {'LAST_PRICE','OPEN','HIGH','LOW','TURNOVER','AVERAGE_BID_ASK_SPREAD'};	

data = GetGeneralDailyDataFromBloomberg(connection, security, start_date, end_date, field);

% The following code is old code, not in use anymore.

%connection = blp;
%
%raw_data = history(connection, char(security), field, datestr(cell2mat(start_date)), datestr(cell2mat(end_date)));
%
%if size(raw_data,1) > 0
%
%	data(:,2) = cellstr(datestr(raw_data(:,1)));
%
%	data(:,3:3 + length(field) - 1) = num2cell(raw_data(:,2:end));
%
%	data(:,1) = security;
%	
%else
%
%	data = {[]};
%	
%end
%
%close(connection);



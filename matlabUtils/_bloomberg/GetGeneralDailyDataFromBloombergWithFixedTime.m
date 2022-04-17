function data = GetGeneralDailyDataFromBloombergWithFixedTime(connection, security_list, start_date, end_date, field, timestring)

% This function fetches data from Bloomberg and returs a cell array.
% 
% Output: data: a struct of cell arrays with [date | field data]
%
% Input: connection, bloomberg conn
%		 security_list, a cell array of security tickers
%	     start_date, a cell of start date
%		 end_date, a cell of end date
%		 field, a cell of data fields to fetch
%		 timestring (optional input), a string indicating what time for the last day data

if nargin < 6 || isempty(timestring)
	isTimeSpecified = 0; timestring = [];	
else
	isTimeSpecified = 1;	
end

% in case some tickers are empty
ticker_list = cell(0);
for i = 1:length(security_list)
	if ~cellfun('isempty',security_list(i))
		ticker_list = [ticker_list ; security_list(i)];
	end
end

% check if there is ticker list
if isempty(ticker_list)
	disp('No Ticker Entered.');
	data = {[]};
	return
end

% fetch data
raw_data = history(connection, ticker_list, field, datestr(cell2mat(start_date)), datestr(cell2mat(end_date)));

% process raw data
k = 1;
for i = 1:length(security_list)
	if ~cellfun('isempty', security_list(i))
		if length(ticker_list) == 1
			data_i = raw_data;
		else
			data_i = raw_data{k,1}; k = k + 1;
		end
		data.(['data',num2str(i)]) = ProcessRawData(connection, security_list(i), data_i, field, isTimeSpecified, end_date, timestring);	
	end
end

end


function data = ProcessRawData(connection, security, raw_data, field, isTimeSpecified, data_date, timestring)
	if ischar(raw_data) && ~isempty(strfind(raw_data,'Invalid'))
		disp(['Ticker Name ', cell2mat(security),' is not Valid.']);	
		data = {[]};	
	elseif size(raw_data,1) > 0
		if any(strcmp(field, 'LAST_PRICE')) && isTimeSpecified
			minute_data = GetPriceDataAtParticularTime(connection, security, data_date, timestring);	
			if ~cellfun('isempty', minute_data)	
				raw_temp = raw_data(:,2:end);		
				if iscell(raw_data)		
					raw_temp(end, strcmp(field, 'LAST_PRICE')) = minute_data(2);			
				elseif isnumeric(raw_data)
					raw_temp(end, strcmp(field, 'LAST_PRICE')) = cell2mat(minute_data(2));
				end
				raw_data = [raw_data(:,1) raw_temp];
			else
				if iscell(raw_data) && floor(cell2mat(raw_data(end,1))) == floor(datenum(cell2mat(data_date)))
					raw_data = raw_data(1:end-1,:);	
				elseif isnumeric(raw_data) && floor(raw_data(end,1)) == floor(datenum(cell2mat(data_date)))
					raw_data = raw_data(1:end-1,:);
				end
			end
		end
		if iscell(raw_data)
			data(:,1) = cellstr(datestr(cell2mat(raw_data(:,1))));
			data(:,2:2 + length(field) - 1) = raw_data(:,2:end);
		elseif isnumeric(raw_data)
			data(:,1) = cellstr(datestr(raw_data(:,1)));
			data(:,2:2 + length(field) - 1) = num2cell(raw_data(:,2:end));
		end
	else
		data = {[]};
	end
end




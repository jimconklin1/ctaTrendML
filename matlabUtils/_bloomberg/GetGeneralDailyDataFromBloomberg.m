function data = GetGeneralDailyDataFromBloomberg(connection, security, start_date, end_date, field)

% NOTE: this function returns a cell matrix containing the following information:
% Nx8 cells with [ security name | date | field data]
%
% Inputs: connection: from config file
%		  security: a cell with bloomberg ticker
%		  start_date: a cell 
%		  end_date: a cell
%		  field: a cell array of strings.


%connection = blp;	% Direct Bloomberg API

raw_data = history(connection, char(security), field, datestr(cell2mat(start_date)), datestr(cell2mat(end_date)));

if ischar(raw_data) & strfind(raw_data,'Invalid')

	disp(['Ticker Name ', cell2mat(security),' is not Valid.']);

	data = {[]};
	
elseif iscell(raw_data) & size(raw_data,1) > 0

	data(:,2) = cellstr(datestr(cell2mat(raw_data(:,1))));
	
	data(:,3:3 + length(field) - 1) = raw_data(:,2:end);
	
	data(:,1) = security;
	
elseif isnumeric(raw_data) & size(raw_data,1) > 0

	data(:,2) = cellstr(datestr(raw_data(:,1)));
	
	data(:,3:3 + length(field) - 1) = num2cell(raw_data(:,2:end));
	
	data(:,1) = security;

else

	data = {[]};
	
end



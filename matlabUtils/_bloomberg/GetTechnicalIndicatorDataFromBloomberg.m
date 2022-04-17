function data = GetTechnicalIndicatorDataFromBloomberg(ctx, security, start_date, end_date, indicator, attributes)

% NOTE: This function returns a cell array with the technical indicator information.
%
% Format: [date | data | data | ... ]
%
% NOTE: The inputs connection is from config file, security, start_date, end_date, indicator are cells.
%
% NOTE: attributes is a struct, which must have both input and output, which are both cell arrays.


input 	= attributes.input;
output 	= attributes.output;

if isempty(input)
	disp(['There is no input attribute for indicator ', cell2mat(indicator), '. No Data Will be Downloaded ...']);
	data = {[]};
	return
elseif isempty(output)
	disp(['There is no output attribute for indicator ', cell2mat(indicator), '. Cannot assembly data ...']);
	data = {[]};
	return
else
	field_string = '';
	for i = 1:size(input,1)
		if ischar(cell2mat(input(i,2)))
			if i == size(input,1)	
				field_string = [field_string, '''', cell2mat(input(i,1)), ''',''', cell2mat(input(i,2)), ''''];	
			else
				field_string = [field_string, '''', cell2mat(input(i,1)), ''',''', cell2mat(input(i,2)), ''','];	
			end
		else
			if i == size(input,1)
				field_string = [field_string, '''', cell2mat(input(i,1)), ''',', cell2mat(input(i,3)), '(', num2str(cell2mat(input(i,2))), ')'];
			else
				field_string = [field_string, '''', cell2mat(input(i,1)), ''',', cell2mat(input(i,3)), '(', num2str(cell2mat(input(i,2))), '),'];
			end
		end
	end
end

connection = blp(8194, ctx.conf.blpIP, 0);
basic_info = ['connection,''', char(security),''',''',datestr(cell2mat(start_date)),''',''',datestr(cell2mat(end_date)),''',''',cell2mat(indicator),''',{''daily'',''calendar''},'];
input_string = [basic_info, field_string];
eval(['original_data = tahistory(', input_string, ');']);

if ~isempty(original_data) && isstruct(original_data)
	indicator_date = cellstr(datestr(original_data.date));
	indicator_data = cell(0);
	for j = 1:length(output)
		if any(strcmp(output(j),fieldnames(original_data)))
			if size(original_data.(cell2mat(output(j))),2) > 1	% some indicators have more than one column and data is weird!
				temp = original_data.(cell2mat(output(j)));	
				temp(temp(:,1) == 0,1) = NaN;
				original_data.(cell2mat(output(j))) = temp(:,1);
			end
			if length(original_data.(cell2mat(output(j)))) ~= length(original_data.date)
				original_data.(cell2mat(output(j))) = [original_data.(cell2mat(output(j))) ; nan(length(original_data.date) - length(original_data.(cell2mat(output(j)))),1)];
			end
			indicator_data = [indicator_data, num2cell(original_data.(cell2mat(output(j))))];
		else
			indicator_data = [indicator_data, num2cell(nan(size(original_data.date)))];
		end
	end
	data = [indicator_date, indicator_data];
	data = data(datenum(indicator_date) >= datenum(datestr(cell2mat(start_date))) & datenum(indicator_date) <= datenum(datestr(cell2mat(end_date))),:);	% for some indicator, there is data beyond end_date, weird!
else
	data = {[]};
end
close(connection);	

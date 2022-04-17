% Retrieve and parse a CSV from a web service
% Author: Brian Lee Yung Rowe
% Date: 2015-03-21
%
% This function downloads a URL and parses the content as a CSV. It assumes
% that the first row is a header. Use the hformat and bformat arguments to
% tell the function how to parse the header and body, respectively.
%
% TODO
% Look into using http://www.mathworks.com/matlabcentral/fileexchange/35693-urlread2
% Examples
% hformat = '%s %s';
% bformat = '%{yyyy-MM-dd HH:mm:ss}D %f';
% data = csv_request(url,hformat,bformat);
function data = cdx_csv_request(url, hformat, bformat, hasheader, webuser, webpassword)
import tsrp.*;
text = strrep(webread(url,weboptions('Username', webuser, 'Password', webpassword, 'Timeout',300)), char(13), '');

if isempty(text)
    data = table;
    return;
end

if length(text) > 5 && strcmp(text(1:6), 'Error:')
    error(text(7:length(text)));
else
    if text(end) == ','
        text = text(1:end-21);
    end
    datastart = 1;
    idx = strfind(text, char(10)); % new line
    if hasheader
        if isempty(hformat)
            header = strsplit(text(1:idx(1)-1), ',');
            bformat = [bformat, repmat('%s',1,2), strtrim(repmat('%f ', 1, length(header) - 3))];
        else
            header = textscan(text(1:idx(1)-1), hformat, 'Delimiter',',');
            if length(header) == 1
                header = header{1};
            end
            header = cellfun(@cellstr,header);
        end
        datastart = idx(1)+1;        
    end
    if length(idx) > 1
        raw = textscan(text(datastart:end), bformat, 'Delimiter',',');
        data = table(raw{:});
    else
        data = cell2table(cell(0,length(header)));
    end
    if hasheader
        data.Properties.VariableNames = header;
    end
end
end
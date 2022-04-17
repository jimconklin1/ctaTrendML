function glStatus(pname, status, level)
%level: ERROR = 3
%level: INFO  = 6
%
%Details Level Specs (for reference)
%0       Emergency: system is unusable
%1       Alert: action must be taken immediately
%2       Critical: critical conditions
%3       Error: error conditions
%4       Warning: warning conditions
%5       Notice: normal but significant condition
%6       Informational: informational messages
%7       Debug: debug-level messages

level = num2str(level);

%escape backslashes and double quotes
pname = strrep(strrep(pname, '\', '\\'), '"', '\"');
status = strrep(strrep(status, '\', '\\'), '"', '\"');

%form the full GELF format JSON string
msg = strcat('{"version":"1.1","host":"', getenv('computername'), '","facility":"gama.status","short_message":"', status, '","process_name":"', pname, '","level":',level,'}');

%send to Graylog (Graylog return HTTP 202 (Accepted) which Matlab
%interprets as an error, thus the try catch (which also ignores any errors)
try
    webwrite('http://52.74.75.54:12205/gelf',msg)
catch
end

end


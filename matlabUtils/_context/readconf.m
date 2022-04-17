function R = readconf(configfile)
% READCONF reads configuration file. 
%
% The value of boolean parameters can be tested with 
%    exist(parameter,'var')
%
% Copied and shortened from http://rosettacode.org/wiki/Read_a_configuration_file
 
if nargin<1, 
   configfile = 'qa.conf';
end;
 
fid = fopen(configfile); 
if fid<0, error('cannot open file %s\n',a); end; 
 
while ~feof(fid)
    line = strtrim(fgetl(fid));
    if isempty(line) || all(isspace(line)) || strncmp(line,'#',1) || strncmp(line,';',1)
        continue
    else
        parts = strsplit(line,'=');
        var = strtrim(parts{1});
        R.(var) = strtrim(parts{2});
    end;
end; 
fclose(fid);
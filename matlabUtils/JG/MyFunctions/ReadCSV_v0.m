%
%__________________________________________________________________________
%
% Diverse solutions to manipulate csv data
%__________________________________________________________________________
%
%
% Solution
Solution = 6;
%
% Solution 1 --------------------------------------------------------------  
if Solution == 1
    d = fileread('C:\JG\Systems\Sys8_ExcelVBA\Test.csv');
    class(d)
% Solution 2 --------------------------------------------------------------      
elseif Solution == 2      
    loadchrone('C:\JG\Systems\Sys8_ExcelVBA\Test.csv')
% Solution 3 --------------------------------------------------------------      
elseif Solution == 3       
    fid = fopen('C:\JG\Systems\Sys8_ExcelVBA\Test.csv');
    %out = textscan(fid,'%s%f$f','delimiter',',');
    out = textscan(fid,'%s %f %f %f %f','delimiter',',');
    fclose(fid);   
    class(out)
    A = cell2mat(out);
    %date = datevec(out{1});
    %col1 = out{2};
    %col2 = out{3};    
% Solution 4 --------------------------------------------------------------    
elseif Solution == 4      
    fid = fopen('C:\JG\Systems\Sys8_ExcelVBA\Test.csv','r');% r is pread permission (not mandatory)
    tline = fgetl(fid);
    %  Split header
    Header(1,:) = regexp(tline, '\,', 'split');  
    % Parse the Date
    %ctr = 1;
    %while(~feof(fid))
    %    if ischar(tline)    
    %          ctr = ctr + 1;
    %          tline = fgetl(fid); 
    %          Date2Cell(ctr,:) = regexp(tline, '\,', 'split');
    %    else
    %        break;   
    %    end    
    %end    
    % Parse the Data
    ctr = 1;
    while(~feof(fid))
        if ischar(tline)    
              ctr = ctr + 1;
              tline = fgetl(fid); 
              %DataCell(ctr,:) = regexp(tline, '\,', 'split');
              DataCell(ctr,:) = regexp(tline, '\,', 'split');
        else
            break;   
        end    
    end
    fclose(fid); 
    % convert to Array
    %Data_array = cell2mat(DataCe;ll);
    A=DataCell
% Solution 5 --------------------------------------------------------------    
elseif Solution == 5      
    fid = fopen('C:\JG\Systems\Sys8_ExcelVBA\Test.csv','r');% r is pread permission (not mandatory)
   % read the file headers, find N (one value)
    N = fscanf(fid, '%*s %*s\nN=%d\n\n', 1);
    % read each set of measurements
    for n = 1:N
        mystruct(n).mtime = fscanf(fid, '%s', 1);
        mystruct(n).mdate = fscanf(fid, '%s', 1);

        % fscanf fills the array in column order,
        % so transpose the results
        mystruct(n).meas  = ...
        fscanf(fid, '%f')';
    end
elseif Solution == 6 % !!!done
    data_cell = read_mixed_csv('C:\JG\Systems\Sys8_ExcelVBA\Test.csv',',');
    % Date
    ColIndex = 1;
    datex_cell = cellfun(@(s) {strtok(s)},data_cell(:,ColIndex));   
    %datex = cellfun(@(s) {datenum(s)},datex_cell(:,1)); 
    A=zeros(length(datex_cell),1);
    for i=500:length(datex_cell)
        A(i) = datenum(datex_cell(i));
    end
    datex = datestr(A);
    % Open
    ColIndex = 2;
    o_cell = cellfun(@(s) {str2double(s)},data_cell(:,ColIndex));
    o = cell2mat(o_cell);
    % High
    ColIndex = 3;
    h_cell = cellfun(@(s) {str2double(s)},data_cell(:,ColIndex));
    h = cell2mat(h_cell);  
    % Low
    ColIndex = 4;
    l_cell = cellfun(@(s) {str2double(s)},data_cell(:,ColIndex));
    l = cell2mat(l_cell);
    % Last
    ColIndex = 5;
    c_cell = cellfun(@(s) {str2double(s)},data_cell(:,ColIndex));
    c = cell2mat(c_cell);      
end    
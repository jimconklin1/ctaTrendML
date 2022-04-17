function[tday, tdaynum, timetop] = UploadTimeTop(dirname, sheetname)

%__________________________________________________________________________
%
% Extract Date, Open, High, Low, Close from an excel spreadsheet where:
% note 1: First row is comlumn headers (name of the time series)
% note 2: Date is in the first column & Data in the secodn row
% note 3: same format required for .csv files
%__________________________________________________________________________
%
%
   %
    % -- Xlsread data --
    [num, txt] = xlsread(dirname,sheetname);
    tday = txt(2:end, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    tdaynum = datenum(tday, 'mm/dd/yyyy');       % convert to numeric format
    tdaystr = datestr(tdaynum, 'yyyymmdd');      % convert to sting and into yyyymmdd format.
    tday = str2double(cellstr(tdaystr)); % convert the date strings first into cell arrays and then into numeric format.
    %numt = x2mdate(tday);
    % other format possible for e.g.
    %tday = datestr(tdaynum, 'ddmmyyyy'); % convert the format into yyyymmdd.
    %
    % -- Time top --
    timetop = num; 
    
  
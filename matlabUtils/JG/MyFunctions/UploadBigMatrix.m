function[tday, tdaynum, x] = UploadBigMatrix(DirName, FileName, SheetName, DataRange)

%__________________________________________________________________________
%
% Extract Date & Big Matrix
% note 1: First row is comlumn headers (name of the time series)
% note 2: Date is in the first column & Data in the secodn row
% note 3: same format required for .csv files
%__________________________________________________________________________
%
    %
    % -- XlsRead data --
    [num, txt] = xlsread(strcat(DirName,FileName), SheetName, DataRange);
    tday = txt(2:end, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    tdaynum = datenum(tday, 'mm/dd/yyyy');       % convert to numeric format
    tdaystr = datestr(tdaynum, 'yyyymmdd');      % convert to sting and into yyyymmdd format.
    tday = str2double(cellstr(tdaystr)); % convert the date strings first into cell arrays and then into numeric format.
    %
    % -- Extract Open, High, Low, Close, Volume --
    x=num;
   

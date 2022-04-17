function[tday, c] = UploadREER(dirname, StockName, sheetname)

%__________________________________________________________________________
%
% Extract Date, Open, High, Low, Close, VWAP & Volume from an excel
% spreadsheet where:
% The first row is mafe up of the comlumn headers
% Data starts at the secodn row
%
% note: same format required for .csv files
%__________________________________________________________________________
%
%
    % -- Filename --
    filename=StockName;     
    %
    % -- Xlsread data --
    [num, txt]=xlsread(strcat(dirname,filename),sheetname);
    tday=txt(2:end, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    tday=datestr(datenum(tday, 'mm/dd/yyyy'), 'yyyymmdd'); % convert the format into yyyymmdd.
    tday=str2double(cellstr(tday)); % convert the date strings first into cell arrays and then into numeric format.
    %
    % -- Extract Open, High, Low, Close, Volume --
    c = num;
    %

function[tdaydb, tdaynum, c] = UploadSingleTS(DirName, FileName, SheetName)

%__________________________________________________________________________
%
% Extract Date (2 formats) for a single time series (economic most of the 
% time) from an excel spreadsheet where:
%                       - The first row is made up of the comlumn headers
%                       - Data starts at the 2nd row
% Inputs:
% dirname is the path, FileName the name of the file 'abc.xls', SheetName
% the name of the worksheet
% Output:
% the time series and two format (tdaynum is used to rebuilt financial time
% series object mainly if needed)
%
% note: same format required for .csv files
%__________________________________________________________________________
%
% 
    %
    % -- Xlsread data --
    [num, txt]=xlsread(strcat(DirName,FileName),SheetName);
    tday = txt(2:end, 1);                   % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    tdaynum = datenum(tday, 'mm/dd/yyyy');  % convert to numeric format 
    tdaystr = datestr(tdaynum, 'yyyymmdd');    % convert the format into yyyymmdd.
    tdaydb = str2double(cellstr(tdaystr));     % convert the date strings first into cell arrays and then into numeric format.
    %
    % -- Extract Open, High, Low, Close, Volume --
    c = num(:,1); 
    %
    % -- Clean Data --
    for i=2:length(c)
        if isnan(c(i)), c(i)=c(i-1);  end
    end  
    %
    % -- Run for trading only --
    RunForTradingOnly=0;
    NbSteps=length(c);
    if RunForTradingOnly==1
        NbPoints=400;
        c(1:NbSteps-NbPoints,:)=[];  
    end
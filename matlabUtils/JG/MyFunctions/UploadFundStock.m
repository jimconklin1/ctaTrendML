function[tday, arm, eq, rv] = UploadFundStock(dirname, StockName, sheetname)

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
    % -- Extract ARM, EQ, RV --
    arm=num(:,1); eq=num(:,2); rv=num(:,3);
    %
    % -- Clean Data -- 
    for i=2:length(arm)
        if isnan(arm(i)), arm(i)=arm(i-1); end
        if isnan(eq(i)), eq(i)=eq(i-1); end   
        if isnan(rv(i)), rv(i)=rv(i-1);
        end  
    end    
    %

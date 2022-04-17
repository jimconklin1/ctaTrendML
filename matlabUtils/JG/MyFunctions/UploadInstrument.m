function[tday, tdaynum, o,h,l,c] = UploadInstrument(dirName, fileName, sheetName)

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
    [num, txt] = xlsread(strcat(dirName,fileName),sheetName);
    tday = txt(2:end, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    tdaynum = datenum(tday, 'mm/dd/yyyy');    % convert to numeric format
    tdaystr = datestr(tdaynum, 'yyyymmdd');   % convert to sting and into yyyymmdd format.
    tday = str2double(cellstr(tdaystr));      % convert the date strings first into cell arrays and then into numeric format.

    % -- Extract Open, High, Low, Close, Volume --
    o=num(:,1); h=num(:,2);  l=num(:,3); c=num(:,4); 
    %
    % -- Clean Data --
    % note: this is sometimes required if data is interesects in the excel
    % workbook source
    % clean 1. - If bank holiday, take the previous close
    for i=2:length(c)
        if isnan(c(i)), c(i)=c(i-1);  end
    end  
    % clean 2. - If bank holiday or old data when o,h and l not available
    for i=2:length(o)
        if isnan(o(i)), o(i)=c(i-1); end
        if isnan(h(i)), h(i)=c(i-1); end   
        if isnan(l(i)), l(i)=c(i-1); end  
    end    
    %
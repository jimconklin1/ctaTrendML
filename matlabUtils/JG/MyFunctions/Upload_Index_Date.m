function[tday, o, h, l, c, eom] = Upload_Index_Date(dirname, StockName, sheetname)

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
    o=num(:,1); h=num(:,2); l=num(:,3); c=num(:,4);
    eom=num(:,5); 
    %
    % -- Clean Data --
    for i=2:length(c)
        if isnan(c(i)), c(i)=c(i-1);  end
    end
    for i=2:length(o)
        if isnan(o(i)), o(i)=c(i-1); end
        if isnan(h(i)), h(i)=c(i-1); end   
        if isnan(l(i)), l(i)=c(i-1);
        end  
    end    
    %
    % -- Run for trading only --
    RunForTradingOnly=0;
    NbSteps=length(c);
    if RunForTradingOnly==1
        NbPoints=400;
        o(1:NbSteps-NbPoints,:)=[];  h(1:NbSteps-NbPoints,:)=[];  l(1:NbSteps-NbPoints,:)=[];  c(1:NbSteps-NbPoints,:)=[];  volspread(1:NbSteps-NbPoints,:)=[];
    end
function[tday, tdaynum, c] = UploadMacroSimple(dirname, MacroFactor, sheetname)

%__________________________________________________________________________
%
% Extract Date, Open, High, Low, Close from an excel spreadsheet where:
% note 1: First row is comlumn headers (name of the time series)
% note 2: Date is in the first column & Data in the secodn row
% note 3: same format required for .csv files
%__________________________________________________________________________
%
%
    % -- Filename --
    filename = MacroFactor;     
    %
    % -- Xlsread data --
    [num, txt] = xlsread(strcat(dirname,filename),sheetname);
    tday = txt(2:end, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    tdaynum = datenum(tday, 'mm/dd/yyyy');    % convert to numeric format
    tdaystr = datestr(tdaynum, 'yyyymmdd');   % convert to sting and into yyyymmdd format.
    tday = str2double(cellstr(tdaystr));      % convert the date strings first into cell arrays and then into numeric format.
    %numt = x2mdate(tday);
    % other format possible for e.g.
    %tday = datestr(tdaynum, 'ddmmyyyy'); % convert the format into yyyymmdd.
    %
    % -- Extract Open, High, Low, Close, Volume --
    c = num(:,1); 
    %
    % -- Clean Data --
    % note: this is sometimes required if data is interesects in the excel
    % workbook source
    % clean 1. - If bank holiday, take the previous close
    for i=2:length(c)
        if isnan(c(i)), c(i)=c(i-1);  end
    end  
    %
    % -- Option Run for Trading only --
    % (not used as of now)
    RunForTradingOnly=0;
    NbSteps=length(c);
    if RunForTradingOnly==1
        NbPoints=400;
        o(1:NbSteps-NbPoints,:)=[];  h(1:NbSteps-NbPoints,:)=[];  l(1:NbSteps-NbPoints,:)=[];  c(1:NbSteps-NbPoints,:)=[];  
    end
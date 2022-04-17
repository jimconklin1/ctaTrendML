%function[tday, o,h,l,c] = UploadMatFileOHLC(fullPath, matName)

%__________________________________________________________________________
%
% Extract Date, Open, High, Low, Close from an excel spreadsheet where:
% note 1: First row is comlumn headers (name of the time series)
% note 2: Date is in the first column & Data in the secodn row
% note 3: same format required for .csv files
%__________________________________________________________________________
%
fullPath='C:\JG\Quantitative_Global_Macro\QGM1_CrossAssets\GlobalCarry\Rates\';
matName='us_10y.mat';
    %
    % -- Xlsread data --
    tempData = load(fullfile(fullPath, matName));
    fileNames = fieldnames(tempData);
    indexRow = length(fileNames);
    tempData_double = eval(['tempData.' fileNames{indexRow}]);
    tday = tempData_double(1:end, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    
    tdayChar = num2str(tday);
    tdayCharCellstr=zeros(length(tday),1);
    for i=1:length(tday)
        ss=tdayChar(i,:);
        tdayCharCellstr(i) = cellstr(ss);
    end
    
    [Y, M, D] =datevec(tday_char);
    
    
    %tdayChar=sprintf('%d',tday(1));
    %for i=1:length(tday)
    %    tdayChar=[tdayChar ; sprintf('%d',tday(i))];
    %end
    %tdayChar(1,:)=[];
    

    
    %tdaynum = datenum(tday, 'mm/dd/yyyy');    % convert to numeric format
    %tdaystr = datestr(tdaynum, 'yyyymmdd');   % convert to sting and into yyyymmdd format.
    %tday = str2double(cellstr(tdaystr));      % convert the date strings first into cell arrays and then into numeric format.
    %numt = x2mdate(tday);
    % other format possible for e.g.
    %tday = datestr(tdaynum, 'ddmmyyyy'); % convert the format into yyyymmdd.
    %
    % -- Extract Open, High, Low, Close, Volume --
    o=tempData_double(:,2); h=tempData_double(:,3);
    l=tempData_double(:,4); c=tempData_double(:,5); 
    %
    % -- Clean Data --
    % note: this is sometimes required if data is interesects in the excel
    % workbook source
    % clean 1. - If bank holiday, take the previous close
    for i=2:length(c)
        if isnan(c(i)), c(i)=c(i-1);  end
    end  
    % clean 2. - If bank hjoliday or old data when o,h and l not available
    for i=2:length(o)
        if isnan(o(i)), o(i)=c(i-1); end
        if isnan(h(i)), h(i)=c(i-1); end   
        if isnan(l(i)), l(i)=c(i-1); end  
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
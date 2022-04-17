function[tday, tdaynum, numx] = UploadMacro(dirname, StockName, sheetname)

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
    [numx, txt] = xlsread(strcat(dirname,filename),sheetname);
    [rowx,colx] = size(numx);    
    % -- Extract & Work with Date --
    tday = txt(2:end, 1); % the first column (starting from the second row) is the trading days in format mm/dd/yyyy.
    tdaynum = datenum(tday, 'mm/dd/yyyy');       % convert to numeric format
    tdaystr = datestr(tdaynum, 'yyyymmdd');      % convert to sting and into yyyymmdd format.
    tday = str2double(cellstr(tdaystr)); % convert the date strings first into cell arrays and then into numeric format.
    % -- Header name --
    dataname = cell(1,colx);
    for j = 1:colx
        dataname(j) = {strcat('data',num2str(j))}; 
    end
    % -- Result --
    %numx.header = dataname; numx.dates = tdaynum; numx.data = numx;
    % -- Plot --
    %figure('Name',name_fig, 'NumberTitle','off');
    %plot(tdaynum,numx); datetick('x','dd-mm-yyyy');
    %grid on;


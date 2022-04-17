function[o,h,l,c,vwap,volu] = UploadStockDataBbg(StockName)

%__________________________________________________________________________
%
% Extract a Pair from Reuters or Bloomberg & Allign the data
% Input: Specify data base (Reuters or Bloomberg)
%__________________________________________________________________________
%
%
    % S:\ DRIVE
    maindrive='S:\';
    dir1='08 Trading\';  
    dir2='088 Quantitative Global Macro\0882 Equity_Stock\';     
    dir3='08823 Equity Trend Following\';
    dirname=strcat(maindrive,dir1,dir2,dir3);
    % Filename 
    filename=StockName;      
    % Sheets name 
    sheetname='today'; 
    %
    % Ranges
    MyRange='B5:G30000';  
    %
    % All Data
    all_data=xlsread(strcat(dirname,filename),sheetname,MyRange);
    % Stock
    Stock_Data=all_data(:,1:6);
    %
    % Extract Open, High, Low, CLose, Volume
    o=Stock_Data(:,1); h=Stock_Data(:,2); l=Stock_Data(:,3); c=Stock_Data(:,4); vwap=Stock_Data(:,5); volu=Stock_Data(:,6);
    %
    % Clean Data
    for i=2:length(c)
        if isnan(c(i)), c(i)=c(i-1);  end
    end
    for i=2:length(vwap)
        if isnan(vwap(i)), vwap(i)=vwap(i-1);  end
    end    
    for i=2:length(o)
        if isnan(o(i)), o(i)=c(i-1); end
        if isnan(h(i)), h(i)=c(i-1); end   
        if isnan(l(i)), l(i)=c(i-1);
        end  
    end    
    %
    % Run for trading only
    RunForTradingOnly=0;
    NbSteps=length(c);
    if RunForTradingOnly==1
        NbPoints=400;
        o(1:NbSteps-NbPoints,:)=[];  h(1:NbSteps-NbPoints,:)=[];  l(1:NbSteps-NbPoints,:)=[];  c(1:NbSteps-NbPoints,:)=[]; 
        vwap(1:NbSteps-NbPoints,:)=[]; volu(1:NbSteps-NbPoints,:)=[];
    end
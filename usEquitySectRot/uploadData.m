%
%__________________________________________________________________________
%
% This functiondownload all the data
% "MySqlSource" means the universe is located in MySql and uploded from the
% function: universe = readDbTable(ctx.dbConn, 'universe').
%
% on the 5th of Feb, after data issue with tsrp, wsitch to BBi SAPI
%__________________________________________________________________________
%

function dataSet = uploadData(configData) 

    % -- create structure --
    dataSet = struct;
    dataSource = configData.dataSource;
    bbgSource = configData.bbgSource;
    startDate = configData.startDate;
    dataSet.startDate = startDate;

    % -- Data source --
    if strcmp(dataSource, 'bbg')
        ConBbg = BbgApiCheck(bbgSource);
        d = datetime('today')-1;
        formatDate = 'mm/dd/yyyy';
        endDate = datestr(d, formatDate);
    elseif strcmp(dataSource, 'tsrp')  
        d = datetime('today')-1;
        formatDate = 'yyyy-mm-dd'; 
        endDate = datestr(d, formatDate);    
    end

    dataSet.endDate = endDate;
    transCost = configData.transCost;
    dataSet.transCost = transCost;

    instrumentList = {'XLY US Equity', 'XLP US Equity', 'XLE US Equity', 'XLFS US Equity', 'XLF US Equity', 'XLV US Equity', 'XLI US Equity', 'XLB US Equity', 'XLRE US Equity', 'XLK US Equity', 'XLU US Equity'};
    factorList = {'SP1 Index', 'VIX Index', 'DXY Index', 'CO1 Comdty', 'USGG10YR Index', 'USGG2YR Index'};
    dataSet.instrumentList = instrumentList;
    dataSet.factorList = factorList;
    
    nbOfAssets = length(instrumentList);
    nbOfFactors = length(factorList);

    % Benchmark SP1 Index
    ohlcOpt = 4; vwapOpt = 0;    volumeOpt = 0;    openIntOpt = 0;     % Option For Bloomberg wrapper
    data = BbgHistWrapper(ConBbg, 'SP1 Index', ohlcOpt, vwapOpt, volumeOpt, openIntOpt, startDate, endDate, 'daily');
    dateBench = data(:,1);
    dateNum = data(:,2);
    dataSet.dateBench = dateBench;
    dataSet.dateNum = dateNum;

    % Prelocate matrix based on Benchmark asset
    nsteps = length(dateBench);    % # data points  
    o = zeros(nsteps,nbOfAssets);    h = zeros(nsteps,nbOfAssets);   
    l = zeros(nsteps,nbOfAssets);    c = zeros(nsteps,nbOfAssets); 
    %volu = zeros(nsteps,2);       %opint = zeros(nsteps,2);
   
    % Instruments
    ohlcOpt = 4; vwapOpt = 0;    volumeOpt = 0;    openIntOpt = 0;     % Option For Bloomberg wrapper
    for j = 1:nbOfAssets 
        data = BbgHistWrapper(ConBbg, instrumentList(j), ohlcOpt, vwapOpt, volumeOpt, openIntOpt, startDate, endDate, 'daily');
        oJunk = VlookupExcel(dateBench, data(:,1), data(:,3), 'NaNtoZero');  
        hJunk = VlookupExcel(dateBench, data(:,1), data(:,4), 'NaNtoZero'); 
        lJunk = VlookupExcel(dateBench, data(:,1), data(:,5), 'NaNtoZero'); 
        cJunk = VlookupExcel(dateBench, data(:,1), data(:,6), 'NaNtoZero'); 
        %voluJunk = VlookupExcel(dateBench, data(:,1), data(:,7), 'NaNtoZero'); 
        % Assign;
        o(:,j) = oJunk;        h(:,j) = hJunk;  
        l(:,j) = lJunk;        c(:,j) = cJunk;   % volu(:,j) = voluJunk; 
    end 
    dataSet.o = o;
    dataSet.h = h;
    dataSet.l = l;
    dataSet.c = c;
    
    % Factors
    ohlcOpt = 1; vwapOpt = 0;    volumeOpt = 0;    openIntOpt = 0;     % Option For Bloomberg wrapper
    cf = zeros(nsteps,nbOfFactors);     
    for j = 1:nbOfFactors
        data = BbgHistWrapper(ConBbg, factorList(j), ohlcOpt, vwapOpt, volumeOpt, openIntOpt, startDate, endDate, 'daily');
        cJunk = VlookupExcel(dateBench, data(:,1), data(:,3), 'NaNtoZero');   
        % Assign;
        cf(:,j) = cJunk; 
    end    
    dataSet.cf = cf;
    
end



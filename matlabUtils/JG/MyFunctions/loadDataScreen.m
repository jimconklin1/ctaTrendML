%
%__________________________________________________________________________
%
% Create a data structure
% Input:
% - dataSource: 'bbg' or 'tsrp'
% - assetBench is Benchmark asset against which data is alligned.
%   In the case of one asset, usually, it is the same asset.
% - instrumentList is a list
% - factors lists is a list
% - factorsFields is the list of fields the user wants for the factor
% - factorsFieldsIn is  amtrix Nb. of "Field Names x Nb. of Factors" as the
%   user may not want all the fields name for a given factor (takes value
%   of 1 or 0)
% - freqData is the frequency
% - startDate is '1/1/2000' for Bloomberg's format or ...
%   '2015-08-19' for TSRP format for example
%__________________________________________________________________________
%
function dataScreen = loadDataScreen(dataSource, assetBench, instrumentsList, vwapVolumeOpInt, factorsList, factorsFields, factorsFieldsIn, freqData, startDate)

addpath 'H:\GIT\matlabUtils\JG\MyFunctions\';
addpath 'H:\GIT\matlabUtils\JG\SecuritiesMasterDatabase_M\SMDBM_Functions\';
addpath 'H:\GIT\matlabUtils\JG\PortfolioOptimization\';
addpath 'H:\GIT\liquidPtf\script\';
addpath 'H:\GIT\mtsrp\';

% -- Prelocate & Dimensions --
dataScreen = struct;

dataScreen.assetBench = assetBench;
dataScreen.instrumentsList = instrumentsList;
dataScreen.vwapVolumeOpInt = vwapVolumeOpInt;
dataScreen.factorsList = factorsList;
dataScreen.freqData = freqData;
dataScreen.startDate = startDate;

instsNb = length(instrumentsList);
factorsNb = length(factorsList);
factorsFieldsNb = length(factorsFields);

if strcmp(dataSource,'bbg') || strcmp(dataSource,'Bbg') || ...
        strcmp(dataSource,'bloomberg') || strcmp(dataSource,'Bloomberg')
    
    % -- BBg API --
    ConBbg = BbgApiCheck('local');
    dataScreen.ConBbg = ConBbg;
    
    % -- Fetch option --
    ohlcOpt = 4; % by default, open high low clsoe
    vwapOpt = vwapVolumeOpInt(1,1);
    volumeOpt = vwapVolumeOpInt(1,2);
    opintOpt = vwapVolumeOpInt(1,3);     % Option For Bloomberg wrapper
    
    % -- today s date --
    d = datetime('today'); formatDate = 'mm/dd/yyyy'; 
    endDate = datestr(d, formatDate);    
    
    % -- Create benchmark --    
    data = BbgHistSingleTS(ConBbg, assetBench, 'PX_LAST', startDate, endDate, freqData);
    dateBench = data(:,1);      dataScreen.dateBench = dateBench ;
    dateNum = data(:,2);        dataScreen.dateNum = dateNum;
    nsteps = size(dateBench,1);
    
    % Prelocate
    o = zeros(nsteps , instsNb);
    h = zeros(nsteps , instsNb);
    l = zeros(nsteps , instsNb);
    c = zeros(nsteps , instsNb);
    vwap = zeros(nsteps , instsNb);
    volu = zeros(nsteps , instsNb);
    opint = zeros(nsteps , instsNb);
    factors = zeros(nsteps , 1);
    
    % -- O,H,L,C,Volume --
    for j=1:instsNb
        data = BbgHistWrapper(ConBbg, instrumentsList(j), ohlcOpt, vwapOpt, volumeOpt, opintOpt, startDate, endDate, freqData);
        oJunk = VlookupExcel(dateBench, data(:,1), data(:,3), 'NaNtoZero');
        o(:,j) = oJunk; 
        hJunk = VlookupExcel(dateBench, data(:,1), data(:,4), 'NaNtoZero');
        h(:,j) = hJunk; 
        lJunk = VlookupExcel(dateBench, data(:,1), data(:,5), 'NaNtoZero');
        l(:,j) = lJunk;      
        cJunk = VlookupExcel(dateBench, data(:,1), data(:,6), 'NaNtoZero');
        c(:,j) = cJunk; 
        % VWAP only (for stocks usually)
        if vwapOpt == 1 && volumeOpt == 0 && opintOpt == 0
            vwapJunk = VlookupExcel(dateBench, data(:,1), data(:,7), 'NaNtoZero');
            vwap(:,j) = vwapJunk;
        % Volume only
        elseif volumeOpt == 1 && vwapOpt == 0 && opintOpt == 0
            voluJunk = VlookupExcel(dateBench, data(:,1), data(:,7), 'NaNtoZero');
            volu(:,j) = voluJunk;
        % VWAP & Volume
        elseif vwapOpt == 1 && volumeOpt == 1 && opintOpt == 0
            vwapJunk = VlookupExcel(dateBench, data(:,1), data(:,7), 'NaNtoZero');
            vwap(:,j) = vwapJunk;            
            voluJunk = VlookupExcel(dateBench, data(:,1), data(:,8), 'NaNtoZero');
            volu(:,j) = voluJunk;
        % Open Interest only
        elseif opintOpt == 1 && vwapOpt == 0 && volumeOpt == 0 
            opintJunk = VlookupExcel(dateBench, data(:,1), data(:,7), 'NaNtoZero'); 
            opint(:,j) = opintJunk;
        % Volume &  Open Interest
        elseif volumeOpt == 1 && opintOpt == 1 && vwapOpt == 0
            voluJunk = VlookupExcel(dateBench, data(:,1), data(:,7), 'NaNtoZero');
            volu(:,j) = voluJunk;            
            opintJunk = VlookupExcel(dateBench, data(:,1), data(:,8), 'NaNtoZero'); 
            opint(:,j) = opintJunk;            
        end
    end
    % Assign
    dataScreen.o = o; dataScreen.h = h; dataScreen.l = l; dataScreen.c = c;
    if  vwapOpt == 1, dataScreen.vwap = vwap;   end;
    if  volumeOpt == 1, dataScreen.volu = volu;   end;
    if  opintOpt == 1, dataScreen.opint = opint;   end; 
    
    % -- Factors --
    if factorsNb >= 1
        for uuu=1:factorsFieldsNb
            fieldName = factorsFields(1,uuu);
            for j=1:factorsNb
                if factorsFieldsIn(uuu,j) == 1
                    try
                        data = BbgHistSingleTS(ConBbg, factorsList(j), fieldName, startDate, endDate, freqData);
                        dataJunk = VlookupExcel(dateBench, data(:,1), data(:,3), 'NaNtoZero');
                        factors = [factors, dataJunk];
                    catch
                        dips('no value')
                    end
                end
            end
        end
    end
    factors(:,1)=[];
    % Assign
    dataScreen.factors = factors;
    
elseif strcmp(dataSource,'tsrp') || strcmp(dataSource,'Tsrp')
    
    % -- today s date --
    d = datetime('today'); formatDate = 'yyyy-mm-dd'; 
    endDate = datestr(d, formatDate);
    
    % -- create benchmark --
    data = tsrp.fetch_bbg_daily_close(assetBench, startDate, endDate);
    dateNum = data(:,1);        dataScreen.dateNum = dateNum;
    dateBench = Num2CellVectorDate(dateNum);
    dataScreen.dateBench = dateBench ;
    nsteps = size(dateBench,1);
    
    % -- Prelocate --
    o = zeros(nsteps , instsNb);    h = zeros(nsteps , instsNb);
    l = zeros(nsteps , instsNb);    c = zeros(nsteps , instsNb);
    volu = zeros(nsteps , instsNb); %vwap = zeros(nsteps , instsNb);    opint = zeros(nsteps , instsNb); 
    factors = zeros(nsteps , 1);
    
    % -- O,H,L,C,Volume --
    for j=1:instsNb
        data = tsrp.fetch_bbg_daily_bar(instrumentsList(j), startDate, endDate);
        oJunk = VlookupExcel(dateNum, data(:,1), data(:,2), 'NaNtoZero');
        o(:,j) = oJunk;  
        hJunk = VlookupExcel(dateNum, data(:,1), data(:,3), 'NaNtoZero');
        h(:,j) = hJunk; 
        lJunk = VlookupExcel(dateNum, data(:,1), data(:,4), 'NaNtoZero');
        l(:,j) = lJunk;        
        cJunk = VlookupExcel(dateNum, data(:,1), data(:,5), 'NaNtoZero');
        c(:,j) = cJunk; 
        voluJunk = VlookupExcel(dateNum, data(:,1), data(:,6), 'NaNtoZero');
        volu(:,j) = voluJunk; 
    end
    % Assign
    dataScreen.o = o; dataScreen.h = h; dataScreen.l = l; dataScreen.c = c;
    dataScreen.volu = volu;
    
    % -- Factors --
    if factorsNb >= 1
        for uuu=1:factorsFieldsNb
            fieldName = factorsFields(1,uuu);
            for j=1:factorsNb
                if factorsFieldsIn(uuu,j) == 1 && strcmp(fieldName,'PX_LAST')
                    %try
                        data = tsrp.fetch_bbg_daily_close(factorsList(j), startDate, endDate); % This function retrieves close only
                        dataJunk = VlookupExcel(dateNum, data(:,1), data(:,2), 'NaNtoZero');
                        factors = [factors, dataJunk];
                    %catch
                    %    disp('no value')
                    %end
                end
            end
            for j=1:factorsNb
                if factorsFieldsIn(uuu,j) == 1 && strcmp(fieldName,'PX_VOLUME')                    
                    %try
                        data = tsrp.fetch_bbg_daily_bar(factorsList(j), startDate, endDate); % this function retrieve OHLC VOlume
                        dataJunk = VlookupExcel(dateNum, data(:,1), data(:,6), 'NaNtoZero');
                        factors = [factors, dataJunk];
                    %catch
                    %    disp('no value')
                    %end
                end                
            end
        end
    end
    factors(:,1)=[];    

    % Assign
    dataScreen.factors = factors;    
        
end


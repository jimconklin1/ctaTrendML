%
%__________________________________________________________________________
%
% Model wrapper
%
% A function that allows to 
% 1. download data according to 2 data sources : Bloomberg or tsrp
% 2. backtest
% 3. write a table
%
% Input:
% - assetBench is Benchmark asset against which data is alligned.
%   In the case of one asset, usually, it is the same asset.
% - instrumentList is a list
% - factors lists is a list
% - startDate is '1/1/2000' for Bloomberg's format or ...
%   '2015-08-19' for TSRP format for example
% - tableName for csv output
% - fcnHandleScreen function passed as an argument to run signal
%
% dataOutput = modelWrapper(dataPath, 'bbg', 'HI1 PIT Index', {'HI1 PIT Index'}, [0,0,0],...
% {'HIHD03M Index',  'US0003M Index',  'VHSI Index'}, 'daily', '1/1/1990', @HangSeng_Screen1, 'HangSeng_Liquidity_VRP.csv')
%__________________________________________________________________________
%

function tScreen = modelWrapper(dataPath, dataSource, assetBench, instrumentsList, vwapVolumeOpInt, factorsList, factorsFields, factorsFieldsIn, freqData, startDate, fcnHandleScreen, tableName)


if (~isdeployed)
    addpath 'H:\GIT\matlabUtils\JG\MyFunctions\';
    addpath 'H:\GIT\matlabUtils\_thematic_screen\';
    addpath 'H:\GIT\matlabUtils\JG\SecuritiesMasterDatabase_M\SMDBM_Functions\';
    addpath 'H:\GIT\matlabUtils\JG\PortfolioOptimization\';
    addpath 'H:\GIT\liquidPtf\script\';
    addpath 'H:\GIT\mtsrp\';
end

% load data
dataScreen = loadDataScreen(dataSource, assetBench, instrumentsList, vwapVolumeOpInt, factorsList, factorsFields, factorsFieldsIn, freqData, startDate);

% build screen 
screenOutput = fcnHandleScreen(dataScreen);

% create the output (flast matrix) & table
ptfec = screenOutput.ptfec;
ptfpl = screenOutput.ptfpl;
s = screenOutput.s;
nbSignals = size(s,2);
dateNum = dataScreen.dateNum;
dateBench = dataScreen.dateBench;

% create stirng for signal
signalString = genvarname({'signal'});
for j=1:nbSignals-1
    signalString = [signalString,genvarname({'signal'})];
end
for j=1:nbSignals 
  signalString{j} = strcat('signal', num2str(j));
end
% write a table format for TSRP    
if strcmp(dataSource,'bbg')
    varNames = {'dateNumFormat', 'signal', 'geometricPL', 'nonCumulPL', 'dateStrFormat'};
    tScreen  = array2table( [dateNum, s, ptfec, ptfpl, dateBench], 'VariableNames', varNames);
    writetable(tScreen,[dataPath,tableName]);
elseif strcmp(dataSource,'tsrp')
    varNames = [{'dateNumFormat'}, signalString, {'geometricPL', 'nonCumulPL'}];
    tScreen  = array2table( [dateNum, s, ptfec, ptfpl], 'VariableNames', varNames);
    writetable(tScreen,[dataPath,tableName]);
end


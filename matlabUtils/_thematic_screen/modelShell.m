%
%__________________________________________________________________________
%
% Simple shell in order to have a code less code on quant signals
% dataDestinationPath = 'S:\quantQA\DATA\signal\thematicMacroScreen\';
%__________________________________________________________________________
%
%
function s = modelShell(dataPath, modelName)

dataDestinationPath = strcat(dataPath,'thematicMacroScreen\');

if strcmp(modelName, 'HangSengScreen1')

    tblTemp = modelWrapper(dataDestinationPath, 'tsrp', {'HI1 PIT Index'}, {'HI1 PIT Index'}, [0,0,0], {'HIHD03M Index','US0003M Index','VHSI Index'}, {'PX_LAST'}, [1,1,1], 'daily', '1990-01-01', ...
        @HangSeng_Screen1, 'HangSeng_Liquidity_VRP.csv');
    
elseif strcmp(modelName, 'JGBScreen1')
    
    tblTemp = modelWrapper(dataDestinationPath, 'tsrp', {'JB1 PIT Comdty'}, {'JB1 PIT Comdty'}, [0,0,0], {'NI1 PIT Index','VNKY PIT Index','AUDJPY Curncy'}, {'PX_LAST', 'PX_VOLUME'}, ...
        [1,1,1;1,0,0], 'daily', '1980-01-01', @JGB_Screen1, 'JGB_vrp_audjpy.csv');   
    
elseif strcmp(modelName, 'oilComplexScreen')
    
    tblTemp = modelWrapper(dataDestinationPath, 'tsrp', {'XLE US Equity'}, {'XLE US Equity', 'SP1 PIT Index', 'CO1 PIT Comdty'}, [0,0,0], {'CO5 PIT Comdty'}, {'PX_LAST'}, [1], ...
        'daily', '2006-01-01', @oilComplexScreen, 'oilComplexScreen.csv');     
    
end

% -- Create structure to store output -- 
dimTable = size(tblTemp,2);
s.dates = tblTemp.dateNumFormat(:,1); 
s.geopl = tblTemp.geometricPL(:,1); 
s.pl = tblTemp.nonCumulPL(:,1);
nbSignals = dimTable-3;
s.signal = table2array(tblTemp(:,2:nbSignals+1));

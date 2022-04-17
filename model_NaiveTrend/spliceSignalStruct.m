function signalMerged = spliceSignalStruct( signalOld, signalNew ,spliceDate   )
%SPLICESIGNALSTRUCT Summary of this function goes here
%   Detailed explanation goes here

    if ~isequal (signalOld.subStratNames , signalNew.subStratNames) || ~isequal (signalOld.subStratAssetClass , signalNew.subStratAssetClass) || ...
            ~isequal (signalOld.variableList , signalNew.variableList) || ~isequal (length ( signalOld.subStrat ), length( signalNew.subStrat))
        error('old and new structures are different.');
    else 
        signalMerged.subStratNames = signalOld.subStratNames ; 
        signalMerged.subStratAssetClass = signalOld.subStratAssetClass ; 
        signalMerged.variableList = signalOld.variableList ; 
    end 
    
    for i =1: length ( signalOld.subStrat )
        if  ~isequal (signalOld.subStrat(i).assetIDs , signalNew.subStrat(i).assetIDs ) || ...
            ~isequal (signalOld.subStrat(i).assets , signalNew.subStrat(i).assets )  
                error('old and new structures are different.');
        else 
            if ~isequal (signalOld.subStrat(i).name , signalNew.subStrat(i).name ) 
                warning('Only names are different!.');
            end 
            if isfield(signalNew.subStrat(i),'lookbacks') 
                if isequal (signalOld.subStrat(i).lookbacks , signalNew.subStrat(i).lookbacks ) 
                    signalMerged.subStrat(i).lookbacks= signalNew.subStrat(i).lookbacks ;
                else 
                    error('old and new structures have different lookbacks.');
                end 
            end 
            signalMerged.subStrat(i).assetIDs = signalNew.subStrat(i).assetIDs ;
            signalMerged.subStrat(i).name= signalNew.subStrat(i).name ;
            signalMerged.subStrat(i).assets= signalNew.subStrat(i).assets ;
            tT = find(signalOld.subStrat(i).dates <= spliceDate,1,'last');
            t0 = find(signalNew.subStrat(i).dates >= spliceDate,1,'first');
            if signalOld.subStrat(i).dates(tT) == signalNew.subStrat(i).dates(t0); t0 = t0+1; end % if
            signalMerged.subStrat(i).dates = [signalOld.subStrat(i).dates(1:tT,:); signalNew.subStrat(i).dates(t0:end,:)];
            if length (size(signalOld.subStrat(i).values))==2
                signalMerged.subStrat(i).values = [signalOld.subStrat(i).values(1:tT,:); signalNew.subStrat(i).values(t0:end,:)];
            elseif length (size(signalOld.subStrat(i).values))==3
                signalMerged.subStrat(i).values = [signalOld.subStrat(i).values(1:tT,:,:); signalNew.subStrat(i).values(t0:end,:,:)];
            end
        end 

    end


end


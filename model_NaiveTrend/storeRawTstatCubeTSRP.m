function storeRawTstatCubeTSRP( config , tstatCubeRawTK,tstatCubeRawLN , tstatCubeRawNY , spliceDates   )
%STORERAWTSTAT Summary of this function goes here
%   Detailed explanation goes here
    names = fieldnames(config.tstat) ; 
    for j =1 : length (names)
        fld = config.tstat.(names{j}); 
        if isfield (fld, 'fParam') && ~fld.fParam.fetchTstatOption
            fParam = fld.fParam ; 
            i = fParam.subStrategyNum; 
            lookbacks = fParam.lookbacks ; 

        
            assets0=tstatCubeRawTK.subStrat(i).assetIDs;
            for h =1:length(assets0)
                if strcmpi(assets0{h}(1:3), 'fx.')
                    assets0{h}= assets0{h}(4:end) ;
                end 
            end
            tempTK.header = assets0;
            tempLN.header = assets0;
            tempNY.header = assets0;
            
            if isnan(spliceDates(1)) || isnan(spliceDates(2)) ||isnan(spliceDates(3))
                tk_t0 = 1; ln_t0 =1; ny_t0 =1;
                disp([' Storing ALL tstats  for ', names{j} ,' : ', datestr(datetime())]);
                disp([' TK from ', datestr(tstatCubeRawTK.subStrat(i).dates(tk_t0))]);
                disp([' LN from ', datestr(tstatCubeRawLN.subStrat(i).dates(ln_t0))]);
                disp([' NY from ', datestr(tstatCubeRawNY.subStrat(i).dates(ny_t0))]);
            else 
                tk_t0 = find(tstatCubeRawTK.subStrat(i).dates >= spliceDates(1) , 1 ); 
                ln_t0 = find(tstatCubeRawLN.subStrat(i).dates >= spliceDates(2) , 1 ); 
                ny_t0 = find(tstatCubeRawNY.subStrat(i).dates >= spliceDates(3) , 1 ); 
                disp([' Storing tstats for ', names{j} , ' from ' , datestr(spliceDates(1))]);
                disp([' TK from ', datestr(tstatCubeRawTK.subStrat(i).dates(tk_t0))]);
                disp([' LN from ', datestr(tstatCubeRawLN.subStrat(i).dates(ln_t0))]);
                disp([' NY from ', datestr(tstatCubeRawNY.subStrat(i).dates(ny_t0))]);
            end 
                tempTK.dates = tstatCubeRawTK.subStrat(i).dates(tk_t0:end);
                tempLN.dates = tstatCubeRawLN.subStrat(i).dates(ln_t0:end);
                tempNY.dates = tstatCubeRawNY.subStrat(i).dates(ny_t0:end);
        
             for k =1:length(lookbacks)
                tempTK.tstat = tstatCubeRawTK.subStrat(i).values(tk_t0:end,:, k);
                tempLN.tstat = tstatCubeRawLN.subStrat(i).values(ln_t0:end,:, k);
                tempNY.tstat = tstatCubeRawNY.subStrat(i).values(ny_t0:end,:, k);

                tstatTableTK = customStruct2Table(tempTK, {'tstat'}, {'.*'}, {});
                tstatTableLN = customStruct2Table(tempLN, {'tstat'}, {'.*'}, {});
                tstatTableNY = customStruct2Table(tempNY, {'tstat'}, {'.*'}, {});
                tstatTable = sortrows([tstatTableTK; tstatTableLN; tstatTableNY], 1); 
                for n =1 : length(assets0)
                    key = tstatTable.Properties.VariableNames{n+1};
                    tsrp.store_user_daily(strcat('u.d.',key ,'_',num2str(lookbacks(k))), tstatTable(:,[1,n+1]), false);
                end 
             end 
        end 
    end 
    





end


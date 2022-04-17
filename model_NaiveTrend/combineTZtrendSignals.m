function signal = combineTZtrendSignals(signalTK,signalLN,signalNY,executionTZ,dataConfig)

% parse possible input strings on execution time zone argument:
if strcmpi(executionTZ,'postTK')||strcmpi(executionTZ,'postTokyo')||strcmpi(executionTZ,'postTKClose')...
        ||strcmpi(executionTZ,'postTokyoClose')
   executionTZ = 'postTokyoClose'; 
   signal = signalTK;
   sesCls = dataConfig.assetSessionSelect.postTK; 
elseif strcmpi(executionTZ,'postLN')||strcmpi(executionTZ,'postLondon')||strcmpi(executionTZ,'postLNClose')...
        ||strcmpi(executionTZ,'postLondonClose')
   executionTZ = 'postLondonClose'; 
   signal = signalLN;
   sesCls = dataConfig.assetSessionSelect.postLN; 
elseif strcmpi(executionTZ,'postNY')||strcmpi(executionTZ,'postNewYork')||strcmpi(executionTZ,'postNewYorkClose')...
        ||strcmpi(executionTZ,'postNYClose')
   executionTZ = 'postNYClose'; 
   signal = signalNY;
   sesCls = dataConfig.assetSessionSelect.postNY; 
end

switch executionTZ
    case 'postTokyoClose'
        for k = 1:length(signal.subStratNames)
            signalLN.subStrat(k).values=rmNaNs (signalLN.subStrat(k).values,0);
            signalNY.subStrat(k).values=rmNaNs (signalNY.subStrat(k).values,0);
            signal.subStrat(k).values=rmNaNs(signal.subStrat(k).values,0);
            switch signal.subStratNames{k}
                case 'ratesBond'
                    begDateStr = dataConfig.rates.bonds.goodDataBeg; 
                case 'equityDM'
                    begDateStr = dataConfig.equity.dm.goodDataBeg; 
                case 'equityEM' 
                    begDateStr = dataConfig.equity.em.goodDataBeg; 
                case 'ccyDM' 
                    begDateStr = dataConfig.ccy.dm.goodDataBeg; 
                case 'ccyEM'
                    begDateStr = dataConfig.ccy.em.goodDataBeg; 
                case 'comdtyEnergy'
                    begDateStr = dataConfig.comdty.energy.goodDataBeg; 
                case 'comdtyMetals' 
                    begDateStr = dataConfig.comdty.metals.goodDataBeg; 
                case 'comdtyAgs' 
                    begDateStr = dataConfig.comdty.ags.goodDataBeg; 
                case 'ratesShortRates'
                    begDateStr = dataConfig.rates.shortRates.goodDataBeg; 
            end % switch
            for n = 1:length(signal.subStrat(k).assetIDs)
                nn = find(strcmp(dataConfig.assetIDs,signal.subStrat(k).assetIDs{n}));
                if strcmp(sesCls(nn),'LN') % get yesterday's Lndn close positions
                    for t = 2:length(signal.subStrat(k).dates)
                        tt = find(signalLN.subStrat(k).dates<signal.subStrat(k).dates(t),1,'last');
                        if ~isempty(tt) && ~isnan(signalLN.subStrat(k).values(tt,n))
                           signal.subStrat(k).values(t,n) = signalLN.subStrat(k).values(tt,n);
                        end % if
                    end % for t
                    % suppress signal values prior to good data dates:
                    begDate = datenum(begDateStr(2,n),'yyyymmdd'); % row that corresponds to LN
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB> 
                elseif strcmp(sesCls(nn),'NY') % get yesterday's NY close positions
                    for t = 2:length(signal.subStrat(k).dates)
                        tt = find(signalNY.subStrat(k).dates<signal.subStrat(k).dates(t),1,'last');
                        if ~isempty(tt) && ~isnan(signalNY.subStrat(k).values(tt,n))
                           signal.subStrat(k).values(t,n) = signalNY.subStrat(k).values(tt,n);
                        end % if
                    end % for t
                    % suppress signal values prior to good data dates:
                    begDate = datenum(begDateStr(3,n),'yyyymmdd'); % row that corresponds to NY
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB> 
                elseif strcmp(sesCls(nn),'TK')
                    begDate = datenum(begDateStr(1,n),'yyyymmdd'); % row that corresponds to TK
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB> 
                end % if
            end % for n
        end % for k
        
    case 'postLondonClose'
        for k = 1:length(signal.subStratNames)
            signalNY.subStrat(k).values=rmNaNs (signalNY.subStrat(k).values,0);
            signalTK.subStrat(k).values=rmNaNs (signalTK.subStrat(k).values,0);
            signal.subStrat(k).values=rmNaNs(signal.subStrat(k).values,0);
            switch signal.subStratNames{k}
                case 'ratesBond'
                    begDateStr = dataConfig.rates.bonds.goodDataBeg; 
                case 'equityDM'
                    begDateStr = dataConfig.equity.dm.goodDataBeg; 
                case 'equityEM' 
                    begDateStr = dataConfig.equity.em.goodDataBeg; 
                case 'ccyDM' 
                    begDateStr = dataConfig.ccy.dm.goodDataBeg; 
                case 'ccyEM'
                    begDateStr = dataConfig.ccy.em.goodDataBeg; 
                case 'comdtyEnergy'
                    begDateStr = dataConfig.comdty.energy.goodDataBeg; 
                case 'comdtyMetals' 
                    begDateStr = dataConfig.comdty.metals.goodDataBeg; 
                case 'comdtyAgs' 
                    begDateStr = dataConfig.comdty.ags.goodDataBeg; 
                case 'ratesShortRates'
                    begDateStr = dataConfig.rates.shortRates.goodDataBeg; 
            end % switch
            for n = 1:length(signal.subStrat(k).assetIDs)
                nn = find(strcmp(dataConfig.assetIDs,signal.subStrat(k).assetIDs{n}));
                if strcmp(sesCls(nn),'TK')
                    for t = 2:length(signal.subStrat(k).dates)
                        tt = find(signalTK.subStrat(k).dates<signal.subStrat(k).dates(t),1,'last');
                        if ~isempty(tt) && ~isnan(signalTK.subStrat(k).values(tt,n))
                           signal.subStrat(k).values(t,n) = signalTK.subStrat(k).values(tt,n);
                        end % if
                    end % for t
                    % suppress signal values prior to good data dates:
                    begDate = datenum(begDateStr(1,n),'yyyymmdd'); % row that corresponds to TYO
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB> 
                elseif strcmp(sesCls(nn),'NY')
                    for t = 2:length(signal.subStrat(k).dates)
                        tt = find(signalNY.subStrat(k).dates<signal.subStrat(k).dates(t),1,'last');
                        if ~isempty(tt) && ~isnan(signalNY.subStrat(k).values(tt,n))
                           signal.subStrat(k).values(t,n) = signalNY.subStrat(k).values(tt,n);
                        end 
                    end % for t
                    % suppress signal values prior to good data dates:
                    begDate = datenum(begDateStr(3,n),'yyyymmdd'); % row that corresponds to NY
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB> 
                elseif strcmp(sesCls(nn),'LN')
                    begDate = datenum(begDateStr(2,n),'yyyymmdd'); % row that corresponds to LN
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB> 
                end % if
            end % for n
        end % for k
        
    case 'postNYClose'
        for k = 1:length(signal.subStratNames)
            signalLN.subStrat(k).values=rmNaNs (signalLN.subStrat(k).values,0);
            signalTK.subStrat(k).values=rmNaNs (signalTK.subStrat(k).values,0);
            signal.subStrat(k).values=rmNaNs(signal.subStrat(k).values,0);
            switch signal.subStratNames{k}
                case 'ratesBond'
                    begDateStr = dataConfig.rates.bonds.goodDataBeg; 
                case 'equityDM'
                    begDateStr = dataConfig.equity.dm.goodDataBeg; 
                case 'equityEM' 
                    begDateStr = dataConfig.equity.em.goodDataBeg; 
                case 'ccyDM' 
                    begDateStr = dataConfig.ccy.dm.goodDataBeg; 
                case 'ccyEM'
                    begDateStr = dataConfig.ccy.em.goodDataBeg; 
                case 'comdtyEnergy'
                    begDateStr = dataConfig.comdty.energy.goodDataBeg; 
                case 'comdtyMetals' 
                    begDateStr = dataConfig.comdty.metals.goodDataBeg; 
                case 'comdtyAgs' 
                    begDateStr = dataConfig.comdty.ags.goodDataBeg; 
                case 'ratesShortRates'
                    begDateStr = dataConfig.rates.shortRates.goodDataBeg; 
            end % switch
            for n = 1:length(signal.subStrat(k).assetIDs)
                nn = find(strcmp(dataConfig.assetIDs,signal.subStrat(k).assetIDs{n}));
                if strcmp(sesCls(nn),'TK')
                    for t = 2:length(signal.subStrat(k).dates)
                        tt = find(signalTK.subStrat(k).dates<signal.subStrat(k).dates(t),1,'last');
                        if ~isempty(tt) && ~isnan(signalTK.subStrat(k).values(tt,n))
                           signal.subStrat(k).values(t,n) = signalTK.subStrat(k).values(tt,n);
                        end 
                    end % for t
                    % suppress signal values prior to good data dates:
                    begDate = datenum(begDateStr(1,n),'yyyymmdd'); % row that corresponds to TYO
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB> 
                elseif strcmp(sesCls(nn),'LN')
                    for t = 2:length(signal.subStrat(k).dates)
                        tt = find(signalLN.subStrat(k).dates<signal.subStrat(k).dates(t),1,'last');
                        if ~isempty(tt) && ~isnan(signalLN.subStrat(k).values(tt,n))
                           signal.subStrat(k).values(t,n) = signalLN.subStrat(k).values(tt,n);
                        end 
                    end % for t
                    % suppress signal values prior to good data dates:
                    begDate = datenum(begDateStr(2,n),'yyyymmdd'); % row that corresponds to NY
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB> 
                elseif strcmp(sesCls(nn),'NY')
                    begDate = datenum(begDateStr(3,n),'yyyymmdd'); % row that corresponds to NY
                    tIndx = find(signal.subStrat(k).dates < begDate);
                    signal.subStrat(k).values(tIndx,n) = 0;  %#ok<FNDSB>
                end % if
            end % for n
        end % for k

end % switch

end % fn
% Save factors to the factor library.
% Inputs:
% fctrRtns - factor returns in RAPC format (sinlge matrix in "values"),
% with header, ids, and bbgTicker fields.
% cfg - transformation definitions that were used to transform these factors
% outPath - path on disk to save to.
function saveFactors(fctrRtns, cfg, outPath)

    for i = 1:length(fctrRtns.header)
        fctrName = fctrRtns.header{i};
        ref.transform = cfg.getItem(fctrName);
        ref.identifiers.BBG_Ticker = fctrRtns.bbgTicker{i};
        ref.Id = fctrRtns.ids(i);
        toJsonFile(ref, fullfile(outPath, [fctrName '.json']));
        
        % trim trailing and leading NaNs
        fctr = fctrRtns.values(:,i);
        nonNanIdx = ~isnan(fctr);
        fromIdx = find(nonNanIdx, 1, 'first');
        toIdx = find(nonNanIdx, 1, 'last');
        trmDatenums = fctrRtns.dates(fromIdx:toIdx);
        trmDates = datetime(trmDatenums, 'ConvertFrom','datenum');
        trmDates.Format='MM/dd/yyyy';
        
        tbl = table(trmDates, fctr(fromIdx:toIdx) ...
            , 'VariableNames', ["date","return"]);
        writetable(tbl, fullfile(outPath, [fctrName '.csv']));
    end % for
    
    
end


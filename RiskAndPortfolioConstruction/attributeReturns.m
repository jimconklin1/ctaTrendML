function ret = attributeReturns(cfg, outStruct)
% Handle funds that were skipped by regression block
validIdx = sum(~isnan(outStruct.fExpos.refinedAlphaTS(:,outStruct.ghIndx)))>0;
hhIdx = outStruct.ghIndx(validIdx);

% fill in dim1_id..dim3_id with IDs of each dimension
db.dim1 = arrayfun(@(x) outStruct.ref.dim.instruments(x),outStruct.fundIdHeader(hhIdx));

factorIds = cellfun(@(x) outStruct.ref.factors.idMap(x), cfg.factors.flat);
factorDimIds = arrayfun(@(x) outStruct.ref.dim.instruments(x), factorIds);

factorOther = ["Total", "Risk Free Rate", "Timing", "Primary Alpha", "Refined Alpha"];
factorOtherIds = arrayfun(@(x) outStruct.ref.dim.factorClasses.map(x), factorOther);
db.dim2 = [factorOtherIds(1:3) factorDimIds factorOtherIds(4:5)];
attFactorStr = [factorOther(1:3) cfg.factors.flat factorOther(4:5)];

horizons = outStruct.ref.dim.time.months.keys();
db.dim3 = cellfun(@(x) outStruct.ref.dim.time.months(x), horizons);

db.values = NaN(length(db.dim1), length(db.dim2), length(db.dim3));
betasIdx = mapStrings(cfg.factors.flat, outStruct.fHeader);

% Some repeated calculations below (i.e. same operation more than
% once, like going over the same time periods for different horizons). 
% Was done to save space. Can be sped up if time becomes an issue.
for i = 1:length(horizons)
    numMonths = horizons{i};
    sz = size(outStruct.fExpos.totRtns);
    if numMonths > sz(1)
        numMonths = sz(1);
    end % if numMonths
    szRtns = size(outStruct.fExpos.totRtns);
    if numMonths > 0 
      startingPeriod = szRtns-numMonths+1;
    else
      startingPeriod = 1;
    end
    totRtns = outStruct.fExpos.totRtns(startingPeriod:end,hhIdx);
    totRtnMean = nanmean(totRtns);
    trIdx = ~isnan(totRtnMean);
    % The "return mask" has NaNs in cells with no returns, and 0 in cells 
    % with returns. This mask is used to replace beta returns and risk-free 
    % returns with NaNs for the periods in which a fund has no returns.
    rtnMask = totRtns - totRtns;
    
    db.values(:, 1, i) = totRtnMean;
    db.values(trIdx, 2, i) = nanmean(outStruct.rfr(startingPeriod:end) + rtnMask(:, trIdx));
    db.values(:, 3, i) = nanmean(outStruct.fExpos.timingRtnMatrix(startingPeriod:end,hhIdx));
    
    factorRtns = outStruct.factors(startingPeriod:end,betasIdx);
    betas = outStruct.fExpos.beta(hhIdx,betasIdx);
    for j = 1:length(trIdx)
        if trIdx(j) ~=0
            filteredFactorRtns = rtnMask(:, j) + factorRtns;
            db.values(j, 4:end-2, i) = nanmean(filteredFactorRtns .* betas(j,:));
        end % if
    end % for j
    
    db.values(:,end-1, i) = nanmean(outStruct.fExpos.primaryAlphaTS(startingPeriod:end,hhIdx));
    db.values(:,end, i)   = nanmean(outStruct.fExpos.refinedAlphaTS(startingPeriod:end,hhIdx));
end %for

% Annualize returns
db.values = db.values*12;

tbl = array2table(outStruct.style.funds(hhIdx)' ...
     ,'RowNames',outStruct.hHeader(hhIdx)', 'VariableNames', "Style"); 
 
for i = 1:length(horizons)
    h = horizons{i};
    if h<0
        moPrefix = 'F_';
    else
        moPrefix = "M" + sprintf('%02.f', horizons{i}) + "_";
    end
    hdrs = tblHeader(moPrefix + attFactorStr);
    for k = 1:length(hdrs)
        tbl = addvars(tbl, db.values(:,k,i), 'NewVariableNames',hdrs(k));
    end % for k
end % for i
 
ret.db = db;
ret.tbl = tbl;

end %function
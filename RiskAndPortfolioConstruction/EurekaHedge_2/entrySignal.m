clear;
%Process the "calc" structure from ehRoll_DP.m into an "entry signal".

fn_suff = "3mo";
outDataDir = fullfile(PubEqPath.localDataPath(), 'EH2');
fn = fullfile(outDataDir, "eh2_RollData_" + fn_suff +".mat");
if ~exist('calc','var')
    load(fn);
end 

% Load full table from the database
coreDb = Env.newPubEqCoreDb();
refCfg.fieldSet = 'full';
[refFull, ~] = coreDb.getEurekaHedgeRef('', refCfg);

% refRowNums will map our matrix-style structures to record numbers in the ML ref data table
refRowNums = mapIdField(refFull, 'FUND_ID', dbData.fundIdHeader);
inceptionDatesTbl = refFull(refRowNums, 'INCEPTION_DATE');
inceptionDates = smartDatenum(table2array(inceptionDatesTbl));
validInceptionDtIdx = inceptionDates>0;
everEnteredFilter = zeros(size(dbData.fundIdHeader));

sz = length(calc.dates);
entryTbls = cell(sz, 1);
totEntryFilter = nan(size(calc.pAlphaVol_12mo));
for i =1:sz
    % Apply hedge fund selection as of as of this date
    filterDtn = datenum(datestr(calc.dates(i)));

    %Row number of our period in "dbData" structure
    dataRowNum = find( dbData.equHFrtns.dates == filterDtn, 1, 'first');

    trackRecordMo = zeros(size(inceptionDates)); % track record in months
    trackRecordMo(validInceptionDtIdx) = round((filterDtn-inceptionDates(validInceptionDtIdx))/365.25*12);
    betas = calc.betas{1}(i,:); %MSCI beta for now, but can carry over other betas if needed

    betaFilter = and(betas < .2, betas >-999999);
    trackRecordFilter = trackRecordMo > 18;
    srFilter = calc.pAlphaSrp_12mo(i,:) > .75;
    pAlphaVolFilter = calc.pAlphaVol_12mo(i,:) > .05;
    aumFilter = dbData.aumTS(dataRowNum,:) >= minAum;

    entryFilter = and(and(and(and(betaFilter, trackRecordFilter), srFilter), pAlphaVolFilter), aumFilter);
    everEnteredFilter = or(everEnteredFilter, entryFilter);
    
    clear tbl;
    tbl.ID = dbData.fundIdHeader(entryFilter)';
    tbl.DT = repmat(calc.dates(i), length(tbl.ID), 1);
    tbl.DT.Format = 'yyyy-MM-dd';
    entryTbls{i} = struct2table(tbl);
    totEntryFilter(i, :) = entryFilter;
end

entryTbl = cat(1,entryTbls{:});
entryTbl.DT.Format = 'yyyy-MM-dd';
% Prepare data set for output
tblRef = refFull(refRowNums(everEnteredFilter)', :);
% at this point rows in tblOut are in the same order as in our filtered
% vectors

tblRef = addvars(tblRef, betas(everEnteredFilter)', 'NewVariableNames', 'Beta','Before','DATE_ADDED');
tblRef = addvars(tblRef, calc.pAlphaSrp_12mo(i, everEnteredFilter)', 'NewVariableNames', 'paSR_1y','Before','DATE_ADDED');
tblRef = addvars(tblRef, calc.pAlphaVol_12mo(i, everEnteredFilter)', 'NewVariableNames', 'paVol_1y','Before','DATE_ADDED');
tblRef = addvars(tblRef, dbData.aumTS(dataRowNum,everEnteredFilter)'/1000/1000, 'NewVariableNames', 'AUM','Before','DATE_ADDED');
tblRef = addvars(tblRef, trackRecordMo(everEnteredFilter)'/12, 'NewVariableNames', 'trackRecYrs','Before','DATE_ADDED');

writetable(tblRef, fullfile(pyOutDataDir, "eh_ref_"+fn_suff+".csv"));
% odler interface: not used anymore. (used to pivot it in Python)
writetable(entryTbl, fullfile(pyOutDataDir, "eh_entry_flat_" + fn_suff +".csv"));

py_fn = fullfile(pyOutDataDir, "eh2_entry_" + fn_suff +".mat");
save(py_fn, 'totEntryFilter');

function ret = mapIdField(tbl, fld, idList)
    ret = nan(size(idList));
    for i = 1:length(idList)
        id = idList(i);
        ret(i) =  find(tbl.(fld) ==id, true, 'first');
    end % for
end % connection

function out = smartDatenum(C)
    index = cellfun(@isempty, C);
    out(index) = 0;  % Empty dates are 0 in output
    out(~index) = datenum(C(~index));
end % smartDatenum



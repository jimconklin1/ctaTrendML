clear;
%Process the "calc" structure from ehRoll_DP.m into an "entry signal".

fn_suff = "1mo";
outDataDir = fullfile(PubEqPath.localDataPath(), 'EH2');
fn = fullfile(outDataDir, "eh2_RollData_" + fn_suff +".mat");
if ~exist('calc','var')
    load(fn);
end 

% Load full table from the database
coreDb = Env.newPubEqCoreDb();
refCfg.fieldSet = 'full';
[refFull, ~] = coreDb.getEurekaHedgeRef('', refCfg);

writetable(refFull, fullfile(pyOutDataDir, "eh_ref_full_2.csv"));

refRowNums = mapIdField(refFull, 'FUND_ID', dbData.fundIdHeader);

% Prepare data set for output
tblRef = refFull(refRowNums', :);
% at this point rows in tblOut are in the same order as in our filtered
% vectors

i = length(calc.dates);
%Row number of our period in "dbData" structure
filterDtn = datenum(datestr(calc.dates(i)));
dataRowNum = find( dbData.equHFrtns.dates == filterDtn, 1, 'first');

betas = calc.betas{1}(i,:); %MSCI beta for now, but can carry over other betas if needed

inceptionDatesTbl = refFull(refRowNums, 'INCEPTION_DATE');
inceptionDates = smartDatenum(table2array(inceptionDatesTbl));

trackRecordMo = zeros(size(inceptionDates)); % track record in months
validInceptionDtIdx = inceptionDates>0;
trackRecordMo(validInceptionDtIdx) = round((filterDtn-inceptionDates(validInceptionDtIdx))/365.25*12);

tblRef = addvars(tblRef, betas', 'NewVariableNames', 'Beta','Before','DATE_ADDED');
tblRef = addvars(tblRef, calc.pAlphaSrp_12mo(i, :)', 'NewVariableNames', 'paSR_1y','Before','DATE_ADDED');
tblRef = addvars(tblRef, calc.pAlphaVol_12mo(i, :)', 'NewVariableNames', 'paVol_1y','Before','DATE_ADDED');
tblRef = addvars(tblRef, dbData.aumTS(dataRowNum,:)'/1000/1000, 'NewVariableNames', 'AUM','Before','DATE_ADDED');
tblRef = addvars(tblRef, trackRecordMo'/12, 'NewVariableNames', 'trackRecYrs','Before','DATE_ADDED');

writetable(tblRef, fullfile(pyOutDataDir, "eh_ref_full.csv"));

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
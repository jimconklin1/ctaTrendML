%Process "calc" from ehRoll_DP.m into an "entry signal".

outDataDir = fullfile(PubEqPath.localDataPath(), 'EH'); 
fn = fullfile(outDataDir, "eh2_RollData.mat");
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

% Apply hedge fund selection as of as of this date
filterDtStr = datestr(eomdate(datetime("2021-03-01")), 'yyyy-mm-dd');
filterDtn = datenum(filterDtStr);
calcStartDt = eomdate(datetime(lastPeriodhStr));
calcStartDtm = datenum(calcStartDt);

calcStartRowNum = find( dbData.equHFrtns.dates == calcStartDtm, 1, 'first');
%Row number of our period in "dbData" structure
dataRowNum = find( dbData.equHFrtns.dates == filterDtn, 1, 'first');
%Row number of our period in "calc" structure
calcRowNum = find( calc.dates == calcStartDt, 1, 'first');

trackRecordMo = zeros(size(inceptionDates)); % track record in months
trackRecordMo(validInceptionDtIdx) = round((filterDtn-inceptionDates(validInceptionDtIdx))/365.25*12);
betas = calc.betas{1}(calcRowNum,:); %MSCI beta for now, but can carry over other betas if needed

betaFilter = and(betas < .2, betas >-999999);
trackRecordFilter = trackRecordMo > 18;
srFilter = calc.pAlphaSrp_12mo(calcRowNum,:) > .75;
pAlphaVolFilter = calc.pAlphaVol_12mo(calcRowNum,:) > .05;
aumFilter = dbData.aumTS(dataRowNum,:) >= minAum;

totFilter = and(and(and(and(betaFilter, trackRecordFilter), srFilter), pAlphaVolFilter), aumFilter);

% Prepare data set for output
tblOut = refFull(refRowNums(totFilter)', :);
% at this point rows in tblOut are in the same order as in our filtered
% vectors

tblOut = addvars(tblOut, betas(totFilter)', 'NewVariableNames', 'Beta','Before','DATE_ADDED');
tblOut = addvars(tblOut, calc.pAlphaSrp_12mo(calcRowNum, totFilter)', 'NewVariableNames', 'paSR_1y','Before','DATE_ADDED');
tblOut = addvars(tblOut, calc.pAlphaVol_12mo(calcRowNum, totFilter)', 'NewVariableNames', 'paVol_1y','Before','DATE_ADDED');
tblOut = addvars(tblOut, dbData.aumTS(dataRowNum,totFilter)'/1000/1000, 'NewVariableNames', 'AUM','Before','DATE_ADDED');
tblOut = addvars(tblOut, trackRecordMo(totFilter)'/12, 'NewVariableNames', 'trackRecYrs','Before','DATE_ADDED');

fn_out = fullfile(outDataDir, sprintf("eh_Filter_%s.csv",  datestr(datetime(filterDtStr), 'yyyy-mm')));

writetable(tblOut, fn_out);


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


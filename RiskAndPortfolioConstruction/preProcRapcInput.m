function outStruct = preProcRapcInput(inputData, cfg)

unpack(inputData);

if cfg.opt.processBenchmark
    % Add benchmark fund indices to the list of "funds" to process.
    idxHfBenchmark = mapStrings(cfg.headers.bmHeader, equFactorRtns.header); %#ok<NODEF>
    equHFrtns.values = [equHFrtns.values, equFactorRtns.values(:,idxHfBenchmark)]; %#ok<NODEF>
    equHFrtns.header = [equHFrtns.header, equFactorRtns.header(idxHfBenchmark)];
end % if benchmark

if cfg.opt.processMV
    sz = size(mktValue.values); %#ok<NODEF>
    mktValue.values = [mktValue.values, zeros(sz(1), length(idxHfBenchmark))];
    mktValue.header = [mktValue.header, equFactorRtns.header(idxHfBenchmark)];
end % if

if cfg.opt.autoTrimReturns
    maxDate = max([equFactorRtns.dates(1) equHFrtns.dates(1)]);
    startHFIdx = find(equHFrtns.dates == maxDate);
    startFIdx = find(equFactorRtns.dates == maxDate);
    
    if isempty(startHFIdx) || isempty(startFIdx)
        throw(MException('Data:Invalid' ...
            , 'Start Dates are not aligned between fund returns and factor returns.'));
    end % if
    
    equFactorRtns.dates = equFactorRtns.dates(startFIdx:end,:);
    equFactorRtns.values = equFactorRtns.values(startFIdx:end,:);
    
    equHFrtns.dates = equHFrtns.dates(startHFIdx:end,:);
    equHFrtns.values = equHFrtns.values(startHFIdx:end,:);

    minDate = min([equFactorRtns.dates(end) equHFrtns.dates(end)]);
    endHFIdx = find(equHFrtns.dates == minDate);
    endFIdx = find(equFactorRtns.dates == minDate);
    
    if isempty(endHFIdx) || isempty(endFIdx)
        throw(MException('Data:Invalid' ...
            , 'End Dates are not aligned between fund returns and factor returns.'));
    end % if
    
    equFactorRtns.dates = equFactorRtns.dates(1:endFIdx,:);
    equFactorRtns.values = equFactorRtns.values(1:endFIdx,:);
    
    equHFrtns.dates = equHFrtns.dates(1:endHFIdx,:);
    equHFrtns.values = equHFrtns.values(1:endHFIdx,:);
    
end % if cfg.opt.autoTrimReturns
if cfg.opt.processBenchmark
    style.funds = [style.funds, repmat({'-x-'}, 1,length(idxHfBenchmark))]; %#ok<NODEF>
end % if
    
hfStartDates = findFirstGood(equHFrtns.values,0,[]);  
equHFrtns.startDates = hfStartDates;

% HACKS: rendering market factors mutually orthogonal, and making them
%   excess returns:
mm = find(strcmp(cfg.headers.riskFree,equFactorRtns.header)); 
rfr = equFactorRtns.values(:,mm);  %#ok<FNDSB>

% Will not use factor library by default for backward-compatibility
if ~(isfield(cfg, 'useFactorLib') && cfg.useFactorLib)
    equFactorRtns.values(:,1) = equFactorRtns.values(:,1) - rfr; % render MSCI World ex-LIBOR
                                                                 % credit is already ex-LIBOR
    equFactorRtns.values(:,3) = equFactorRtns.values(:,3) - rfr; % render US Treasury Index ex-LIBOR
    equFactorRtns.values(:,4) = equFactorRtns.values(:,4) - rfr; % render US Agency MBS ex-LIBOR
    orth = orthogonalizeFactor(equFactorRtns.values,equFactorRtns.header,{'Markit IG CDX NA'},{'MSCIworld'},'InSample',false);
    temp = nanstd(equFactorRtns.values(:,3))/nanstd(orth); % scale vol on credit factor to be the same as US treasuries
    equFactorRtns.values(:,2) = temp*orth; 
    orth = orthogonalizeFactor(equFactorRtns.values,equFactorRtns.header,{'US Agency MBS'},{'BarcGlobalTreas'},'InSample',false);
    temp = nanstd(equFactorRtns.values(:,3))/nanstd(orth); % scale vol on MBS factor to be the same as US treasuries
    equFactorRtns.values(:,4) = temp*orth; 
end % if useFactorLib

% ad hoc what-if for Ric
%hackInd = mapStrings({'Voleon Investors','Voleon Inst', 'Winton Diversified', 'BW Pure Alpha 21 Vol'}, mktValue.header);
%zz1 = tempMktVal(hackInd);
%tempMktVal(hackInd) = [30000000, 90000000, 0,0];
%zStyle = mktValue.style(hackInd);
%zz2 = tempMktVal(hackInd);
%mktValue.values = zeros(size(mktValue.values));

if cfg.opt.processMV
    % Create aggregate return series for: bckstCrrntPrtfl; bckstEquityLS; bckstQuantMacro; bckstEventDr; bckstOpportunistic; 
    % HF returns are net of fees, but NOT excess returns:
    strIndx = mapStrings(mktValue.header,equHFrtns.header,false);
    tempMktVal = mktValue.values(end,strIndx);
    tempMktVal(isnan(tempMktVal))=0;

    numStyles = length(style.rptList);
    hfStyleWts = zeros(numStyles+1, 1); 
    hfStyleMktVal = zeros(numStyles+1, 1); 
    hfWts = [0,tempMktVal(1,2:end)]/sum(tempMktVal(1,2:end)); % note, in 1st column is the total AIG HF NAV
    
    % HACK: For aggregation purposes, we replace NaN returns with zeros. A NaN
    % likely means the fund didn't exist at the time. Ideally we would use
    % betas and alphas from individual funds, and just aggregate them at the
    % end.
    paddedRtns = equHFrtns.values;
    paddedRtns(isnan(paddedRtns)) = 0;
    % TODO: (posible bug) Ideally need a NaN-ignoring matrix multiplication
    % but only when corresponding weights are zero.
    % Next best thing (another hack) would be to replace zeroes with NaNs 
    % after multiplication.
    szRtns = size(equHFrtns.values);
    tr = zeros(szRtns(1), numStyles+1);
    tr(:,1) = paddedRtns*hfWts'; 
    hfStyleWts(1) = 1;
    hfStyleMktVal(1) = tempMktVal(1,1);
    
    szHfWts = size(hfWts);

    for i = 1:length(style.rptList)
        rptStr = style.rptList(i);
        if isKey(style.rptMap, rptStr)
            % Some fund styles are merged at the moment, e.g. Global Macro
            % and Quant
            tmpIndx = []; 
            for k = string(style.rptMap(rptStr))
                tmpIndx = [tmpIndx find(strcmp(style.funds, k))];  %#ok<AGROW>
            end % for k
        else
          tmpIndx = find(strcmp(style.funds, rptStr)); 
        end %if

        totWt = sum(hfWts(1,tmpIndx));
        wts = zeros(szHfWts);
        wts(1,tmpIndx) = hfWts(1,tmpIndx)/totWt;

        tr(:,i+1) = paddedRtns*wts'; 
        hfStyleWts(i+1) = totWt; 
        hfStyleMktVal(i+1) = sum(tempMktVal(1,tmpIndx));
    end % for i
    clear rptStr tmpIndx totWt wts
    
    % hfStyleWts array elements correspond to: {'total','LSequity','macro',eventDriven','opportunistic'}

    hHeader = [equHFrtns.header(1,1),{'aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},equHFrtns.header(1,2:end)]; 
    rtns = [equHFrtns.values(:,1), tr, equHFrtns.values(:,2:end)]; 
    style.funds(6:end+5) = style.funds;
    style.funds(1:5)= {'Aggregate'};    
else     
    hHeader = equHFrtns.header; 
    rtns = equHFrtns.values; 
end % cfg.opt.processMV



% re-name factor variables, compute some params:
factors = equFactorRtns.values; 
fHeader = equFactorRtns.header;
volsHF = sqrt(12)*std(rtns)';
volsFact = sqrt(12)*std(factors)';

if cfg.opt.processMV
    t0 = find(equHFrtns.dates>=mktValue.dates(1),1,'first'); 
    tt0 = find(equFactorRtns.dates>=mktValue.dates(1),1,'first'); 
    
    outStruct.mktValue = mktValue;
    outStruct.hfStyleMktVal = hfStyleMktVal;
    outStruct.hfStyleWts = hfStyleWts;
else
    t0 = 1;
    tt0 = 1;
end % MV    

if cfg.opt.processStrategy
    outStruct.style = style;
end % if cfg.opt.processStrategy

rtns = rtns(t0:end,:); 
rfr = rfr(t0:end,:); 
factors = factors(tt0:end,:); 
clear mm;

outStruct.rtns = rtns;
outStruct.factors = factors;
outStruct.rfr = rfr;
outStruct.hHeader = hHeader;
outStruct.fHeader = fHeader;
outStruct.volsHF = volsHF;
outStruct.volsFact = volsFact;
outStruct.equHFrtns = equHFrtns;
outStruct.dates = equHFrtns.dates(t0:end,:);  
outStruct.t0 = t0;
outStruct.tt0 = tt0;
outStruct.ref = ref;

if isfield(inputData, 'futEquHFrtns')
    outStruct.futEquHFrtns = inputData.futEquHFrtns;
end % if

end 
function outStruct = fetchRAPCdataStructures(dataDir,dataSetName)

load(fullfile([dataDir,'\',dataSetName{1,1}])); %#ok<LOAD> % monthlyEquityARPandHFdata201812est.mat; varnames: equHFrtns equFactorRtns mktValue
% save H:\research\DATA\hfFactorModel\monthlyEquityARPandHFdata201812.mat equHFrtns equFactorRtns mktValue;
% save 'M:\Manager of Managers\Hedge\quantDev\DATA\RAPC\monthlyEquityARPandHFdata201902.mat' equHFrtns equFactorRtns mktValue;
hfStartDates = findFirstGood(equHFrtns.values,0,[]);  %#ok<NODEF>
equHFrtns.startDates = hfStartDates;
% dbConn = getOracleDb(); 

% queryStr = ['select * from data_table_directory' ...
%             ' where table_display_name_key = ''MODEL_FACTOR_' model '_1'''];
% tableName = readDbQuery(dbConn, queryStr);

% % Load the list of funds and factors (mixed; factors are 7 last columns)
% fundDS = select(dbConn,'SELECT inst_id, inst_name from arp.hf_funds_factors_for_rtn_v');
% 
% % Map database fund ID to sequence number for filling out the returns matrix
% InvID_to_Idx = containers.Map(fundDS.INST_ID, 1:length(fundDS.INST_ID));
% 
% % this is what used to be the "header" in the original data set
% header = fundDS.INST_NAME.';
% 
% monthTo = '2018-08';
% retSQLStr = ['select * from table(arp.hf_return.hf_monthly_return(date ''' ...
%              , monthTo, '-01' , '''))' ];
% 
% datesDS = select(dbConn,'SELECT dt from table(arp.hf_return.monthend_dates(date ''' , monthTo, '-01''))');
% 
% % this is what used to be "dates" in the original set
% dates = datenum(datesDS.DT);
% 
% retDS = select(dbConn, retSQLStr);
% 
% rtns = zeros(length(dates), length(fundDS.INST_ID));
% 
% % fill in "rtns" matrix from the Oracle data set.
% dbRecNum = 1;
% colNum = 1;
% oldInstId = retDS.INST_ID(1)-10000;
% for recNum =1 : length(retDS.INST_ID)
%     instId = retDS.INST_ID(recNum);
%     if (instId ~= oldInstId)
%         colNum = InvID_to_Idx(instId);
%         lineNum = 1;
%         oldInstId = instId;
%     end
%     
%     rtns(lineNum, colNum) = retDS.RTN_FRAC(recNum);
%     
%     lineNum = lineNum+1;
% end

% By now we have "header", "dates", and "rtns" loaded.
% TODO: Dmitriy needs to replace NaNs with zeroes for compatibility with
% existing script (although NaNs are arguably better because we won't have
% "magic numbers" in our code, and could handle legitimate zero returns correctly.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      database section end     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %------------------
% 
% addpath (fullfile(root_dir, 'GIT/matlabUtils/_data'));
% cd (fullfile(root_dir, 'GIT/hfFactorModel')); 
% dataDir = fullfile(root_dir, 'DATA/hfFactorModel');
% load(fullfile(dataDir,'monthlyEquityARPandHFdata.mat')); % varname: equHFrtns


% HACKS: rendering market factors mutually orthogonal, and making them
%   excess returns:
mm = find(strcmp({'USD_LIBOR_3M'},equFactorRtns.header)); %#ok<NODEF>
rfr = equFactorRtns.values(:,mm);  %#ok<FNDSB>
equFactorRtns.values(:,1) = equFactorRtns.values(:,1) - rfr;
equFactorRtns.values(:,3) = equFactorRtns.values(:,3) - rfr;
temp = 3.5*(equFactorRtns.values(:,2)-.09125*equFactorRtns.values(:,1)); 
equFactorRtns.values(:,2) = temp; 
temp = 1.15*(equFactorRtns.values(:,4)-.225*equFactorRtns.values(:,3));
equFactorRtns.values(:,4) = temp; 

% Create aggregate return series for: bckstCrrntPrtfl; bckstEquityLS; bckstQuantMacro; bckstEventDr; bckstOpportunistic; 
% HF returns are net of fees, but NOT excess returns:
tmpRtns = equHFrtns.values; 
strIndx = mapStrings(mktValue.header,equHFrtns.header,false);
tempMktVal = mktValue.values(end,strIndx);
hfStyleWts = zeros(5,1); 
hfStyleMktVal = zeros(5,1); 
hfWts = [0,tempMktVal(1,2:end)]/sum(tempMktVal(1,2:end)); % note, in 1st column is the total AIG HF NAV
equityLSwts = zeros(size(hfWts));
macroWts = zeros(size(hfWts));
eventDrivenWts = zeros(size(hfWts));
opportunisticWts = zeros(size(hfWts));
% hfStyleWts array elements correspond to: {'total','LSequity','macro',eventDriven','opportunistic'}
tmpIndx = find(strcmp(mktValue.style,{'L-S_equity'})); 
hfStyleWts(1) = 1;
hfStyleMktVal(1) = tempMktVal(1,1);
hfStyleWts(2) = sum(hfWts(1,tmpIndx)); 
hfStyleMktVal(2) = sum(tempMktVal(1,tmpIndx));
equityLSwts(1,tmpIndx) = hfWts(1,tmpIndx)/hfStyleWts(2); 
tmpIndx = find(strcmp(mktValue.style,{'GlobalMacro'})); 
hfStyleWts(3) = sum(hfWts(1,tmpIndx)); 
hfStyleMktVal(3) = sum(tempMktVal(1,tmpIndx));
macroWts(1,tmpIndx) = hfWts(1,tmpIndx)/hfStyleWts(3); 
tmpIndx = find(strcmp(mktValue.style,{'EventDriven'})); 
hfStyleWts(4) = sum(hfWts(1,tmpIndx)); 
hfStyleMktVal(4) = sum(tempMktVal(1,tmpIndx));
eventDrivenWts(1,tmpIndx) = hfWts(1,tmpIndx)/hfStyleWts(4); 
tmpIndx = find(strcmp(mktValue.style,{'Opportunistic'})); 
hfStyleWts(5) = sum(hfWts(1,tmpIndx)); 
hfStyleMktVal(5) = sum(tempMktVal(1,tmpIndx));
opportunisticWts(1,tmpIndx) = hfWts(1,tmpIndx)/hfStyleWts(5); % the relative weights of each HF style in the portfolio as a whole
tr = tmpRtns*hfWts'; 
tr(:,2) = tmpRtns*equityLSwts'; 
tr(:,3) = tmpRtns*macroWts'; 
tr(:,4) = tmpRtns*eventDrivenWts'; 
tr(:,5) = tmpRtns*opportunisticWts'; 
hHeader = [equHFrtns.header(1,1),{'aigHFbkcst','lseqHFbkcst','gmcroHFbkcst','evntDrHFbkcst','opportunHFbkcst'},equHFrtns.header(1,2:end)]; 
rtns = [tmpRtns(:,1), tr, tmpRtns(:,2:end)]; 

% re-name factor variables, compute some params:
factors = equFactorRtns.values; 
fHeader = equFactorRtns.header;
volsHF = sqrt(12)*std(rtns)';
volsFact = sqrt(12)*std(factors)';
%sigma = cov(equHFrtns.values);
%rho = corrcoef(equHFrtns.values);
t0 = find(equHFrtns.dates>=mktValue.dates(1),1,'first'); 
rtnsLong = rtns;
rfrLong = rfr;
rtns = rtns(t0:end,:); 
rfr = rfr(t0:end,:); 
tt0 = find(equFactorRtns.dates>=mktValue.dates(1),1,'first'); 
factorsLong = factors;
factors = factors(tt0:end,:); 
clear mm;

outStruct.rtns = rtns;
outStruct.factors = factors;
outStruct.rfr = rfr;
outStruct.rtnsLong = rtnsLong;
outStruct.rfrLong = rfrLong;
outStruct.factorsLong = factorsLong;
outStruct.hHeader = hHeader;
outStruct.fHeader = fHeader;
outStruct.volsHF = volsHF;
outStruct.volsFact = volsFact;
outStruct.equHFrtns = equHFrtns;
outStruct.equFactorRtns = equFactorRtns;
outStruct.mktValue = mktValue;
outStruct.hfStyleMktVal = hfStyleMktVal;
outStruct.hfStyleWts = hfStyleWts;
outStruct.t0 = t0;
outStruct.tt0 = tt0;
end 
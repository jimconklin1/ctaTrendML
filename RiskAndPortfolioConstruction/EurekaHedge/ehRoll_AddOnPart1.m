%Add on script for Part 1 of Assignment

outDataDir = fullfile(PubEqPath.localDataPath(), 'EH'); 
fn = fullfile(outDataDir, "ehRollData.mat");
if ~exist('calc','var')
    load(fn);
end 

% compute quarterly returns:
t0 = find(dbData.equHFrtns.dates >= dates(1),1);
t0 = t0-2; % go to the beginning of quarter, as dates is end-of-quarters
temp = dbData.equHFrtns.values(t0:end,:);
tempCum = calcCum(temp,1);
indx = 3:3:size(temp,1);
if indx(end) < size(temp,1)
   indx = [indx,size(temp,1)];
end 
tempCum = tempCum(indx,:);
expon = indx(end)-indx(end-1);
xx1 = tempCum(1,:)-1;
xx2 = tempCum(2:end-1,:)./tempCum(1:end-2,:)-1;
xx3 = (tempCum(end,:)./tempCum(end-1,:)).^expon -1;
calc.hfTtlRtn = [xx1;xx2;xx3];

cfg.AUMfloor = 100000000;
cfg.AUMgrowthCeiling = 3000000000;
cfg.betaCeiling = 0.25;
cfg.betaFloor = -0.5;
cfg.alphaSRthrehold = 0.75;
cfg.AUMgrthCeil3yr = 2;
AUM_3yrGrth=calc.aum(aumOffset+1:end,:)./ calc.aum(1:end-aumOffset,:)-1; 

AUM=calc.aum(aumOffset+1:end,:); %Create new AUM2 variable 
MSCIBetaFilter = calc.beta<cfg.betaCeiling & calc.beta>cfg.betaFloor & calc.beta>-999999999; %Added in additional beta constraint to filter out funds that have a RAPC assigned beta of -999999999. Should this be absolute value of MSCI beta? Or should all negative betas be included as it currently is?
AUMFilter = AUM>cfg.AUMfloor;  %Starts at row 13 because of the additional rows added to calc.aum
AlphaSrp36Filter = calc.pAlphaSrp_36mo > cfg.alphaSRthrehold;
AUM_GrowthFilter = (AUM_3yrGrth < cfg.AUMgrthCeil3yr) | AUM<=cfg.AUMgrowthCeiling;
CombinedFilter = MSCIBetaFilter & AlphaSrp36Filter & AUMFilter & AUM_GrowthFilter; 

sz = size(CombinedFilter);

varForJim = {};
varDates = {};
varUniverse = {};
for i = 1: sz(1)
    FinalOutput(1,:) = calc.beta(i,:);
    FinalOutput(2,:) = calc.aum(aumOffset+i,:);
    FinalOutput(3,:) = AUM_GrowthFilter(i,:);
    FinalOutput(4,:) = calc.pAlphaSrp_36mo(i,:);
    tFinalOutput = array2table(FinalOutput', 'VariableNames', {'Beta', 'AUM', 'AUM_Increase', 'pAlphaSrp_3yr'});
    tFinalOutput = addvars(tFinalOutput, dbData.geoMandate.funds', 'NewVariableNames', 'GeoMandate','Before','Beta');
    tFinalOutput = addvars(tFinalOutput, dbData.style.funds', 'NewVariableNames', 'FundStyle','Before','GeoMandate');
    tFinalOutput = addvars(tFinalOutput, dbData.equHFrtns.header', 'NewVariableNames', 'FundName','Before','FundStyle');
    tFinalOutput = addvars(tFinalOutput, dbData.fundIdHeader','NewVariableNames','FundID','Before','FundName');
   
    tFilteredOutput = tFinalOutput(CombinedFilter(i,:), :);

    filename=sprintf('File_%d.csv',i); %File 1 is Q1 2009 and File 46 is Q2 2020
    writetable(tFilteredOutput, filename);
    
    %Combined Variable
    %varForJim{i} = tFilteredOutput; %Original
    varForJim{1,i+1}=dates_formatted(i,:);
    varForJim{2,i+1} = tFilteredOutput; 
    varForJim{1,1} = "Dates";
    varForJim{2,1} = "Universe";
    
    %Indivudal Variables
    varDates{i}=dates_formatted(i,:);
    varUniverse{i}=tFilteredOutput;
end %i


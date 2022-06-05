%clear;
PubEqPath.addLibPath('_util','_data','_platform','_database','_file','_date');
inDataDir = fullfile(PubEqPath.localDataPath(), 'EH'); 
load(fullfile(inDataDir, "ehRollData.mat"));


rDim = size(calc.alphaRtn_lastMo);
rtnCnt = sum(~isnan(calc.alphaRtn_lastMo),2);

tableSlices = cell(1,rDim(1)-1);
for i = 1:rDim(1)-1
    z.srcI = t0+i-1;
    z.retFltr = ~isnan(calc.alphaRtn_lastMo(i, :)) ...
            & ~isnan(dbData.aumTS(z.srcI, :)) & (dbData.aumTS(z.srcI, :)>0);
    vec.style = dbData.style.funds(z.retFltr);
    vec.geoMandate = dbData.geoMandate.funds(z.retFltr);
    z.aum = dbData.aumTS(z.srcI, :);
    vec.Ids = "i" + string(dbData.fundIdHeader(z.retFltr));
    z.dt = dbData.equHFrtns.dates(z.srcI);
    z.dtStr = "m" + datestr(z.dt, "yyyymm");
    vec.mo = repmat(z.dtStr, 1, sum(z.retFltr));
    vec.logAum = log(z.aum(:,z.retFltr));
    vec.sr_1r_12v = calc.alphaRtn_lastMo(i, z.retFltr) ./ calc.alphaVol_12mo(i, z.retFltr);
    vec.sr_3r_12v = calc.alphaRtn_3mo(i, z.retFltr) ./ calc.alphaVol_12mo(i, z.retFltr);
    vec.sr_tot = calc.alphaRtn_Full(i, z.retFltr) ./ calc.alphaVol_Full(i, z.retFltr);
    
    vec.NextSr_1r_12v = calc.alphaRtn_lastMo(i+1, z.retFltr) ./ calc.alphaVol_12mo(i+1, z.retFltr);
    
    z.tblSlice = table(vec.mo', vec.Ids', vec.style', vec.geoMandate' ...
        , vec.logAum', vec.sr_1r_12v', vec.sr_3r_12v' ...
        , vec.sr_tot', vec.NextSr_1r_12v');
    z.tblSlice.Properties.VariableNames = [ "YMo", "FundId" ...
        , "Style", "GeoMand", "LogAUM", "SR_1r_12v", "SR_6r_12v", "SR_Tot", "NextSR"];
    tableSlices{i} = z.tblSlice;
end %for
clear i z vec; % clear variables "local" to the inside of the loop

tbl = vertcat(tableSlices{:});
clear tableSlices;

toDel = isnan(tbl.NextSR) | isnan(tbl.SR_1r_12v) | isnan(tbl.SR_6r_12v) ...
    | isnan(tbl.SR_Tot) | isnan(tbl.LogAUM);
tbl = tbl(~toDel,:);

%lm = fitlm(tbl, "NextSR ~ YMo + FundId + LogAUM + SR_1r_12v + SR_6r_12v + SR_Tot");
%lm = fitlm(tbl, "NextSR ~ YMo + FundId + LogAUM + SR_1r_12v + SR_6r_12v + SR_Tot");
lm = fitlm(tbl, "NextSR ~ YMo + Style +GeoMand + LogAUM + SR_1r_12v + SR_6r_12v + SR_Tot");

%{
i = 1;
lag = 3;
statCfg = {'tstat','fstat','rsquare'}; ..., 'r'


rgr.Y = calc.alphaSrp_3mo(i + lag, :)';
rgr.X = [calc.alphaSrp_3mo(i, :)' calc.alphaRtn_lastMo(i, :)' ...
      calc.alphaRtn_3mo(i, :)' calc.alphaSrp_Full(i, :)'];
  
stats = regstats(rgr.Y, rgr.X,'linear',statCfg);
res.rollReg(i) = stats.tstat.beta
%}
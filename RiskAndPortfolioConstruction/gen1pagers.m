function rc = gen1pagers(outStruct,hIndx,EPerfTable,outDir)
unpack(outStruct);
[~,~] = mkdir(outDir);

rtns2 = rtns(:,hIndx); %#ok<IDISVAR,NODEF>
T = length(rtns);
table2 = EPerfTable(:,{'B_msciWrld','B_usCDX','B_us10y','B_usMtg','E_SR_tot','corr2y'}); 
tmpTbl = EPerfTable(:,{'E_SR_refinedAlpha','E_SR_ARP','E_vol_refinedAlpha','E_vol_ARP','B_msciWrld','B_usCDX','B_us10y','B_usMtg'});
alphaScore = sign(tmpTbl.E_SR_refinedAlpha).*(abs(tmpTbl.E_SR_refinedAlpha).^1.35).*(tmpTbl.E_vol_refinedAlpha.^0.65);
arpScore = sign(tmpTbl.E_SR_ARP).*(abs(tmpTbl.E_SR_ARP).^1.35).*(tmpTbl.E_vol_ARP.^0.65);
betaPen = -1*(0.7*max(tmpTbl.B_msciWrld,0).^2+0.1*max(tmpTbl.B_usCDX,0).^2+0.1*max(tmpTbl.B_us10y,0).^2+0.1*max(tmpTbl.B_usMtg,0).^2);
table2.alphaRating = 0.009+alphaScore+0.33*arpScore+0.2*betaPen;

thirdMom = mean(rtns2.^3)';
fourthMom = mean(rtns2.^4)';
s = nanstd(rtns2)';
g1 = (thirdMom./(s.^3)); 
table2.skew = (sqrt(T*(T-1))/(T-2))*g1; % pearson fischer
table2.kurtosis = (fourthMom./(s.^4)); 
for n = 1:height(EPerfTable)
    fileName = table2.Properties.RowNames{n};
    fileName = strrep(fileName, '/', '');
    fileName = strrep(fileName, '\', '');
    writetable(table2(n,:),fullfile(outDir,[fileName,'.csv']));
end
writetable(table2,fullfile(outDir,'one-pagerResultsAllHFs.csv'));
% Loading_MSCI_W
% Loading_US CDX
% Loading_MBS
% Loading_US 10y
% Diversifying Alpha
% Expected Sharpe
% Combined Rank {Metric}
% Skew (realized)
% Kurtosis (realized)
% Vol Implied Max Position Size

rc = true;
end
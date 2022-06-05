load('M:\Manager of Managers\Public Equity\hedgeFundPortfolio\3 - Prospects\1 - ActiveAnalysis\delphia_quant\returns.mat')
X = table2array(tot_ret(:,2:6)); 
xHeader = tot_ret.Properties.VariableNames(2:6); 
y = table2array(tot_ret(:,7)); 
rfr = X(:,end)/(100*252); 
yHeader = tot_ret.Properties.VariableNames(7); 
dates = table2array(tot_ret(:,1)); 

XX = X(:,1:4); 
statCfg = {'tstat','fstat','rsquare'}; 
i1 = find(strcmp(xHeader,{'MSCIworld'}));
i2 = find(strcmp(xHeader,{'MarkitIGCDXNA'}));
i3 = find(strcmp(xHeader,{'BarcGlobalTreas'}));
i4 = find(strcmp(xHeader,{'USAgencyMBS'}));
stats = regstats(X(:,i2),X(:,i1),'linear',[statCfg,{'r'}]);
XX(:,i2) = 10*stats.r;
stats = regstats(X(:,i4),X(:,i3),'linear',[statCfg,{'r'}]);
XX(:,i4) = 3*stats.r;

stats = regstats(y,XX,'linear',[statCfg,{'r'}]);

% SR alpha: 
alpha = stats.r+ stats.tstat.beta(1);
SR = sqrt(252)*mean(alpha-rfr)/std(alpha);

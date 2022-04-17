function [rowLabel, xx] = displayPnLstatTable(portSim)
N = length(portSim.dates);
oosN = sum(portSim.dates>=datenum('30-apr-2016'));
tt1 = find((portSim.dates>=datenum('30-apr-2016')),1,'first'); 
insN = N -oosN;
rowLabel = {'Sample size'};
xx = [insN,oosN,N]; % Sample size
rowLabel = [rowLabel; {'% of days positive returns'}];
xx = [xx; 100*[sum(portSim.totPnl(1:tt1,:)>=0)/insN,sum(portSim.totPnl(tt1+1:end,:)>=0)/oosN,sum(portSim.totPnl>=0)/N]]; % # pos days
rowLabel = [rowLabel; {'Maximum daily return'}];
xx = [xx; [max(portSim.totPnl(1:tt1,:)),max(portSim.totPnl(tt1+1:end,:)),max(portSim.totPnl)]]; % max rtn
rowLabel = [rowLabel; {'Minimum daily return'}];
xx = [xx; [min(portSim.totPnl(1:tt1,:)),min(portSim.totPnl(tt1+1:end,:)),min(portSim.totPnl)]]; % min rtn
rowLabel = [rowLabel; {'Mean daily return, %'}];
xx = [xx; 100*[mean(portSim.totPnl(1:tt1,:)),mean(portSim.totPnl(tt1+1:end,:)),mean(portSim.totPnl)]]; % mean rtn
rowLabel = [rowLabel; {'Median daily return, %'}];
xx = [xx; 100*[median(portSim.totPnl(1:tt1,:)),median(portSim.totPnl(tt1+1:end,:)),median(portSim.totPnl)]]; % median rtn
indxPosIS = portSim.totPnl(1:tt1,:)>=0;
indxPosOS = portSim.totPnl(tt1+1:end,:)>=0;
indxPos = portSim.totPnl>=0;
indxNegIS = portSim.totPnl(1:tt1,:)<0;
indxNegOS = portSim.totPnl(tt1+1:end,:)<0;
indxNeg = portSim.totPnl<0;
rowLabel = [rowLabel; {'Avg positive daily rtn'}];
xx = [xx; [mean(portSim.totPnl(indxPosIS,:)),mean(portSim.totPnl(indxPosOS,:)),mean(portSim.totPnl(indxPos,:))]]; % mean Pos rtn
rowLabel = [rowLabel; {'Avg negative daily rtn'}];
xx = [xx; [mean(portSim.totPnl(indxNegIS,:)),mean(portSim.totPnl(indxNegOS,:)),mean(portSim.totPnl(indxNeg,:))]]; % mean Neg rtn
rowLabel = [rowLabel; {'Sharpe Ratio'}];
xx = [xx; [16*mean(portSim.totPnl(1:tt1,:))./std(portSim.totPnl(1:tt1,:)),...
           16*mean(portSim.totPnl(tt1+1:end,:))./std(portSim.totPnl(tt1+1:end,:)),...
           16*mean(portSim.totPnl)./std(portSim.totPnl)]]; % Sharpe ratio
negPnL = portSim.totPnl; 
negPnL(indxPos,:) = 0;
rowLabel = [rowLabel; {'Sortino Ratio'}];
xx = [xx; [16*mean(portSim.totPnl(1:tt1,:))./std(negPnL(1:tt1,:)),...
           16*mean(portSim.totPnl(tt1+1:end,:))./std(negPnL(tt1+1:end,:)),...
           16*mean(portSim.totPnl)./std(negPnL)]]; % Sortino ratio
xxC = calcCum(portSim.totPnl,1);
xxM = xxC;
for t = 2:length(xxM)
   xxM(t,:) = max([xxM(t,:); xxM(t-1,:)]); 
end 
xxDD = (xxC-xxM)./xxM;
rowLabel = [rowLabel; {'Max drawdown, %'}];
xx = [xx; 100*[min(xxDD(1:tt1,:)), min(xxDD(tt1:end,:)), min(xxDD)]]; % max DD

temp = sort(portSim.totPnl(1:tt1,:),'ascend'); 
trig = temp(1);
k = 1;
while trig<0 && k < length(temp)
   k=k+1;
   trig = trig + temp(k);
end
busNumIS = length(temp)-k;

temp = sort(portSim.totPnl(tt1+1:end,:),'ascend'); 
trig = temp(1);
k = 1;
while trig<0 && k < length(temp)
   k=k+1;
   trig = trig + temp(k);
end
busNumOS = length(temp)-k;

temp = sort(portSim.totPnl,'ascend'); 
trig = temp(1);
k = 1;
while trig<0 && k < length(temp)
   k=k+1;
   trig = trig + temp(k);
end
busNum = length(temp)-k;
rowLabel = [rowLabel; {'Bus days per year'}];
xx = [xx; [260*busNumIS/insN, 260*busNumOS/oosN, 260*busNum/N]]; % # bus days per year to drive SR to 0
rowLabel = [rowLabel; {'Bus days, %'}];
xx = [xx; 100*[busNumIS/insN, busNumOS/oosN, busNum/N]];% # bus days to drive SR to 0, as % of all days
rowLabel = [rowLabel; {'TransCosts as % of PnL'}];
tcINS = abs(sum(sum(portSim.tc(1:tt1,:))));
pnlINS = (sum(sum(portSim.totPnl(1:tt1,:))));
tcOOS = abs(sum(sum(portSim.tc(tt1+1:end,:))));
pnlOOS = (sum(sum(portSim.totPnl(tt1+1:end,:))));
tc = abs(sum(sum(portSim.tc)));
pnl = (sum(sum(portSim.totPnl)));
xx = [xx; 100*[tcINS/pnlINS, tcOOS/pnlOOS, tc/pnl]];% # bus days to drive SR to 0, as % of all days
end % fn
% tt1 = find(portSim.dates<=datenum('31-dec-2004'));
% tt2 = find(portSim.dates<=datenum('31-dec-2007')&portSim.dates>datenum('31-dec-2004'));
% tt3 = find(portSim.dates<=datenum('31-dec-2010')&portSim.dates>datenum('31-dec-2007'));
% tt4 = find(portSim.dates<=datenum('31-dec-2012')&portSim.dates>datenum('31-dec-2010'));
% tt5 = find(portSim.dates<=datenum('31-dec-2014')&portSim.dates>datenum('31-dec-2012'));
% tt6 = find(portSim.dates>datenum('31-dec-2014'));
% yy1 = [260*nanmean(xx(tt1,:)); 16*nanmean(xx(tt1,:))./nanstd(xx(tt1,:)); min(xxDD(tt1,:)); zz];
% zz1 = [sum(sum(abs(portSim.equTrades(tt1,:))))*(260/length(tt1)),sum(sum(abs(portSim.ratesTrades(tt1,:))))*(260/length(tt1)),sum(sum(abs(portSim.cmdTrades(tt1,:))))*(260/length(tt1)),sum(sum(abs(portSim.ccyTrades(tt1,:))))*(260/length(tt1))]; zz1 = [sum(zz1),zz1];
% zz2 = [sum(sum(abs(portSim.equTrades(tt2,:))))*(260/length(tt2)),sum(sum(abs(portSim.ratesTrades(tt2,:))))*(260/length(tt2)),sum(sum(abs(portSim.cmdTrades(tt2,:))))*(260/length(tt2)),sum(sum(abs(portSim.ccyTrades(tt2,:))))*(260/length(tt2))]; zz2 = [sum(zz2),zz2];
% yy2 = [260*nanmean(xx(tt2,:)); 16*nanmean(xx(tt2,:))./nanstd(xx(tt2,:)); min(xxDD(tt2,:)); zz2];
% zz3 = [sum(sum(abs(portSim.equTrades(tt3,:))))*(260/length(tt3)),sum(sum(abs(portSim.ratesTrades(tt3,:))))*(260/length(tt3)),sum(sum(abs(portSim.cmdTrades(tt3,:))))*(260/length(tt3)),sum(sum(abs(portSim.ccyTrades(tt3,:))))*(260/length(tt3))]; zz3 = [sum(zz3),zz3];
% yy3 = [260*nanmean(xx(tt3,:)); 16*nanmean(xx(tt3,:))./nanstd(xx(tt3,:)); min(xxDD(tt3,:)); zz3];
% zz4 = [sum(sum(abs(portSim.equTrades(tt4,:))))*(260/length(tt4)),sum(sum(abs(portSim.ratesTrades(tt4,:))))*(260/length(tt4)),sum(sum(abs(portSim.cmdTrades(tt4,:))))*(260/length(tt4)),sum(sum(abs(portSim.ccyTrades(tt4,:))))*(260/length(tt4))]; zz4 = [sum(zz4),zz4];
% yy4 = [260*nanmean(xx(tt4,:)); 16*nanmean(xx(tt4,:))./nanstd(xx(tt4,:)); min(xxDD(tt4,:)); zz4];
% zz5 = [sum(sum(abs(portSim.equTrades(tt5,:))))*(260/length(tt5)),sum(sum(abs(portSim.ratesTrades(tt5,:))))*(260/length(tt5)),sum(sum(abs(portSim.cmdTrades(tt5,:))))*(260/length(tt5)),sum(sum(abs(portSim.ccyTrades(tt5,:))))*(260/length(tt5))]; zz5 = [sum(zz5),zz5];
% yy5 = [260*nanmean(xx(tt5,:)); 16*nanmean(xx(tt5,:))./nanstd(xx(tt5,:)); min(xxDD(tt5,:)); zz5];
% zz = [sum(sum(abs(portSim.equTrades(:,:))))*(260/length(xx)),sum(sum(abs(portSim.ratesTrades(:,:))))*(260/length(xx)),sum(sum(abs(portSim.cmdTrades(:,:))))*(260/length(xx)),sum(sum(abs(portSim.ccyTrades(:,:))))*(260/length(xx))]; zz = [sum(zz),zz];
% yy = [260*nanmean(xx(:,:)); 16*nanmean(xx(:,:))./nanstd(xx(:,:)); min(xxDD(:,:)); zz];
% zz6 = [sum(sum(abs(portSim.equTrades(tt6,:))))*(260/length(tt6)),sum(sum(abs(portSim.ratesTrades(tt6,:))))*(260/length(tt6)),sum(sum(abs(portSim.cmdTrades(tt6,:))))*(260/length(tt6)),sum(sum(abs(portSim.ccyTrades(tt6,:))))*(260/length(tt6))]; zz6 = [sum(zz6),zz6];
% yy6 = [260*nanmean(xx(tt6,:)); 16*nanmean(xx(tt6,:))./nanstd(xx(tt6,:)); min(xxDD(tt6,:)); zz6];
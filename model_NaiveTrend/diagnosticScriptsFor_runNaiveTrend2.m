% compute turnover
260*sum(nanmean(abs(portSim.wts(1001:end,:)-portSim.wts(1000:end-1,:))))'

% plot asset returns against signals:
for k = 1:9
   header = signal.subStrat(k).assetIDs; 
   for kk = 1:length(header)
      kkk = find(strcmp(assetDataPx.header,header(kk)));
      figure(1); plot(assetDataPx.dates,[signal.subStrat(k).values(:,kk),calcCum(assetDataPx.close(:,kkk),1)])
      datetick('x','mmmyyyy')
      header(kk)
      pause
   end % kk
end % k

% plot positions against signals:
for k = 1:9
   header = signal.subStrat(k).assetIDs; 
   for kk = 1:length(header)
      kkk = find(strcmp(portSim.header,header(kk)));
      plot(portSim.dates,[signal.subStrat(k).values(:,kk),portSim.wts(:,kkk)])
      datetick('x','mmmyyyy')
      header(kk)
      pause
   end % kk
end % k

% compute how much turnover is from portConst, how much from signal
temp = [signal.subStrat(1).values(1001:end,:),signal.subStrat(2).values(1001:end,:),signal.subStrat(3).values(1001:end,:),...
        signal.subStrat(4).values(1001:end,:),signal.subStrat(5).values(1001:end,:),signal.subStrat(6).values(1001:end,:),...
        signal.subStrat(7).values(1001:end,:),signal.subStrat(8).values(1001:end,:),signal.subStrat(9).values(1001:end,:)];
const1 = nanmean(abs(temp)); 
const2 = nanmean(abs(portSim.wts(1001:end,:))); 
TrnOvr0 = 260*sum(nanmean(abs(temp(2:end,:)-temp(1:end-1,:))));
TrnOvr1 = 260*sum(nanmean(abs(temp(2:end,:)-temp(1:end-1,:))).*(const2./const1));
TrnOvr2 = 260*sum(nanmean(abs(portSim.wts(1002:end,:)-portSim.wts(1001:end-1,:))));
[TrnOvr0, TrnOvr1, TrnOvr2]

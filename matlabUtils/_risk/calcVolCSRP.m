function vol = calcVolCSRP(assetData,simConfig) 
buffer = 260; 
hl(1) = simConfig.volRangeHL;
hl(2) = simConfig.volCloseHL;
alpha = simConfig.volAlpha;
method = simConfig.volMethod;
switch method
   case 'mixedEWA'
      rtns = assetData.close;
      range = assetData.range;
      seed1 = zeros(1, size(range, 2));
      seed2 = zeros(1, size(rtns, 2));
      for n = 1 : size(range, 2)
          range_n = range(:, n);
          range_n_trimmed = range_n(~isnan(range_n));
          seed1(n) = std(range_n_trimmed(1:buffer));         
      end
      for n = 1 : size(rtns, 2)
          returns_n = rtns(:, n);
          returns_n_trimmed = returns_n(~isnan(returns_n));
          seed2(n) = std(returns_n_trimmed(1:buffer)); 
      end
      T = length(rtns); 
      volVec1 = calcEWAvol(range,hl(1),0,seed1,true); 
      volVec2 = calcEWAvol(rtns,hl(2),0,seed2,true); 
      for n = 1:size(volVec1,2)
         volVec1(:,n) = rmNaNs(volVec1(:,n),seed1(:,n)); 
         volVec2(:,n) = rmNaNs(volVec2(:,n),seed2(:,n)); 
      end % n 
      % re-scale abs range into stdev units: 
      coeff = nanmean(volVec2./volVec1); 
      volVec1 = repmat(coeff,[T,1]).*volVec1; 
      vol = alpha*volVec1+(1-alpha)*volVec2; 
      
      if isfield(simConfig, 'overrideheader')
          overrideIndex = find(ismember(assetData.header, simConfig.overrideheader));
          vol(:, overrideIndex) = volVec2(:, overrideIndex);
      end
      
      if isfield(simConfig, 'volFloor')
          volFloor = simConfig.volFloor / (260 ^ 0.5);
          vol(vol < volFloor) = volFloor;
      end      
      
    case 'closeEWA'
      rtns = assetData.close;
      volVec2 = nanstd(rtns(1:buffer,:));
      volVec2 = calcEWAvol(rtns,hl(2),0,volVec2,true);
      vol = volVec2;
 
    case 'dailyRangeEWA'
      rtns = assetData.close;
      range = assetData.range;
      volVec1 = nanstd(range(1:buffer,:));
      volVec2 = nanstd(rtns(1:buffer,:));
      T = length(rtns);
      volVec1 = calcEWAvol(range,hl(1),0,volVec1,true);
      volVec2 = calcEWAvol(rtns,hl(2),0,volVec2,true);
      % re-scale abs range into stdev units:
      coeff = mean(volVec2./volVec1);
      volVec1 = repmat(coeff,[T,1]).*volVec1;
      vol = volVec1;
end % switch
end % fn 
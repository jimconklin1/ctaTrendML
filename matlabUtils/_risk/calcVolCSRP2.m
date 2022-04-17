function vol = calcVolCSRP2(assetData,riskConfig) 
buffer = riskConfig.buffer; 
hl(1) = riskConfig.volRangeHL;
hl(2) = riskConfig.volCloseHL;
obsTruncate = 5; % units in stdevs
method = riskConfig.volMethod;
switch method
   case 'mixedEWA'
      a = riskConfig.volMix;
      rtns = assetData.close;
      range = assetData.range;
      seed1 = zeros(1, size(range, 2));
      seed2 = zeros(1, size(rtns, 2));
      for n = 1 : size(range, 2)
          range_n = range(:, n);
          range_n_trimmed = range_n(~isnan(range_n));
          t1 = min([length(range_n_trimmed),buffer]); 
          seed1(n) = std(range_n_trimmed(1:t1));         
      end
      for n = 1 : size(rtns, 2)
          returns_n = rtns(:, n);
          returns_n_trimmed = returns_n(~isnan(returns_n));
          t1 = min([length(returns_n_trimmed),buffer]); 
          seed2(n) = std(returns_n_trimmed(1:t1)); 
      end
      T = length(rtns); 
      volVec1 = calcEWAvol(range,hl(1),0,seed1,true,obsTruncate); 
      volVec2 = calcEWAvol(rtns,hl(2),0,seed2,true,obsTruncate); 
      for n = 1:size(volVec1,2)
         volVec1(:,n) = rmNaNs(volVec1(:,n),seed1(:,n)); 
         volVec2(:,n) = rmNaNs(volVec2(:,n),seed2(:,n)); 
      end % n 
      % re-scale abs range into stdev units: 
      coeff = nanmean(volVec2./volVec1); 
      volVec1 = repmat(coeff,[T,1]).*volVec1; 
      vol = a*volVec1+(1-a)*volVec2; 
      
      if isfield(riskConfig, 'overrideheader')
          overrideIndex = find(ismember(assetData.header, riskConfig.overrideheader));
          vol(:, overrideIndex) = volVec2(:, overrideIndex);
      end
      
    case 'closeEWA'
      rtns = assetData.close;
      seed2 = zeros(1, size(rtns,2));
      for n = 1 : size(rtns,2)
         returns_n = rtns(:,n);
         returns_n_trimmed = returns_n(~isnan(returns_n));
         t1 = min([length(returns_n_trimmed),buffer]); 
         seed2(n) = std(returns_n_trimmed(1:t1)); 
      end 
      volVec2 = calcEWAvol(rtns,hl(2),0,seed2,true,obsTruncate); 
      for n = 1:size(volVec2,2)
         volVec2(:,n) = rmNaNs(volVec2(:,n),seed2(:,n)); 
      end % n 
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

if isfield(riskConfig, 'volFloor')
    volFloor = riskConfig.volFloor ./ (260 ^ 0.5);
    if size(volFloor,2)==1
        vol(vol < volFloor) = volFloor;
    else
        for i = 1:size(vol,1)
            for j = 1:size(vol,2)
                if vol(i,j) < volFloor(j)
                    vol(i,j) = volFloor(j);
                end
            end
        end
    end
            
end

end % fn 
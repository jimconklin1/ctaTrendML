function totRtns = computeReplTotalRtns(assetHeader,assetConfigTable,rawPx,rawRtns,carryHeader,carryData) 
totRtns = rawRtns;
N = length(assetHeader); 
for n = 1:N
   if assetConfigTable.carryCalcCode(n)==1 % O/N ccy fwd points, indirect pairs
      nn = find(strcmp(carryHeader,assetConfigTable.auxAssetBbgID(n))); 
      ptsConvention = assetConfigTable.fwdPtsConvention(n); 
      temp = carryData(:,nn)/ptsConvention; %#ok<FNDSB> if pts positive, carry on fgn ccy is positive
      temp(isnan(temp)) = 0; 
      if strcmp(assetConfigTable.bbgID{n}(1:3),'USD')
         totRtns(:,n) = rawRtns(:,n) + temp./rawPx(:,n); 
      else % if strcmp(assetConfigTable.bbgID{n}(4:6),'USD'), i.e, data pulled from bbg
           % *NOT* according to convention
         totRtns(:,n) = rawRtns(:,n) + temp.*rawPx(:,n); % spot pulled in as 1./spot, but pts in USDXXX convention
      end % if
   elseif assetConfigTable.carryCalcCode(n)==2 % O/N ccy fwd points, direct pairs
      nn = find(strcmp(carryHeader,assetConfigTable.auxAssetBbgID(n))); 
      ptsConvention = assetConfigTable.fwdPtsConvention(n); 
      temp = -carryData(:,nn)/ptsConvention;  %#ok<FNDSB> if pts positive, carry on fgn ccy is negative
      temp(isnan(temp)) = 0; 
      totRtns(:,n) = rawRtns(:,n) + temp./rawPx(:,n); 
   elseif assetConfigTable.carryCalcCode(n)==3 % 1-mo ccy fwd points, indirect pairs
      nn = find(strcmp(carryHeader,assetConfigTable.auxAssetBbgID(n))); 
      ptsConvention = assetConfigTable.fwdPtsConvention(n); 
      temp = carryData(:,nn)/(22*ptsConvention); %#ok<FNDSB>
      temp(isnan(temp)) = 0; 
      if strcmp(assetConfigTable.bbgID{n}(1:3),'USD')
         temp2 = (1./rawPx(:,n)); 
         temp2(isnan(temp2)) = nanmean(temp2); 
         totRtns(:,n) = rawRtns(:,n) + temp.*temp2; 
      else % if strcmp(assetConfigTable.bbgID{n}(4:6),'USD'), i.e, data pulled from bbg
         % *NOT* according to convention
         temp2 = (1./rawPx(:,n)); 
         temp2(isnan(temp2)) = nanmean(temp2); 
         totRtns(:,n) = rawRtns(:,n) + temp./temp2; 
      end % if
   elseif assetConfigTable.carryCalcCode(n)==4 % 1-mo ccy fwd points, direct pairs
      nn = find(strcmp(carryHeader,assetConfigTable.auxAssetBbgID(n))); 
      ptsConvention = assetConfigTable.fwdPtsConvention(n); 
      temp = -carryData(:,nn)/(22*ptsConvention);  %#ok<FNDSB>
      temp(isnan(temp)) = 0; 
      temp2 = (1./rawPx(:,n)); 
      temp2(isnan(temp2)) = nanmean(temp2); 
      totRtns(:,n) = rawRtns(:,n) + temp.*temp2; 
   elseif assetConfigTable.carryCalcCode(n)==5 % swap 1-yr rolls
      nn = find(strcmp(carryHeader,assetConfigTable.auxAssetBbgID(n))); 
      temp = 100*(carryData(:,nn) - rawPx(:,n))/365;  %#ok<FNDSB>
      temp(isnan(temp)) = 0; 
      totRtns(:,n) = rawRtns(:,n) - temp; % Note: for swaps, reversed: if "rtn" is negative, a negative DV01 (receive) position gets PnL>0
   end % if
   
end % for N 
end % fn 

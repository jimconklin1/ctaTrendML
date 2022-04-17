function simStruct = constructPortfolioGM5(assetData, signal, covmtx, datesCov, dataConfig, portConfig) 
% This function takes a raw directional signal and converts it into
% portfolio positions whose units are in NAVs.  

% The function differs from constructPortfolioGM3.m in that keys on signal
%   dates rather the assetData dates, and will compute signals on dates
%   later than the last assetData date.

% NOTES: the structure signal will have k = 1:K subStrats(k).  Each
%   subStrat's fields (e.g., signals, etc.) are NOT defined over the entire
%   assetData universe, but the elements of the *sub-universe*.
%   Consequently, in this function, size(simStruct.wts0(:,indx(k)),2) == 
%   size(simStruct.subStruct(k).wts(:,:),2).

%% parse input arguments:
% p = inputParser;
% p.addRequired('assetData'); 
% p.addRequired('signal'); 
% p.addRequired('covmtx'); 
% p.addRequired('dataConfig'); 
% p.parse(assetData, signal, covmtx, dataConfig, varargin{:}); 

%% assign convenient variable names:
daysInYr = portConfig.annBusDays; 
if isfield(assetData,'values')
   rtns = assetData.values; 
elseif isfield(assetData,'close')
   rtns = assetData.close; 
elseif isfield(assetData,'rtns')
   rtns = assetData.rtns; 
end

% set params:
K = length(signal.subStrat); % or K = portConfig.numSubStrats; 
%rebalTol = portConfig.rebalTol; 

% align dates between pricing data and signal data; NOTE: signal data
%  may extend to days beyond the end of pricing data
tempDates = [];
for k = 1:K
   tempDates = [tempDates; signal.subStrat(k).dates]; %#ok<AGROW>
end % for k
sDates2 = unique(tempDates,'sorted'); clear tempDates;

% Note: it is likely that signal dates occur earlier in the day than the
%   closing price -- so PnL returns dates need to have a later time stamp.
% Compute both the aligned returns and their corresponding time stamps:
[rtns2, rDates2, ~] = alignRtns2NewDates(assetData.dates, rtns, sDates2); 
[T,N] = size(rtns2);
ddVolScaleMax = ones(1,K);
% align signals to the new extended dates:
for k = 1:K
   [temp2, ~] = alignSignals2NewDates(signal.subStrat(k).dates, signal.subStrat(k).values, sDates2); 
   aa = portConfig.subStrat(k);
   ddParam = [aa.DDriskAvers, aa.DDalpha, aa.ddDecayRate, aa.DDsharpe, 1];
   [~, currScale] = getDDtargetRisk3(ddParam,0,'daily'); 
   ddVolScaleMax(1,k) = currScale;
   % fill in NaNs, zeros w/ earlier signal value:
   for t = 2:length(temp2)
       indx = isnan(temp2(t,:));
       temp2(t,indx) = temp2(t-1,indx);
       indx = temp2(t,:)==0;
       temp2(t,indx) = temp2(t-1,indx);
   end % for
   signal.subStrat(k).dates = sDates2;
   signal.subStrat(k).values = temp2;
end % for k 

%% convert the directional signals into portfolio holdings: 
% NOTE: unlike the function portfolioConstruction.m, this function does not
%   yet have an optimization option.
simStruct = initializeSimStruct(assetData.header,rDates2,sDates2,rtns2,signal,dataConfig,portConfig); 
rawVol0 = zeros(T,1); 
mult0 = ones(T,1); 
ddVolScale = ones(T,K); 
simStruct.targRisk = repmat(portConfig.portVolTarget/sqrt(daysInYr),[T,1]); % vol in daily, decimal units 
for t = 1:T 
   tCov = find(floor(datesCov)<=floor(sDates2(t)),1,'last');
   for k = 1:K
     VCVmat = squeeze(covmtx(simStruct.subStrat(k).indx,simStruct.subStrat(k).indx,tCov));
     pcMethod = portConfig.subStratMethod{k};
     aa = portConfig.subStrat(k);
     risk_ub = aa.maxRisk/sqrt(252); % daily vol terms
     risk_lb = aa.DDminRisk/sqrt(252); % daily vol terms
     ddParam = [aa.DDriskAvers, aa.DDalpha, aa.ddDecayRate, aa.DDsharpe, 1];
%      if (t == 520) || (t == 1040)
%          disp('here'); 
%      end % if
     if t > 1
        % update decayed HW, decayed drawdown, nav, etc.: 
        simStruct.subStrat(k) = calcDDandPnL(simStruct.subStrat(k),portConfig,dataConfig,rtns2(:,simStruct.subStrat(k).indx),t,k,portConfig.subStrat(k).ddOpt);
        % adjust target vol with updated drawdown level:
        decayedDrawdown = simStruct.subStrat(k).dd.drawdown(t,1); 
        [currTargRisk, currScale] = getDDtargetRisk3(ddParam,decayedDrawdown,'daily'); 
        ddVolScale(t,k) = currScale; 
        simStruct.subStrat(k).targRisk(t,:) = min(max([risk_lb; currTargRisk]),risk_ub); % when fn didn't react to DD: = simStruct.targRisk(t,:); 
        % compute position according to PC method, given DD-constrained
        %    port construction:
        simStruct.subStrat(k).wts(t,:) = portConstKernel(signal.subStrat(k).values(t,:), VCVmat, ...
                                                         simStruct.subStrat(k).targRisk(t,:), pcMethod); 
        simStruct.rawSig(t,simStruct.subStrat(k).indx) = signal.subStrat(k).values(t,:); 
     else 
        simStruct.subStrat(k).wts(t,:) = portConstKernel(signal.subStrat(k).values(t,:), VCVmat, ...
                                                         simStruct.subStrat(k).targRisk(t,:), pcMethod); 
        simStruct.rawSig(t,simStruct.subStrat(k).indx) = signal.subStrat(k).values(t,:); 
     end % if 
     % the following line is additive, not a straight assignment, in case
     % certain assets are appear in multiple strategies
     if strcmpi(pcMethod,'corrParity')|| strcmpi(pcMethod,'varyingPremia') || strcmpi(pcMethod,'optimal')
        simStruct.wts0(t,simStruct.subStrat(k).indx) = portConfig.subStratWts(t,k)*simStruct.subStrat(k).wts(t,:) + ...
                                                       simStruct.wts0(t,simStruct.subStrat(k).indx);
     else % portConfig.subStratWts is not dynamic, ~ [1,N]
        simStruct.wts0(t,simStruct.subStrat(k).indx) = portConfig.subStratWts(k)*simStruct.subStrat(k).wts(t,:) + ...
                                                       simStruct.wts0(t,simStruct.subStrat(k).indx);
     end % if 
   end % for k
   % Full portfolio DD control:
   k = 0; 
   %pcMethod = portConfig.method;
   VCVmat = squeeze(covmtx(:,:,tCov)); 
   rawVol0(t,1) = sqrt(simStruct.wts0(t,:)*VCVmat*simStruct.wts0(t,:)');
   risk_ub = portConfig.maxRisk/sqrt(252); % daily vol terms
   risk_lb = portConfig.DDminRisk/sqrt(252); % daily vol terms

   % compute pnl, drawdowns across all subStrats:
   % Now incorporate changes above here!
   if t > 1
      ddParam = [portConfig.DDriskAvers, portConfig.DDalpha, portConfig.ddDecayRate, portConfig.DDsharpe, 1];
      % compute hw, decayed DD, nav, etc:
      simStruct = calcDDandPnL(simStruct,portConfig,dataConfig,rtns2,t,k,portConfig.ddOpt); 
      decayedDrawdown = simStruct.dd.drawdown(t,1);
      [aggTargRisk, ~] = getDDtargetRisk3(ddParam,decayedDrawdown);
      simStruct.targRisk(t,:) = min(max([risk_lb; aggTargRisk]),risk_ub);  % daily vol units 
   end % if 
   if simStruct.targRisk(t,:) <= rawVol0(t,1) 
       mult0(t,1) = simStruct.targRisk(t,:)/rawVol0(t,1); 
   elseif rawVol0(t,1)>0 
       mult1 = (ddVolScale(t,:)./ddVolScaleMax)*portConfig.subStratWts'; 
       mult0(t,1) = (simStruct.targRisk(t,:)*mult1)/rawVol0(t,1); 
   end % if 
   simStruct.wts(t,:) = mult0(t,:)*simStruct.wts0(t,:);
   % Note to self: you are NOT re-deploying portfolio construction from
   % scratch... that would un-do subStrat level DD control
   % = portConstKernel(signal.subStrat(k).values(t,:), VCVmat, ...
   %                   simStruct.subStrat(k).targRisk(t,:), pcMethod);
   if t > 1
      holidayStruct.header = assetData.header;
      holidayStruct.holidays = assetData.holidays;
      temp = getAllowableTrades(simStruct.wts(t-1:t,:), simStruct.targRisk(t,:), portConfig.rebalTol, simStruct.dates(t-1:t,:), holidayStruct);
      simStruct.wts(t,:) = temp(2,:);
   end 
   simStruct.actRisk(t,:) = sqrt(simStruct.wts(t,:)*VCVmat*simStruct.wts(t,:)'); 
end % for t
disp('Completed portfolio construction.')
end % fn

function simStruct = initializeSimStruct(header,rtnDates,sigDates,rtns,signal,dataConfig,portConfig)
simStruct.dates = sigDates; 
simStruct.pnlDates = rtnDates; 
simStruct.header = header;
simStruct.rawSig = zeros([size(simStruct.dates,1),size(rtns,2)]); 
simStruct.wts0 = zeros([size(simStruct.dates,1),size(rtns,2)]); 
simStruct.wts = zeros([size(simStruct.dates,1),size(rtns,2)]); 
simStruct.pnl = zeros([size(simStruct.dates,1),size(rtns,2)]); 
simStruct.totPnl = zeros(size(simStruct.dates,1),1); 
simStruct.targRisk = zeros([size(simStruct.dates,1),size(rtns,2)]); 
simStruct.actRisk = zeros([size(simStruct.dates,1),size(rtns,2)]); 
simStruct.dd.nav = ones(length(sigDates),1);
simStruct.dd.highDate = repmat(rtnDates(1),[length(sigDates),1]);
simStruct.dd.highValue = ones(length(sigDates),1);
simStruct.dd.decayedHigh = ones(length(sigDates),1);
simStruct.dd.drawdown = zeros(length(sigDates),1);
simStruct.dd.decayedDrawdown = zeros(length(sigDates),1);
% NOTE: by convention, each subStrategy runs at "full vol"; holdings are 
%   only scaled down (subStratWts applied) when combined into "wts0" at 
%   the full portfolio level.
for k = 1:portConfig.numSubStrats
   switch signal.subStratAssetClass{k}
      case 'rates' 
         simStruct.subStrat(k).header = dataConfig.rates.header(portConfig.subStrat(k).indx); 
      case 'cdx' 
         simStruct.subStrat(k).header = dataConfig.cdx.header(portConfig.subStrat(k).indx); 
      case 'irs' 
         simStruct.subStrat(k).header = dataConfig.irs.header(portConfig.subStrat(k).indx); 
      case 'equity' 
         simStruct.subStrat(k).header = dataConfig.equity.header(portConfig.subStrat(k).indx); 
      case 'ccy' 
         simStruct.subStrat(k).header = dataConfig.ccy.header(portConfig.subStrat(k).indx); 
      case 'comdty' 
         simStruct.subStrat(k).header = dataConfig.comdty.header(portConfig.subStrat(k).indx); 
   end % switch 
   simStruct.subStrat(k).dates = simStruct.dates; 
   simStruct.subStrat(k).wts = zeros(size(signal.subStrat(k).values)); 
   simStruct.subStrat(k).pnl = zeros(size(signal.subStrat(k).values)); 
   simStruct.subStrat(k).tc = zeros(size(signal.subStrat(k).values)); 
   simStruct.subStrat(k).totPnl = zeros(length(signal.subStrat(k).values),1); 
   simStruct.subStrat(k).targRisk = zeros(length(signal.subStrat(k).values),1); 
   simStruct.subStrat(k).actRisk = zeros(length(signal.subStrat(k).values),1); 
   if portConfig.subStrat(k).ddOpt
      simStruct.subStrat(k).dd.nav = ones(length(signal.subStrat(k).values),1);
      simStruct.subStrat(k).dd.highDate = repmat(rtnDates(1),[length(signal.subStrat(k).values),1]);
      simStruct.subStrat(k).dd.highValue = ones(length(signal.subStrat(k).values),1);
      simStruct.subStrat(k).dd.decayedHigh = ones(length(signal.subStrat(k).values),1);
      simStruct.subStrat(k).dd.drawdown = zeros(length(signal.subStrat(k).values),1);
      simStruct.subStrat(k).dd.decayedDrawdown = zeros(length(signal.subStrat(k).values),1);
   end 
end % for k

% HERE: map signals, aligned to sub-asset universes, to new columns that
% span all assets: 
simStruct.indx = 1:size(header,2);
for k = 1:portConfig.numSubStrats
   [~, temp] = ismember(simStruct.subStrat(k).header,header);
   % temp = makeStrMap(header,simStruct.subStrat(k).header, false); 
   simStruct.subStrat(k).indx = temp;
end % for k

end % fn

function wts = portConstKernel(signal,VCVmat,targRisk,portMethod,params)
% portfolio construction kernel:
% Inputs: 

%    signal: either an expected return forecast or a normalized trading
%       signal whose sign indicates the expected direction of future asset 
%       returns and whose magnitude indicates conviction.
%    VCVmat: variance covariance matrix.  Units are DAILY.
%    targRisk: target portfolio risk.  Units are DAILY.
%    portMethod: indicates which method to select below (if-statement)
%    params:    auxiliary data that might be required for the portMethod 
%       chosen
% Outputs: wts are a vector of rates, 1 x N, N=number of assets traded.
varTol = 1.0e-12; 
if strcmp(portMethod,'optimal')
   if nargin<5 || isempty(params)
      disp('For portMethod == ''optimal'' the structure param must be passed non-empty.')
      disp('Passing back ''NaNs'' for weights.')
      wts = nan(size(signal)); 
      return
   end % if 
elseif strcmp(portMethod,'corrParity')||strcmp(portMethod,'varyingPremia')
   maxAbsCorr = 0.5; 
   toler = 1.0e-10; 
   temp1 = sqrt(diag(VCVmat))';
   corrMat = VCVmat./(temp1'*temp1); 
   sr = signal;
   temp2 = optPortCorrNonNeg(sr,corrMat,maxAbsCorr,toler); 
   temp3 = temp2*VCVmat*temp2';
   % deal w/ poorly conditioned VCV matrices:
   if temp3 < varTol && sum(abs(temp2))==0
       temp3 = varTol;
   elseif temp3 < varTol
       VCVmat2 = eye(size(VCVmat,1)).*repmat(abs(diag(VCVmat)),[1,size(VCVmat,1)]);
       temp3 = temp2*(0.5*VCVmat+0.5*VCVmat2)*temp2';
   end 
   mult = targRisk/sqrt(temp3); 
   wts = mult*temp2; 
   wts(isnan(wts))=0;
elseif strcmp(portMethod,'proportionalRisk') 
   temp1 = sqrt(diag(VCVmat))';
   temp2 = signal./temp1; 
   temp3 = temp2*VCVmat*temp2';
   % deal w/ poorly conditioned VCV matrices:
   if temp3 < varTol && sum(abs(temp2))==0
       temp3 = varTol;
   elseif temp3 < varTol
       VCVmat2 = eye(size(VCVmat,1)).*repmat(abs(diag(VCVmat)),[1,size(VCVmat,1)]);
       temp3 = temp2*(0.5*VCVmat+0.5*VCVmat2)*temp2';
   end 
   mult = targRisk/sqrt(temp3); 
   wts = mult*temp2; 
   wts(isnan(wts))=0;
elseif strcmp(portMethod,'scaledRiskWeights')
   % if signals have low average values, allow risk to be lower
   mult2 = nanmean(signal./sign(signal));
   mult2 = nansum([mult2; zeros(size(mult2))]); % dealing w/ the case of nanmean() = NaN;
   temp2 = signal; 
   temp3 = temp2*VCVmat*temp2';
   % deal w/ poorly conditioned VCV matrices:
   if temp3 < varTol && sum(abs(temp2))==0
       temp3 = varTol;
   elseif temp3 < varTol
       VCVmat2 = eye(size(VCVmat,1)).*repmat(abs(diag(VCVmat)),[1,size(VCVmat,1)]);
       temp3 = temp2*(0.5*VCVmat+0.5*VCVmat2)*temp2';
   end 
   mult = targRisk/sqrt(temp3); 
   wts = mult*mult2*temp2; 
   wts(isnan(wts))=0; 
else % strcmp(portMethod,'fixedRiskWeights')
   temp2 = signal; 
   temp3 = temp2*VCVmat*temp2';
   % deal w/ poorly conditioned VCV matrices:
   if temp3 < varTol && sum(abs(temp2))==0
       temp3 = varTol;
   elseif temp3 < varTol
       VCVmat2 = eye(size(VCVmat,1)).*repmat(abs(diag(VCVmat)),[1,size(VCVmat,1)]);
       temp3 = temp2*(0.5*VCVmat+0.5*VCVmat2)*temp2';
   end 
   mult = targRisk/sqrt(temp3); 
   wts = mult*temp2; 
   wts(isnan(wts))=0; 
end % if
end % fn 

function simStruct = constructPortfolioGM3(assetData, signal, covmtx, datesCov, dataConfig, portConfig) 
% This function takes a raw directional signal and converts it into
% portfolio positions whose units are in NAVs.  

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
[T,N] = size(rtns);
K = length(signal.subStrat); % or K = portConfig.numSubStrats; 
for k = 1:K
   if T~=length(signal.subStrat(k).values)
      disp(['WARNING: dimension mis-match between ',signal.subStratNames{k},' signal and asset returns in number of periods.'])
      disp('Re-aligning return data.')
      [temp, ~] = alignNewDatesJC(signal.subStrat(k).dates, signal.subStrat(k).values, assetData.dates, NaN);
      % fill in NaNs w/ earlier signal value:
      for t = 2:length(temp)
         indx = isnan(temp(t,:)); 
         temp(t,indx) = temp(t-1,indx); 
      end % for 
      signal.subStrat(k).dates2 = signal.subStrat(k).dates; 
      signal.subStrat(k).values2 = signal.subStrat(k).values; 
      signal.subStrat(k).dates = assetData.dates; 
      signal.subStrat(k).values = temp; 
   end % if 
end % m 

%dailyAssetVolFloor = (1/sqrt(daysInYr))*portConfig.assetVolFloor; % daily return units
rebalTol = portConfig.rebalTol; 

%% convert the directional signals into portfolio holdings: 
% NOTE: unlike the function portfolioConstruction.m, this function does not
%   yet have an optimization option.
simStruct = initializeSimStruct(assetData,rtns,signal,dataConfig,portConfig); 
rawVol0 = zeros(T,1); 
mult0 = zeros(T,1); 
tempWts = zeros(T,N); 
simStruct.targRisk = repmat(portConfig.portVolTarget/sqrt(daysInYr),[T,1]); % vol in daily, decimal units 
for t = 1:T 
   tCov = find(floor(datesCov)<=floor(assetData.dates(t)),1,'last');
   for k = 1:K
     ddParam = [];
     simStruct.subStrat(k).targRisk(t,:) = getDDtargetRisk3(ddParam,decayedDrawdown); % when fn didn't react to DD: = simStruct.targRisk(t,:); 
     VCVmat = squeeze(covmtx(simStruct.subStrat(k).indx,simStruct.subStrat(k).indx,tCov));
     simStruct.subStrat(k).wts(t,:) = portConstKernel(signal.subStrat(k).values(t,:), VCVmat,...
                                      simStruct.subStrat(k).targRisk(t,:), portConfig.method);
     if t > 1
        temp = calcDDandPnL(simStruct.subStrat(k),portConfig,dataConfig,rtns(:,simStruct.subStrat(k).indx),t,k,portConfig.ddMode);
        simStruct.subStrat(k) = temp;
     end % if 
     % the following line is additive, not a straight assignment, in case
     % certain assets are appear in multiple strategies
     if strcmpi(portConfig.method,'corrParity')|| strcmpi(portConfig.method,'varyingPremia') || strcmpi(portConfig.method,'optimal')
        simStruct.wts0(t,simStruct.subStrat(k).indx) = portConfig.subStratWts(t,k)*simStruct.subStrat(k).wts(t,:) + ...
                                                       simStruct.wts0(t,simStruct.subStrat(k).indx);
     else % portConfig.subStratWts is not dynamic, ~ [1,N]
        simStruct.wts0(t,simStruct.subStrat(k).indx) = portConfig.subStratWts(k)*simStruct.subStrat(k).wts(t,:) + ...
                                                       simStruct.wts0(t,simStruct.subStrat(k).indx);
     end % if 
   end % for k
   VCVmat = squeeze(covmtx(:,:,tCov)); 
   rawVol0(t,1) = sqrt(simStruct.wts0(t,:)*VCVmat*simStruct.wts0(t,:)');
   denom = rawVol0(t,1) + (rawVol0(t,1)==0)*simStruct.targRisk(t,1); % if rawVol is 0 make multiplier =1
   mult0(t,1) = simStruct.targRisk(t,1)/denom; 
   tempWts(t,:) = mult0(t,1)*simStruct.wts0(t,:); 
   % compute pnl, drawdowns across all subStrats:
   k = 0; 
   if t > 1
      ddParam = [];
      temp = [simStruct.wts(t-1,:); tempWts(t,:)];
      targRisk = getDDtargetRisk3(ddParam,decayedDrawdown); % = simStruct.targRisk(t,:);
      temp = getThreshRebal(temp, targRisk, rebalTol); 
      temp =  temp(2,:); 
      temp(tempWts(t,:) == 0) = 0; % force trade when the target is zero
      simStruct.wts(t,:) = adjustPositions(temp, simStruct.wts(t-1,:), portConfig, simStruct); 
      % compute hw, decayed DD, nav, etc:
      simStruct = calcDDandPnL(simStruct,portConfig,dataConfig,rtns,t,k,portConfig.ddMode); 
   else 
      simStruct.wts(t,:) = tempWts(t,:); 
   end 
   simStruct.actRisk(t,:) = sqrt(simStruct.wts(t,:)*VCVmat*simStruct.wts(t,:)'); 
end % for t
disp('Completed portfolio construction.')
end % fn

function simStruct = initializeSimStruct(assetData,rtns,signal,dataConfig,portConfig)
simStruct.dates = assetData.dates(:,1); 
simStruct.header = assetData.header;
simStruct.wts0 = zeros(size(rtns)); 
simStruct.wts = zeros(size(rtns)); 
simStruct.pnl = zeros(size(rtns)); 
simStruct.totPnl = zeros(size(rtns,1),1); 
simStruct.targRisk = zeros(length(rtns),1); 
simStruct.actRisk = zeros(length(rtns),1); 
% NOTE: by convention, each subStrategy runs at "full vol"; holdings are 
%   only scaled down (subStratWts applied) when combined into "wts0" at 
%   the full portfolio level.
for k = 1:portConfig.numSubStrats
   switch signal.subStratAssetClass{k}
      case 'rates' 
         simStruct.subStrat(k).header = dataConfig.rates.header(portConfig.subStrat(k).indx); 
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
%    simStruct.subStrat(k).dd.nav = ones(length(signal.subStrat(k).values),1);
%    simStruct.subStrat(k).dd.highDate = repmat(assetData.dates(1),[length(signal.subStrat(k).values),1]);
%    simStruct.subStrat(k).dd.highValue = ones(length(signal.subStrat(k).values),1);
%    simStruct.subStrat(k).dd.decayedHigh = ones(length(signal.subStrat(k).values),1);
%    simStruct.subStrat(k).dd.drawdown = zeros(length(signal.subStrat(k).values),1);
%    simStruct.subStrat(k).dd.decayedDrawdown = zeros(length(signal.subStrat(k).values),1);
end % for k

% HERE: map signals, aligned to sub-asset universes, to new columns that
% span all assets: 
simStruct.indx = 1:size(assetData.header,2);
for k = 1:portConfig.numSubStrats
   [~, temp] = ismember(simStruct.subStrat(k).header,assetData.header);
   % temp = makeStrMap(assetData.header,simStruct.subStrat(k).header, false); 
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
%    targRisk: target portfolio risk.  Units are MONTHLY.
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
else % strcmp(portMethod,'proportionalWeight')
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

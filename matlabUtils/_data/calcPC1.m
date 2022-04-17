function factor1 = calcPC1(assetData,keyAsset,optns)
% inputs:
%   assetData an input structure w/ asset return data in *.value or *.close
%      or *.rtns fields.
%   keyAsset: the asset we key on to guard against "sign flips" in the
%      polarity of the 1st PCA
%   optns or "options"; self-evident from parsing code, just below

if nargin < 2 || isempty(optns)
   optns.mode = 'var-cov'; 
   optns.polarityFlip = false; 
   optns.smoothWeights = false; 
   optns.gamma = 0.5; 
   optns.hl = [50,500]; 
end 

if ~isfield(optns,'unityWts')
  optns.unityWts = false; 
end 

if ~isfield(optns,'mode')
  optns.mode = 'var-cov'; 
end 

if ~isfield(optns,'polarityFlip')
  optns.polarityFlip = false; 
end 

if ~isfield(optns,'smoothWeights')
  optns.smoothWeights = false; 
end 

if ~isfield(optns,'smoothFactor')
  optns.smoothFactor = 10; 
end 

if ~isfield(optns,'gamma')
  optns.gamma = 0.5; 
end 

if ~isfield(optns,'hl')
  optns.hl = [50,500]; 
end 

if ~isfield(optns,'shrinkFactor')
  optns.shrinkFactor = 1; 
end 

if ~isfield(optns,'toler')
  optns.toler = 9.9e-11; 
end 

if ~isfield(optns,'buffer')
  optns.buffer = 252; 
end
% set half-lifes for var-cov matrix mix:
hl1 = optns.hl(1); 
hl2 = optns.hl(2); 
paramA = optns.smoothFactor; % the greater the value, the more smoothed
if isfield(assetData,'close')
   rtns = assetData.close;
elseif isfield(assetData,'rtns')
   rtns = assetData.rtns;
elseif isfield(assetData,'values')
   rtns = assetData.values;
end % if
% create USD weights w/ PCA: 
[T,N] = size(rtns); 
optns.buffer = min([2*252,round(T/10)]); %JON EDIT
t0 = calcFirstActive(rtns,1,optns.toler); 
pcLoading1 = zeros(T,N); 
finalLoading = zeros(T,N); 
eigVals = zeros(T,N); 
asstIndx = false(T,N); 
% T0 = max([optns.buffer,t0]); 
T0 = max([2*optns.buffer,t0]); %JON EDIT

% initilize 1st PC prior to buffer with equal wts: 
for t = 1:T0
   asstIndx(t,:) = (t0<=t); 
   finalLoading(t,:) = asstIndx(t,:)*(1./sum(asstIndx(t,:),2)); 
end 

% main loop (over periods) to compute 1st PC: 
vcv1 = nan(N,N,T); 
vcv2 = nan(N,N,T); 
temp1 = escov(rtns,hl1,'A');
temp2 = escov(rtns,hl2,'A');
%vcv1 = escov(rtns(T0:end,:),hl1,'A'); 
vcv1(:,:,1:T0+2) = repmat(temp1(:,:,T0+3),[1,1,T0+2]); 
vcv1(:,:,T0+3:end) = temp1(:,:,T0+3:end); 
vcv2(:,:,1:T0+2) = repmat(temp2(:,:,T0+3),[1,1,T0+2]); 
vcv2(:,:,T0+3:end) = temp2(:,:,T0+3:end); 
% vcv1 = cat(3,repmat(temp1,[1,1,T0-1]),vcv1);
% vcv2 = escov(rtns(T0:end,:),hl2,'A'); 
% temp2 = vcv2(:,:,optns.buffer);
% vcv2 = cat(3,repmat(temp2,[1,1,T0-1]),vcv2);
for t = T0+1:T
   % data housekeeping:
   asstIndx(t,:) = ((t-t0)>=optns.buffer); 
   tt0 = max(t0(asstIndx(t,:))); 
   if isempty(tt0)
       continue
   end % if

   % 1.) compute raw var-cov matrices, fast and slow: 
   temp1 = squeeze(vcv1(asstIndx(t,:),asstIndx(t,:),t)); 
   temp2 = squeeze(vcv2(asstIndx(t,:),asstIndx(t,:),t)); 
   % convert to correlation matrices:
   vols1 = diag(temp1).^0.5;
   corr1 = eye(N);
   corr1(asstIndx(t,:),asstIndx(t,:)) = temp1./(vols1*vols1');
   vols2 = diag(temp2).^0.5;
   corr2 = eye(N);
   corr2(asstIndx(t,:),asstIndx(t,:)) = temp2./(vols2*vols2');
   % shrink, if required
   if optns.shrinkFactor < 1
      corr1 = reduceOffDiags(corr1,optns.shrinkFactor);
      corr2 = reduceOffDiags(corr2,optns.shrinkFactor);
   end % if
   if strcmpi(optns.mode,'corr')
      omega = optns.gamma*corr1 + (1-optns.gamma)*corr2; 
   else % strcmpi(optns.mode,'var-cov')
%       temp1 = corr1.*repmat(vols1,[N,1]).*repmat(vols1',[1,N]); 
%       temp2 = corr2.*repmat(vols2,[N,1]).*repmat(vols2',[1,N]); 
      temp1 = corr1.*repmat(vols1,[1,N]).*repmat(vols1',[N,1]); %JON EDIT
      temp2 = corr2.*repmat(vols2,[1,N]).*repmat(vols2',[N,1]); %JON EDIT
      omega = optns.gamma*temp1 + (1-optns.gamma)*temp2; 
   end
   
   % 2.) derive PCA weights
   [temp,eigVal] = pcacov(omega); 
   pcLoading1(t,:) = temp(:,1)'; 
   eigVals(t,:) = eigVal'; 

   % 3.) Scale and smooth weights:
   if optns.unityWts
      if strcmp(optns.mode,'corr')
         pcTemp = pcLoading1(t,:)./vols2';
      else
         pcTemp = pcLoading1(t,:);
      end 
      posIndx = find(pcTemp>0);
      denom = sum(abs(pcTemp(1,posIndx))); %#ok
%       nIdx = find(pcTemp<0); 
%       if sum(abs(pcTemp(1,posIndx))) > sum(abs(pcTemp(1,nIdx)))
%          denom = sum(abs(pcTemp(1,posIndx))); 
%       else 
%          denom = sum(abs(pcTemp(1,nIdx))); 
%       end % if 
      x1 = pcTemp(1,:)/denom; 
   else 
      x1 = pcLoading1(t,:); 
   end 
   x2 = finalLoading(t-1,:); 
   if optns.smoothWeights
      gamma2 = fminbnd(@(gamma2) objDistFunc(gamma2,x1,x2,paramA),0.01,0.99);
      finalLoading(t,:) = gamma2*x1 + (1-gamma2)*x2; % xx = 
      % finalLoading(t,:) = xx/sum(abs(xx));
   else
      xx = 0.333*x1 + 0.667*x2; % moderately smoothed 
      finalLoading(t,:) = xx;
   end
   
   % 4.) Preserve polarity
   if keyAsset ~= 0
      if sign(finalLoading(t,keyAsset))~=sign(finalLoading(t-1,keyAsset))
         finalLoading(t,:) = -finalLoading(t,:);
      end 
   end 
%    if sign(mean(x1)) ~= sign(mean(x2))||sign(mean(x2))<0
%        x2 = -x2;
%    end
       
   % message computational problems, progress in loop:
%    if optns.unityWts && (sum(abs(finalLoading(t,:)))<0.999 || sum(abs(finalLoading(t,:)))>1.001)
%        disp(['In PCA loop, period t = ',num2str(t),' and wts do not sum to 1'])
%    end
   if mod(t,250)==0
       disp(['In PCA loop, period t = ',num2str(t)])
   end
end

% Compute 1st factor OUT-OF-SAMPLE:
temp = [zeros(1,N); finalLoading(1:end-1,:).*rtns(2:end,:)]; 
factor1.dates = assetData.dates; 
if optns.polarityFlip 
   factor1.values = -nansum(temp,2); 
else
   factor1.values = nansum(temp,2); 
end 
factor1.loadings1 = finalLoading; 
factor1.eigenValues = eigVals; 
end % fn

function y = objDistFunc(gamma,x1,x2,paramA)
   xx = gamma*x1 + (1-gamma)*x2; 
   xx = xx/sum(abs(xx)); 
   temp = abs(x1-xx) + paramA*(x2-xx).^2; 
   y = sum(temp); 
   %[x1;x2;xx;temp]
end % function
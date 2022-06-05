function o = computeFactorExposures(hHeader,rtns,rfr,fHeader,factors,cfg)  
 
[T,N] = size(rtns); 
[~,M] = size(factors); 
 
statCfg = {'tstat','fstat','rsquare'}; 
if cfg.opt.regression.dwstat 
    statCfg = [statCfg, {'dwstat'}]; 
end %if 
if isfield(cfg.opt.regression, 'singlePrimaryFactor') 
    cfg_singlePrimaryFactor = cfg.opt.regression.singlePrimaryFactor; 
else     
    cfg_singlePrimaryFactor = false; 
end 
 
% Derive factor exposures through sequential regression:  
bHeader = cfg.headers.betaHeader;  
aHeader = cfg.headers.arsHeader;  
bmHeader = cfg.headers.bmHeader;  
M1 = length(bHeader); 
M2 = M1+length(aHeader); 
M3 = M2+length(bmHeader);  
 
rgrsnOrdr = nan(N,M3);  
beta = nan(N,M3);  
alpha = nan(N,1);  
alphaTstats = nan(N,2); 
betaTstats = nan(N,M3); 
 
refinedAlphaTS = nan(T,N);  
primaryAlphaTS = nan(T,N);  
betaTS = nan(T,N,M1);  
arpTS = nan(T,N,M2-M1);  
 
% Block-sequential is the only option supported now, as too much have changed  
% since other options were last run. The old code is available in the "old" 
% sub-directory 
if cfg.adjustForTiming  
	timingParamBlock = nan(N,size(bHeader,2)); 
	timingBetaBlock = nan(N,size(bHeader,2)); 
	timingRtnMatrix = nan(T,N); 
end 
for n = 1:N % 
	blkItemLen = sum(cellfun(@(x) length(x), cfg.factors.blocks)); 
	saBetasLen = length(cfg.standAloneBetas); 
	totFctrLen = blkItemLen + saBetasLen; 
	numBlocks = length(cfg.factors.blocks); 
	 
	alphas = zeros(numBlocks,1); 
	betas = zeros(totFctrLen,1); 
	rSqr = zeros(numBlocks + saBetasLen,1); 
	%tIndx = find(rtns(:,n)~=0); 
	tIndx = ~isnan(rtns(:,n)); 
	needToSkip = isempty(tIndx); 
	if ~needToSkip 
		numObservations = sum(tIndx); % assumption: will get us # of 1's 
		needToSkip = (numObservations < 2*(blkItemLen+1)); 
	end % if ~needToSkip 
	if ~needToSkip 
		y = rtns(tIndx,n) - rfr(tIndx,:); 
		 
		% If timing is significant, adjust the returns 
		if cfg.adjustForTiming 
			yy = y; 
			outlierThreshold = 100; 
			timingThreshold = 0.05; 
			timingFactors = bHeader; 
            if cfg_singlePrimaryFactor 
                timingFactors = timingFactors(1); 
            end 
             
			for i= 1:size(timingFactors,2) 
				[timingParams, adjustedRtns] = squaredReturnTest(y ... 
					, factors(tIndx, mapStrings(timingFactors(i) ... 
					   , fHeader, false)) ... 
					, [], '', '', outlierThreshold, 0 ... 
				); 
				if (timingParams(6) <= timingThreshold) && (timingParams(3)>0) 
					y = adjustedRtns; 
					timingParamBlock(n,i) = timingParams(6); 
					timingBetaBlock(n,i) = timingParams(2); 
					%fprintf("%s,%s \n",cell2mat(hHeader(n)),cell2mat(timingFactors(i))) 
				end 
			end 
			timingRtnMatrix(tIndx,n) = yy-y; 
			clear yy; 
		end 
 
		blockStart = 1; 
		for iBlock = 1:numBlocks 
			blockHeader = cfg.factors.blocks{iBlock}; 
			factorBlock = mapStrings(blockHeader,fHeader,false); 
			blockLength = length(factorBlock); 
			blockEnd = blockStart + blockLength - 1; 
 
			X = factors(tIndx,factorBlock); 
            if (iBlock==1) && cfg_singlePrimaryFactor 
                X = X(:, 1); 
            end  
			%if iBlock > 1 
			   %X = X - repmat(mean(X),[size(X,1),1]); % de-mean regressors: y (a reside) is now de-meaned, too         
			%end 
            try 
                stats = regstats(y,X,'linear',[statCfg,{'r'}]); 
            catch ME 
                rethrow(ME); % this is the line for puttng debug breakpints 
            end 
            tstat_beta = stats.tstat.beta; 
            tstat_t = stats.tstat.t; 
            if (iBlock==1) && cfg_singlePrimaryFactor 
                % "pad" the data structures with zeroes so that the rest of 
                % the code keeps working as though all 4 factors were 
                % present and betas are zero. 
                tstat_beta(3:blockLength+1) = 0; 
                tstat_t(3:blockLength+1) = 0; 
            end 
			y = stats.r + tstat_beta(1); 
			if iBlock == 1  
				% TODO: make alphaTS a cell array so that every 
				% regression block generates alphTS. This will affect 
				% downstream code, so we hard-code block number for now. 
				primaryAlphaTS(tIndx,n) = tstat_beta(1) + stats.r; 
				if cfg.adjustForTiming 
					% Put timing back in after the 1st regression block. 
					 
					% Some funds have no timing ability (all NaNs in the timingRtnMatrix); 
					% That's why we have to turn NaNs into zeroes (otherwise the addition  
					% will produce NaNs across the board for funds that can't time). 
					tempTiming = rmNaNs(timingRtnMatrix(:,n)); 
					y = y + tempTiming(tIndx,:); 
					% See model doc: prim. alpha includes timing 
					primaryAlphaTS(tIndx,n) = primaryAlphaTS(tIndx,n) ...  
						+ tempTiming(tIndx,:); 
				end %if adjustForTiming 
			end % if iBlock == 1  
			alphas(iBlock,1) = tstat_beta(1); 
			betas(blockStart:blockEnd,1) = tstat_beta(2:blockLength+1); 
			tStats(blockStart:blockEnd,1) = tstat_t(2:blockLength+1); 
			rSqr(iBlock,1) = stats.rsquare; 
			 
			blockStart = blockEnd + 1; 
		end % for iBlock 
		 
		resids = stats.r; 
		% now evaluate bi-variate exposures to benchmarks: 
		y = rtns(tIndx,n) - rfr(tIndx,:); 
		strIndx = mapStrings(bmHeader,fHeader,false); 
		 
		for m = 1:saBetasLen  
			mm = strIndx(m); 
			X = factors(tIndx,mm); 
			stats = regstats(y,X,'linear',statCfg); 
			% alphas(mm,1) = stats.tstat.beta(1); % DO NOT INCLUDE BM alphas 
			%    into sum of factor exposure means!!!!  These are just 
			%    reference values, not part of factor loading analysis! 
			betas(m+blkItemLen,1) = stats.tstat.beta(2); 
			tStats(m+blkItemLen,1) = stats.tstat.t(2); 
			rSqr(m+blkItemLen,1) = stats.rsquare; 
		end 
		alpha(n,1) = alphas(end,1); 
		beta(n,:) = betas'; 
		refinedAlphaTS(tIndx,n) = alpha(n,1)+resids; 
		 
		% TODO: Below, we are assuming 2 blocks, 4 factors each. 
		% We need to generalize these outputs as well to variable 
		% number of blocks and factors. 
		betaTS(:,n,1:4) = factors(:,1:M1).*repmat(beta(n,1:M1),[T,1]); % NOT y... y is for subsequent iteration, not last resids 
		arpTS(:,n,1:4) = factors(:,M1+1:M2).*repmat(beta(n,M1+1:M2),[T,1]); % NOT y... y is for subsequent iteration, not last resids 
 
		alphaTstats(n,1) = stats.tstat.t(1); 
		betaTstats(n,:) = tStats(:,1)'; 
	else 
		alpha(n,1) = NaN; % -999999999; 
		beta(n,:) = repmat(-999999999,size(beta(n,:))); 
		refinedAlphaTS(tIndx,n) = NaN(size(refinedAlphaTS(tIndx,n)));  
		betaTS(:,n,1:4) = repmat(-999999999,size(betaTS(:,n,1:4)));  
		arpTS(:,n,1:4) = repmat(-999999999,size(arpTS(:,n,1:4)));  
		alphaTstats(n,1) = -999999999; 
		betaTstats(n,:) = repmat(-999999999,size(betaTstats(n,:))); 
	end 
end % for n 
 
 
 
o.hfHeader = hHeader; 
o.factorHeader = fHeader; 
o.betaHeader = bHeader; 
o.arpHeader = aHeader; 
o.bchmHeader = bmHeader; 
o.totRtns = rtns; 
o.beta = beta; 
o.alpha = alpha; 
o.refinedAlphaTS = refinedAlphaTS; 
o.primaryAlphaTS = primaryAlphaTS; 
o.betaTS = betaTS; 
o.arpTS = arpTS; 
o.alphaTstats = alphaTstats; 
o.tStats = betaTstats; 
o.rSqr = rSqr; 
if cfg.adjustForTiming 
    % Make sure funds with no timing ability show full column of NaNs 
    hasTimingIdx = sum(~isnan(timingRtnMatrix) & timingRtnMatrix ~= 0, 1) >0; 
    timingRtnMatrix(:, ~hasTimingIdx) = NaN; 
     
    o.timingParamBlock = timingParamBlock;  
    o.timingBetaBlock = timingBetaBlock;  
    o.timingRtnMatrix = timingRtnMatrix; 
end  
 
end % fn 

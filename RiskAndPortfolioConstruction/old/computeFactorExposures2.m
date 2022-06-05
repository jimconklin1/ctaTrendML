function o = computeFactorExposures2(hHeader,hDates,rtns,rfr,fHeader,factors,cfg,adjustForTiming) 
if nargin < 5 || isempty(cfg.opt)
   cfg.opt = 'OLS';
end 

if ~exist('adjustForTiming','var')
    adjustForTiming = false;
end

[T,N] = size(rtns);
[~,M] = size(factors);

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

if strcmp(cfg.opt,'sequential')
    for n = 1:N %
        tempBetas = zeros(M3,1);
        alphas = zeros(M3,1);
        betas = zeros(M3,1);
        tStats = zeros(M3,1);
        rSqr = zeros(M3,1);
        resids = nan(T,M3);
        % Order of sequential regression: do first M1 beta factors in the order they appear in bHeader, that is, 
        %   equities, credit, rates, mtgs as your first four, always in that order
        %tIndx = find(rtns(:,n)~=0);
        tIndx = ~isnan(rtns(:,n));
        hfRtn = rtns(tIndx,n)-rfr(tIndx,:);
        strIndx = mapStrings(bHeader,fHeader,false);
        y = hfRtn - rfr;
        for m = 1:M1
            mm = strIndx(m);
            if m ==1
                resids(tIndx,m) = y;
            else
                resids(tIndx,m) = stats.r;
            end
            X = factors(tIndx,mm);
            stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat','r'});
            alphas(m,1) = stats.tstat.beta(1);
            betas(m,1) = stats.tstat.beta(2);
            alphaTstats(n,1) = stats.tstat.t(1);
            tStats(m,1) = stats.tstat.t(2);
            rSqr(m,1) = stats.rsquare;
            y = stats.r;
        end
        rgrsnOrdr(n,1:M1) = 1:M1;
        
        % Now do alt risk premium factors, in the order suggested by a sequence
        %   of univariate regressions:
        strIndx = mapStrings(aHeader,fHeader,false);
        for m = 1:(M2-M1)
            mm = strIndx(m);
            X = factors(tIndx,mm);
            stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat'});
            tempBetas(mm,1) = stats.tstat.beta(2);
            alphaTstats(n,2) = stats.tstat.t(1);
            tStats(mm,1) = stats.tstat.t(2);
            rSqr(mm,1) = stats.rsquare;
            % NOTE: we do not update y, but leave it as the resids from the
            %   first 3 market index regressors
        end
        [~,ordrIndx] = sort(abs(tStats(M1+1:M2,:)),'desc');
        tStats(M1+1:M2,1) = 0; % re-use variable, now with sequential regression value
        rSqr(M1+1:M2,1) = 0; % re-use variable, now with sequential regression value
        
        % do the sequential regression and derive resid returns:
        for m = 1:(M2-M1) % note, m might be = to 1 or 2, but ordrIndx is built off of tStats(M1+1:M2,:), not tStats(1:M2,:)
            mm = ordrIndx(m)+(M2-M1); % first M1 factors are determined in beta logic... second M1+1 to M2 block gets ordered acc. to t-stat
            X = factors(tIndx,mm);
            stats = regstats(y,X,'linear',{'tstat','r','rsquare','dwstat'});
            tThresh = stats.tstat.t(2);
            rgrsnOrdr(n,M1+m) = mm;
            if abs(tThresh) > 0.67
                y = stats.r; % note: if regressor doesn't break t-stat threshold, resids remain unchanged for subsequent factor trial
                alphas(mm,1) = stats.tstat.beta(1);
                betas(mm,1) = stats.tstat.beta(2);
                tStats(mm,1) = stats.tstat.t(2);
                rSqr(mm,1) = stats.rsquare;
            end
        end
        resids = y; % use resids that *only* incorporate significance-tested regressors
        % now evaluate bi-variate exposures to benchmarks: 
        y =  hfRtn - rfr;
        strIndx = mapStrings(bmHeader,fHeader,false);
        for m = 1:(M3-M2)
            mm = strIndx(m);
            X = factors(tIndx,mm);
            stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat'});
            % alphas(mm,1) = stats.tstat.beta(1); % DO NOT INCLUDE BM alphas
            %    into sum of factor exposure means!!!!  These are just
            %    reference values, not part of factor loading analysis!
            betas(mm,1) = stats.tstat.beta(2); 
            tStats(mm,1) = stats.tstat.t(2);
            rSqr(mm,1) = stats.rsquare; 
        end 
        
        alpha(n,1) = sum(alphas(:,1));
        beta(n,:) = betas';
        betaTstats(n,:) = tStats';
        refinedAlphaTS(tIndx,n) = alpha(n,1)+resids; % NOT y... y is for subsequent iteration, not last resids
        betaTS(:,n,1:4) = factors(:,1:M1).*repmat(beta(n,1:4),[T,1]); % NOT y... y is for subsequent iteration, not last resids
        arpTS(:,n,1:4) = factors(:,M1+1:M2).*repmat(beta(n,1:4),[T,1]); % NOT y... y is for subsequent iteration, not last resids
        alphaTstats(n,1) = stats.tstat.t(1);
        betaTstats(n,:) = tStats(:,1)';
    end % for
elseif strcmp(cfg.opt,'blockSequential')
    if adjustForTiming 
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
            if adjustForTiming == true
                yy = y;
                outlierThreshold = 100;
                timingThreshold = 0.05;
                timingFactors = bHeader;
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
                %if iBlock > 1
                   %X = X - repmat(mean(X),[size(X,1),1]); % de-mean regressors: y (a reside) is now de-meaned, too        
                %end
                stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat','r'});
                y = stats.r + stats.tstat.beta(1);
                if iBlock == 1 
                    % TODO: make alphaTS a cell array so that every
                    % regression block generates alphTS. This will affect
                    % downstream code, so we hard-code block number for now.
                    primaryAlphaTS(tIndx,n) = stats.tstat.beta(1) + stats.r;
                    if adjustForTiming
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
                alphas(iBlock,1) = stats.tstat.beta(1);
                betas(blockStart:blockEnd,1) = stats.tstat.beta(2:blockLength+1);
                tStats(blockStart:blockEnd,1) = stats.tstat.t(2:blockLength+1);
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
                stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat'});
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
else % OLS 
    for n = 1:N %
        alphas = zeros(2,1);
        betas = zeros(M3,1);
        tStats = zeros(M3,1);
        rSqr = zeros(2,1);
        
        %tIndx = find(rtns(:,n)~=0);
        tIndx = ~isnan(rtns(:,n));
        y = rtns(tIndx,n) - rfr(tIndx,:);
        strIndx = mapStrings([bHeader,arpHeader],fHeader,false);
        X = factors(tIndx,strIndx); 
        stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat','r'});
        alphas(1,1) = stats.tstat.beta(1);
        betas(1:M2,1) = stats.tstat.beta(2:M+1);
        tStats(1:M2,1) = stats.tstat.t(2:M+1);
        rSqr(n,1) = stats.rsquare;
        resids = stats.r;
        % now evaluate bi-variate exposures to benchmarks: 
        y = rtns(tIndx,n) - rfr(tIndx,:);
        strIndx = mapStrings(bmHeader,fHeader,false);
        for m = 1:(M3-M2)
            mm = strIndx(m);
            X = factors(tIndx,mm); 
            stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat'});
            % alphas(mm,1) = stats.tstat.beta(1); % DO NOT INCLUDE BM alphas
            %    into sum of factor exposure means!!!!  These are just
            %    reference values, not part of factor loading analysis!
            betas(mm,1) = stats.tstat.beta(2); 
            tStats(mm,1) = stats.tstat.t(2);
            rSqr(mm,1) = stats.rsquare; 
        end 
        alpha(n,1) = alphas(:,1);
        beta(n,:) = betas';
        refinedAlphaTS(tIndx,n) = alpha(1,n)+resids; % NOT y... y is for subsequent iteration, not last resids
        betaTS(:,n,1:4) = factors(:,1:4).*repmat(beta(n,1:4),[T,1]); % NOT y... y is for subsequent iteration, not last resids
        arpTS(:,n,1:4) = factors(:,5:8).*repmat(beta(n,1:4),[T,1]); % NOT y... y is for subsequent iteration, not last resids
        alphaTstats(n,1) = stats.tstat.t(1);
        betaTstats(n,:) = tStats(:,1)';
    end % for
end % if 

o.hfHeader = hHeader;
o.factorHeader = fHeader;
o.betaHeader = bHeader;
o.arpHeader = aHeader;
o.bchmHeader = bmHeader;
o.dates = hDates; 
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
if adjustForTiming && strcmp(cfg.opt,'blockSequential')
    % Make sure funds with no timing ability show full column of NaNs
    hasTimingIdx = sum(~isnan(timingRtnMatrix) & timingRtnMatrix ~= 0, 1) >0;
    timingRtnMatrix(:, ~hasTimingIdx) = NaN;
    
    o.timingParamBlock = timingParamBlock; 
    o.timingBetaBlock = timingBetaBlock; 
    o.timingRtnMatrix = timingRtnMatrix;
end 
o.adjustForTiming = adjustForTiming;
end % fn

function o = computeFactorExposures(hHeader,rtns,fHeader,factors,config,opt)
if nargin < 5 || isempty(opt)
   opt = 'OLS';
end 
[T,N] = size(rtns);
[~,M] = size(factors);

% Derive factor exposures through sequential regression: 
bHeader = config.betaHeader; 
aHeader = config.arsHeader; 
M1 = length(bHeader);
M2 = length(aHeader);

rgrssnSqunc = zeros(N,M); 
beta = zeros(N,M); 
alpha = zeros(1,N); 
betaRows = hHeader'; 
betaCols = fHeader; 
alphaTS = zeros(T,N); 
betaTS = zeros(T,N,4); 
altBetaTS = zeros(T,N,4); 

if strcmp(opt,'sequential')
    for n = 1:N %
        tempBetas = zeros(M,1);
        alphas = zeros(M,1);
        betas = zeros(M,1);
        rgrsnOrdr = ones(M,1);
        tStats = zeros(M,1);
        rSqr = zeros(M,1);
        resids = nan(T,M);
        % Determine order of sequential regression: do equities, rates, credit,
        %   mtgs as your first four, always in that order
        tIndx = find(rtns(:,n)~=0);
        hfRtn = rtns(tIndx,n);
        strIndx = mapStrings(fHeader(1,1:4),bHeader(1,1:4));
        y = hfRtn;
        for m = 1:4
            mm = strIndx(m);
            if m ==1
                resids(tIndx,m) = y;
            else
                resids(tIndx,m) = stats.r;
            end
            stats = regstats(y,factors(tIndx,mm),'linear',{'tstat','fstat','rsquare','dwstat','r'});
            alphas(m,1) = stats.tstat.beta(1);
            betas(m,1) = stats.tstat.beta(2);
            tStats(m,1) = stats.tstat.t(2);
            rSqr(m,1) = stats.rsquare;
            y = stats.r;
        end
        rgrssnSqunc(n,1:4) = 1:4;
        
        % Now do alt risk premium factors, in the order suggested by a sequence
        %   of univariate regressions:
        for m = 5:8
            stats = regstats(y,factors(tIndx,m),'linear',{'tstat','fstat','rsquare','dwstat'});
            tempBetas(m,1) = stats.tstat.beta(2);
            tStats(m,1) = stats.tstat.t(2);
            rSqr(m,1) = stats.rsquare;
            % NOTE: we do not update y, but leave it as the resids from the
            %   first 3 market index regressors
        end
        [~,ordrIndx] = sort(abs(tStats(5:8,:)),'desc');
        tStats(5:8,1) = 0; % re-use variable, now with sequential regression value
        rSqr(5:8,1) = 0; % re-use variable, now with sequential regression value
        
        % do the sequential regression and derive resid returns:
        for m = 1:4 % note, m might be = to 4, but ordrIndx is built off of tStats(5:8,:), not tStats(1:8,:)
            mm = ordrIndx(m)+4; % first 4 factors are in fixed sequence... last 4 get ordered acc. to t-stat
            stats = regstats(y,factors(tIndx,mm),'linear',{'tstat','r','rsquare','dwstat'});
            tThresh = stats.tstat.t(2);
            if abs(tThresh) > 0.67
                rgrssnSqunc(n,mm) = mm;
                y = stats.r; % note: if regressor doesn't break t-stat threshold, resids remain unchanged for subsequent factor trial
                alphas(mm,1) = stats.tstat.beta(1);
                betas(mm,1) = stats.tstat.beta(2);
                tStats(mm,1) = stats.tstat.t(2);
                rSqr(mm,1) = stats.rsquare;
            end
        end
        resids = y; % use resids that *only* incorporate significance-tested regressors
        alpha(1,n) = sum(alphas(:,1));
        beta(n,:) = betas';
        alphaTS(tIndx,n) = alpha(1,n)+resids; % NOT y... y is for subsequent iteration, not last resids
        betaTS(:,n,1:4) = factors(:,1:4).*repmat(beta(n,1:4),[T,1]); % NOT y... y is for subsequent iteration, not last resids
        altBetaTS(:,n,1:4) = factors(:,5:8).*repmat(beta(n,1:4),[T,1]); % NOT y... y is for subsequent iteration, not last resids
    end % for
elseif strcmp(opt,'blockSequential')
    for n = 1:N %
        tempBetas = zeros(M,1);
        alphas = zeros(2,1);
        betas = zeros(M,1);
        tStats = zeros(M,1);
        rSqr = zeros(2,1);
        resids = nan(T,M);
        
        tIndx = find(rtns(:,n)~=0);
        y = rtns(tIndx,n);
        strIndx = mapStrings(fHeader(1,1:4),bHeader(1,1:4));
        X = factors(tIndx,strIndx);
        stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat','r'});
        alphas(1,1) = stats.tstat.beta(1);
        betas(1:M1,1) = stats.tstat.beta(2:M1+1);
        tStats(1:M1,1) = stats.tstat.t(2:M1+1);
        rSqr(1,1) = stats.rsquare;
        
        % YOU ARE HERE: Now do alt risk premium factors
        y = stats.r;
        X = factors(tIndx,5:8);
        stats = regstats(y,X,'linear',{'tstat','fstat','rsquare','dwstat'});
            tempBetas(m,1) = stats.tstat.beta(2);
            tStats(m,1) = stats.tstat.t(2);
            rSqr(m,1) = stats.rsquare;
            
        resids = y; % use resids that *only* incorporate significance-tested regressors
        alpha(1,n) = sum(alphas(:,1));
        beta(n,:) = betas';
        alphaTS(tIndx,n) = alpha(1,n)+resids; % NOT y... y is for subsequent iteration, not last resids
        betaTS(:,n,1:4) = factors(:,1:4).*repmat(beta(n,1:4),[T,1]); % NOT y... y is for subsequent iteration, not last resids
        altBetaTS(:,n,1:4) = factors(:,5:8).*repmat(beta(n,1:4),[T,1]); % NOT y... y is for subsequent iteration, not last resids
    end % for
end % if

o.bHeader = bHeader;
o.beta = beta;
o.alpha = alpha;
o.alphaTS = alphaTS;
o.betaTS = betaTS;
o.altBetaTS = altBetaTS;

end % fn

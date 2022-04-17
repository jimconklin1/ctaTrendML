%
%__________________________________________________________________________
%
% This function screens best momenta based on 
% Moskowitz Tobias, Hua Ooi Yao and Lasse Heke Pedersen: 
%"Time Series Momentum", Journal of Financial Economics 04, n.2 (2012), 
% pp. 228:250
%
% Input: 
% close price and date vector (num format)
% lookbackParam: a row vector with different lookback parameters
% holddaysPram: a row vector with different holding days parameters
%
% Output
% mom is a structure
% mom.statRes is a cube, each layer of the cube the result for a specific
% instruments, the first column gives the different lookback and the seocnd
% column the different holding days. The 3rd column gives the
% coefficient of correlation, the 4th, its pvalue.
%lookbackParam = [1 3 4 5 10 21 2*21 3*21 4*21 5*21 6*21 7*21 8*21 9*21 10*21 11*21 12*21 2*12*21];
%holddaysPram = [1 3 4 5 10 21 2*21 3*21 4*21 5*21 6*21 7*21 8*21 9*21 10*21 11*21 12*21];
%
%__________________________________________________________________________
%

function mom = momentumGridSearch(c, dateBench, lookbackParam, holddaysPram)

% -- upload data --
formatDate = 'yyyy-mm-dd'; 
dateBenchhrf = datestr(dateBench, formatDate);
dateBenchhrfd = dateCell2dateDouble(dateBenchhrf);
cl=c;

% -- dimensions & prelocate matrix --
[nsteps,ncols]=size(c);
hts = zeros(1,ncols);
hvr = zeros(1,ncols);
pValuevr = zeros(1,ncols);
cumret = zeros(size(c));
maxDrawdown = zeros(2,ncols);

statRes = zeros(size(lookbackParam,2)*size(holddaysPram,2),4,ncols); % cube
lbJunk = repmat(lookbackParam,size(holddaysPram,2),1);
lbJunk = lbJunk(:); % just use it for output
hdJunk = repmat(holddaysPram',size(lookbackParam,2),1);
paramJunk = [lbJunk , hdJunk];


for j=1:ncols
    % snap
    clSnap = cl(:,j);
    % Correlation tests
    rowCounter = 0;
    for lookback = lookbackParam
        for holddays = holddaysPram
            rowCounter = rowCounter +1;
            % returns
            ret_lag = (clSnap-backshift(lookback, clSnap))./backshift(lookback, clSnap);
            ret_fut = (fwdshift(holddays, clSnap)-clSnap)./clSnap;
            % clean
            badDates=any([isnan(ret_lag) isnan(ret_fut)], 2);
            ret_lag(badDates)=[];
            ret_fut(badDates)=[];
            % extract for correlation analysis
            if (lookback >= holddays)
                indepSet = [1:holddays:length(ret_lag)];
            else
                indepSet = [1:lookback:length(ret_lag)];
            end
            ret_lag = ret_lag(indepSet); 
            ret_fut = ret_fut(indepSet); 
            retComb = [ret_lag,ret_fut]; 
            rowIdx=find(retComb==Inf); retComb(rowIdx,:)=[];
            [ccSnap, pvalSnap] = corrcoef(retComb(:,1), retComb(:,2));
            % print & assign
%             fprintf(1, '%3i\t%3i\t%7.4f\t%6.4f\n',  lookback, holddays, ccSnap(1, 2), pvalSnap(1, 2));
            statRes(rowCounter,3,j) = ccSnap(1, 2);
            statRes(rowCounter,4,j) = pvalSnap(1, 2);
        end
    end
    statRes(:,1:2,j) = paramJunk; %just for ease of reading
    
    % -- Compute Hurst exponent and Variance ratio test ...
    %     ... useful for momenta strategies --
    clSnapJunk = clSnap;
    rowIdx=find(clSnapJunk==0);
    clSnapJunk(rowIdx,:)=[];
    htsSnap = genhurst(log(clSnapJunk), 2);
    fprintf(1, 'H2=%f\n', htsSnap);
    hts(1,j) = htsSnap;

    % Variance ratio test from Matlab Econometrics Toolbox
    [hvrSnap,pValuevrSnap] = vratiotest(log(clSnapJunk));
    hvr(1,j) = hvrSnap;
    pValuevr(1,j) = pValuevrSnap;

%     fprintf(1, 'h=%i\n', hvrSnap); % h=1 means rejection of random walk hypothesis, 0 means it is a random walk.
%     fprintf(1, 'pValue=%f\n', pValuevrSnap); % pValue is essentially the probability that the null hypothesis (random walk) is true.

    % -- Find best combination of lookback x holding period --
    [maxJunk,rowIdx] = max(statRes(:,4,j));
    lookbackBest = statRes(rowIdx,1,j);
    holddaysBest = statRes(rowIdx,2,j);

    % -- extract naive equity curve --
    longs = clSnap  > backshift(lookbackBest, clSnap);
    shorts = clSnap < backshift(lookbackBest, clSnap);
    position = zeros(length(clSnap), 1);
    for h = 0:holddaysBest-1
        % long
        long_lag = backshift(h, longs);
        long_lag(isnan(long_lag)) = false;
        long_lag = logical(long_lag);
        % short
        short_lag = backshift(h, shorts);
        short_lag(isnan(short_lag)) = false;
        short_lag = logical(short_lag);
        %  positions
        position(long_lag) = position(long_lag)+1;
        position(short_lag) = position(short_lag)-1;
    end
    ret = (backshift(1, position).*(clSnap-backshift(1, clSnap))./backshift(1, clSnap))/holddaysBest;
     % Compute cumulated return since 2000
    ret(isnan(ret)) = 0;
    idx=find(dateBenchhrfd == 20000103);
    cumretSnap = cumprod(1+ret(idx:end))-1;
    cumret(idx:end,j) = cumretSnap;
    plot(cumretSnap);
    % Print
%     fprintf(1, 'Avg Ann Ret=%7.4f Ann Volatility=%7.4f Sharpe ratio=%4.2f \n',252*smartmean(ret(idx:end)), sqrt(252)*smartstd(ret(idx:end)), sqrt(252)*smartmean(ret(idx:end))/smartstd(ret(idx:end)));
%     fprintf(1, 'APR=%10.4f\n', prod(1+ret(idx:end)).^(252/length(ret(idx:end)))-1);
     [maxDD, maxDDD]=computeMaxDD(cumretSnap);
%     fprintf(1, 'Max DD =%f Max DDD in days=%i\n\n', maxDD, round(maxDDD));
%     fprintf(1, 'Kelly f=%f\n', mean(ret(idx:end))/std(ret(idx:end))^2);    
    maxDrawdown(1,j) = maxDD;
    maxDrawdown(2,j) = maxDDD;
    
end
% output
 mom.statRes = statRes;
 mom.maxDrawdown = maxDrawdown;
 mom.cumret = cumret;
 mom.hts = hts;
 mom.hvr = hvr;
 mom.pValuevr = pValuevr;

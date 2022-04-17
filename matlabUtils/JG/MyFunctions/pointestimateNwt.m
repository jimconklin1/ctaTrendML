%
%__________________________________________________________________________
%
% Compute the Newey West
% note: for a reaosn I do not epxlain yet, I get a complex number sometimes
%       this is the reason why I use the real part
%__________________________________________________________________________
%

function nwt = pointestimateNwt(c, rowIdx, assetClass, lookback)

[nsteps,ncols] = size(c);
nwt = zeros(1,ncols);

xtime = zeros(lookback,1);
for i=1:lookback
    xtime(i)=i;
end;

% check if intertest rate
if strcmp(assetClass,'irs') || strcmp(assetClass,'rate')
    goLog=0;
else
    goLog=1;
end

for j=1:ncols
    if goLog == 1
        y  = log(c(rowIdx-lookback+1:rowIdx,j));
    elseif goLog == 0
        y  = c(rowIdx-lookback+1:rowIdx,j);
    end
    [b,stats] = robustfit(xtime,y,'ols');
    % Get residuals
    e = stats.resid;
    % NeweyWest
    nwse = NeweyWest(e,xtime,-1,1);
    if size(stats.t,1)==2
        %tstat(i,j) = min(abs(stats.t(2,1)),30); % bound it
        nwt(1,j) = real(b(2,1)) / real((nwse(2,1)));
    else
        %tstat(1,j) = NaN;
        nwt(1,j) = NaN;
    end
end
%
%__________________________________________________________________________
%
% Compute the Newey West
% note: for a reaosn I do not explain yet, I get a complex number sometimes
%       this is the reason why I use the real part
%__________________________________________________________________________
%

function nwt = rollingNwt(c, lookback)

[nsteps,ncols] = size(c);
nwt = zeros(size(c));

xtime = zeros(lookback,1); for i=1:lookback,xtime(i)=i;end;

for j=1:ncols
    for i=lookback+1:nsteps
        y  = log(c(i-lookback+1:i,j));
        [b,stats] = robustfit(xtime,y,'ols');
        % Get residuals
        e = stats.resid;
        % NeweyWest
        nwse = NeweyWest(e,xtime,-1,1);
        if size(stats.t,1)==2
            %tstat(i,j) = min(abs(stats.t(2,1)),30); % bound it
            nwt(i,j) = real(b(2,1)) / real((nwse(2,1)));
        else
            %tstat(i,j) = tstat(i-1,j);
            nwt(i,j) = nwt(i-1,j);
        end
    end
end

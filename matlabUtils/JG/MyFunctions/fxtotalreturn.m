%
%__________________________________________________________________________
%
% Compute FX total return comparing spot and forward
%__________________________________________________________________________
%

function y = fxtotalreturn(lastPrice, fwd, period, method)

[nsteps,ncols] = size(lastPrice); % dimension

switch method
    
    case {'simple', 'arithmetic', 's', 'a'}

        lag_fwd = ShiftBwd(fwd,period,'z');
        y = lastPrice ./ lag_fwd - ones(nsteps,ncols);
        y(y==abs(Inf))=0;
        y(isnan(y))=0;
        y(1:period,:) = zeros(period,ncols);
        
    case {'geo', 'geometric', 'g'}
   
        lag_fwd = ShiftBwd(fwd,1,'z');
        y = lastPrice ./ lag_fwd - ones(nsteps,ncols);
        y(y==abs(Inf))=0;
        y(isnan(y))=0;        
        y(1:period,:) = zeros(period,ncols);
        ytemp = y + ones(size(y));
        
        for i=period:nsteps
            ytempSnap = ytemp(i-period+1:i,:);
            cp = cumprod(ytempSnap,1);
            cpSnap = cp(end,:) .^ (1/period) - ones(1,ncols);
            y(i,:) = cpSnap(1,:);
        end
        
    case {'geoDemeaned', 'geometricDemeaned', 'geodDem', 'geod', 'geodemean', 'geodem', 'gd'}
   
        lag_fwd = ShiftBwd(fwd,1,'z');
        y = lastPrice ./ lag_fwd - ones(nsteps,ncols);
        y(y==abs(Inf))=0;
        y(isnan(y))=0;        
        
        ytemp = y + ones(size(y));
        
        for i=period:nsteps
            ytempSnap = ytemp(i-period+1:i,:);
            cp = cumprod(ytempSnap,1);
            cpSnap = cp(end,:) .^ (1/period) - ones(1,ncols);
            y(i,:) = cpSnap(1,:);
        end
        
        % demean time series
        ytemp = zeros(size(y));
        for i=1
            ytemp(i,:) = y(i,:) - nanmean(y(1:i,:));
        end
        y = ytemp;
        clear ytemp
        
end


function Y = ewmastf(x,Lookback, decay)


%   Y=EWMASTD(X,d) returns the EWMA (Exponentially Weighted Moving Average)
%   standard deviation using the historical returns in vector X and a decay
%   factor, d.
% % ======================================================================
%
%
% % ======================================================================


[nsteps,ncols]=size(x);
Y = zeros(size(x));


% -- Weight --
f = 2/(nbd+1);
%
% -- Compute Exponential Moving Avergae --
for j=1:nbcols
    % .. Step 1: find the first cell to start the code ..
    start_date=zeros(1,1);
    for i=1:nbsteps
        if ~isnan(X(i,j))
            start_date(1,1)=i;
        break               
        end                                 
    end
    if nbsteps > Lookback
        % .. Step 2: First is simple moving average ..
        Y(start_date(1,1) + Lookback-1,j) = mean(X(start_date(1,1):start_date(1,1) + Lookback - 1,j));     
        % .. Step 3: Then Exponential moving average ..
        for k = start_date(1,1) + Lookback :nbsteps
            if ~isnan(X(k,j))
                Y(k,j) = f * X(k,j) + (1-f) * Y(k-1,j);
            else
                Y(k,j) = Y(k-1,j);
            end
        end
    end
end

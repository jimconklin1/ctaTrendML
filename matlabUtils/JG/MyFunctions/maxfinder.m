function [y, c2h] = maxfinder(c,h, method, Lookback)
%
%--------------------------------------------------------------------------
%
% max finder looks for the maximum over a rolling period or since the start
% of the time series
%--------------------------------------------------------------------------
%
y = zeros(size(c));
c2h = zeros(size(c));
[nbsteps,nbcols]=size(y);
%
for j=1:nbcols
    % .. Step 1: find the first cell to start the code ..
    start_date = zeros(1,1);
    for i=1:nbsteps
        if ~isnan(c(i,j)) && ~isnan(h(i,j)) && h(i,j)>0 && c(i,j)>0 
            start_date(1,1) = i;
        break               
        end                                 
    end
    switch method
        case 'rolling'
            if nbsteps > Lookback
                for i = start_date(1,1) + Lookback + 1: nbsteps
                    y(i,j) = max(h(i - Lookback + 1:i-1,j));
                end      
            end
        case 'history'
            for i = start_date(1,1) + 1 :nbsteps
                y(i,j) = max(h(start_date(1,1):i-1,j));
            end
    end
end

for j=1:nbcols
    for i=2:nbsteps
        if c(i,j)>0 && h(i,j)>0 && ~isnan(c(i,j)) && ~isnan(h(i,j)) && y(i,j)>0
            c2h(i,j) = 100 * c(i,j) / y(i,j);
        end
    end
end


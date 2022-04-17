function [y, ty, c2l] = minfinder(c,l, method, Lookback)
%
%--------------------------------------------------------------------------
%
% max finder looks for the minimum over a rolling period or since the start
% of the time series
%--------------------------------------------------------------------------
%
y = zeros(size(c)); ty = zeros(size(c));
c2l = zeros(size(c));
[nbsteps,nbcols]=size(y);
%
for j=1:nbcols
    % .. Step 1: find the first cell to start the code ..
    start_date = zeros(1,1);
    for i=1:nbsteps
        if ~isnan(c(i,j)) && ~isnan(l(i,j)) && l(i,j)>0 && c(i,j)>0 
            start_date(1,1)=i;
        break               
        end                                 
    end
    switch method
        case 'rolling'
            for i=start_date(1,1)+Lookback+1:nbsteps
                y(i,j) = min(l(i-Lookback+1:i-1,j));
            end                
        case 'history'
            for i=start_date(1,1)+1:nbsteps
                y(i,j) = min(l(start_date(1,1):i-1,j));
                if y(i,j)<y(i-1,j), ty(i,j)=i;
                else
                    ty(i,j)=ty(i-1,j);
                end
            end
    end
end

for j=2:nbcols
    for i=1:nbsteps
        if c(i,j)>0 && l(i,j)>0 && ~isnan(c(i,j)) && ~isnan(l(i,j)) && y(i,j)>0
            c2l(i,j) = 100 * c(i,j) / y(i,j);
        end
    end
end

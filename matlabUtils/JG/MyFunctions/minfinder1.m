function [y, ty] = minfinder1(x)
%
%--------------------------------------------------------------------------
%
% max finder looks for the minimum over a rolling period or since the start
% of the time series
%--------------------------------------------------------------------------
%
y = zeros(size(x)); ty = zeros(size(x));
[nbsteps,nbcols]=size(y);
%
for j=1:nbcols
    % .. Step 1: find the first cell to start the code ..
    start_date = zeros(1,1);
    for i=1:nbsteps
        if ~isnan(x(i,j)) && x(i,j)>0 
            start_date(1,1)=i;
        break               
        end                                 
    end

    for i=start_date(1,1)+1:nbsteps
        y(i,j) = min(x(start_date(1,1):i-1,j));
        if y(i,j)<y(i-1,j), ty(i,j)=i;
        else
            ty(i,j)=ty(i-1,j);
        end
    end

end


function t0 = findFirstGood(x,badVal,toler)
% x:  vector
% badVal: [=nan];
% toler:  [=1e-314]; 
% return the first index of x, such that |x(index)-badVal|>toler;

if nargin < 2 || isempty(badVal) 
    badVal = NaN;
end

if nargin < 3 || isempty(toler) 
    toler = 1.0e-314; 
end


T = size(x,1);
t = T; 
N = size(x,2); 
t0 = ones(1,N); 

for n = 1:N
    i = 1;
    goodVal = false;
    if isnan(badVal)
        while ~goodVal && i < T
            if isnan(x(i,n))
                i = i+1;
            else
                t = i;
                goodVal = true;
            end
        end % while
    else
        while ~goodVal && i<T
            if abs(x(i,n) - badVal) <= toler
                i = i+1;
            else
                t = i;
                goodVal = true;
            end
        end % while
    end % for t
    t0(1,n) = t; 
end % for n
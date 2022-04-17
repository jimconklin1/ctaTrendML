function indx = findLastGood(X,badVal,toler)
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

T = size(X,1);
N = size(X,2); 
indx = ones(1,N); 
for n = 1:N
    x = X(:,n);
    t = 1; 
    i = T;
    goodVal = false;
    if isnan(badVal)
        while ~goodVal && i > 1
            if isnan(x(i))
                i = i-1;
            else
                t = i;
                goodVal = true;
            end
        end % while
    else
        while ~goodVal && i>1
            if abs(x(i) - badVal) <= toler
                i = i-1;
            else
                t = i;
                goodVal = true;
            end
        end % while
    end
    indx(1,n) = t;
end % n
end % fn
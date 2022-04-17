function [C, indx] = setdiffJC(A,B)
% C = A(indx) where C is the maximal subset of A such that intersect(C,B) = null
% setdiffJC() is different from Matlab setdiff in that it does not
%   eliminate dupes or order results. 
temp = ~ismember(A,B);
indx = find(temp);
C = A(indx);
end % fn
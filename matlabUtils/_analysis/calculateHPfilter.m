function [gt,ct]=calculateHPfilter(y,lambda) 
%H-P filter, [gt,ct]=hpfilter(yt,lambda), by macro2.org 
if nargin<2 || lambda<0; 
  lambda=1600; % By default, for seasonal data 
end 
y = y(:); % Whatever y was, it becomes a column vector now ! 
T = length(y); 
% Now generating matrix--in the form of sparse matrix. 
mtrx = spdiags(repmat(lambda*[1,-4,6,-4,1]+[0,0,1,0,0],T,1),-2:2,T,T); 
mtrx(1,1:3) = lambda*[1,-2,1]+[1,0,0]; 
mtrx(2,1:4) = lambda*[-2, 5,-4,1]+[0,1,0,0]; 
mtrx(end-1,(end-3):end) = lambda*[1, -4,5,-2]+[0,0,1,0]; 
mtrx(end,(end-2):end) = lambda*[1,-2,1]+[0,0,1]; 
% Solve the equation 
gt = mtrx\y; 
ct = y - gt; 
end % function 

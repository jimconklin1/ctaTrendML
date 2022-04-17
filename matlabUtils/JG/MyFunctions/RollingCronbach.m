function alpha = RollingCronbach(x)
%
%__________________________________________________________________________
%
% Compute the Cronbach's alpha based on the formula here:
%
% http://www.ats.ucla.edu/stat/spss/faq/alpha.html
% alpha = N / (V + (N-1)*C)
% N = number of individual
% V = average variance
% C = average inter-item covariance among the items
% Work in the cross section
% Joel Guglietta - August 2014
%__________________________________________________________________________
%
%

if nargin<1 || isempty(x)==1
   error('You shoud provide a data set.');
else
   % X must be a 2 dimensional matrix
   if ndims(x)~=2
      error('Invalid data set.');
   end
end

N=size(x,2);
alpha=zeros(N,1);

for i=1:N
    covX=cov(x(i,:));
    ColVec_covX=covX(:);
    avgCov=mean(ColVec_covX);
    avgVar=mean(var(x(i,:)));    
    alpha(i) = N*avgCov / (avgVar + (N-1)*avgCov);
end    
 


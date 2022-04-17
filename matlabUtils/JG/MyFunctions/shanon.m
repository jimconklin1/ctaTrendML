function se = shanon(x,lag, rollingperiod)
%
%__________________________________________________________________________
%
% The function computes the shanon entropy over a rolling period
%
% INPUT
% - x             = 'n observations X m assets' matrix
% - lag           = lag for the momentum
% - rollingperiod = rollingperiod is the lookback period to compute the 
%                   rolling entropy
% OUTPUT
% se              = Rolling Shanon Entropy With rolling Summation
%__________________________________________________________________________
%
% -- Prelocate Matrix & Dimensions --
[nsteps,ncols]=size(x);
se=zeros(size(x));
xl=zeros(size(x));
rpdx=zeros(size(x));    lrpdx=zeros(size(x));  
%
% -- Compute Momentum --
xl(lag+1:nsteps,:)=x(1:nsteps-lag,:);
dx = x - xl;
dx(find(dx>0)) = 1; % Keep "+" momentum only
dx(find(dx<0)) = 0; % Recode "-" momentum in 0
%
% -- Compute Probability over rolling period--
for i=rollingperiod:nsteps
    rpdx(i,:) = sum(dx(i-rollingperiod+1:i,:)) / rollingperiod;
end
%
% -- Log base 2 for non-0 pdx (0 otherwise) --
for i=2:nsteps
    for j=1:ncols
        if rpdx(i,j)~=0
            lrpdx(i,j) = log2(rpdx(i,j));
        end        
    end
end
%
% -- Dot product --
drpdx = lrpdx .* rpdx;
%
% -- Shanon entropy --
for i=rollingperiod:nsteps
    se(i,:) = -sum(drpdx(i-rollingperiod+1:i,:)) ;
end

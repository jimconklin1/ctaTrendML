function x = RebuildBackward(x, xtemp)
%
%--------------------------------------------------------------------------
%
% Rebuild time series backward
%--------------------------------------------------------------------------
%
xtempr1d = Delta(xtemp,'roc',1);
nsteps=size(x,1);

for i=1:nsteps
        if ~isnan(x(i)) && x(i)~=0
            startDest(1,1)=i;
        break               
        end                                 
end
for i=1:startDest(1,1)-1
    x(startDest(1,1)-i) = x(startDest(1,1)-i+1)/(1+xtempr1d(startDest(1,1)-i+1));
end
 

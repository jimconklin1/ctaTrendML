
function [yHat, resid, maResid]  = econoModel1(x,y, modelOption,  modelOptionlagDiff, regOption,perEst, maResidPer)
%__________________________________________________________________________
%
% - Input - 
% x
% y
% modelOption: level vs difference
% RegOption: rolling or expanding(static)
% perEst: the period for estimation
 %maResid: the moving aveeage for the residuals
%__________________________________________________________________________

% Prelocate matrices
startDate = findStart(y);
yHat = zeros(size(y));
nsteps = size(y,1);

% Level or difference
if strcmp(modelOption,'level') || strcmp(modelOption,'lev') 
    yy = y;
    xx = x;
elseif strcmp(modelOption,'difference') || strcmp(modelOption,'diff') || strcmp(modelOption,'dif')
    yy = Delta(y,'delta', modelOptionlagDiff);
    xx = Delta(x,'delta', modelOptionlagDiff);
end

% Run model with desired model
for i=startDate+perEst+30:nsteps
    if strcmp(regOption,'rolling') || strcmp(regOption,'Rolling') || strcmp(regOption,'roll')
        ySnap = yy(i-perEst+1:i);
        xSnap = xx(i-perEst+1:i,:);
    elseif strcmp(regOption,'static') || strcmp(regOption,'Static') || strcmp(regOption,'stat') || ...
            strcmp(regOption,'expanding') || strcmp(regOption,'Expanding') || strcmp(RegOption,'exp')
        ySnap = yy(startDate+perEst:i);
        xSnap = xx(startDate+perEst:i,:);
    end
    b = regress(ySnap,xSnap);
    yHat(i) = xSnap(size(xSnap,1),:) * b;
end

% output
resid = yy - yHat;
maResid = expmav(resid, maResidPer);

    
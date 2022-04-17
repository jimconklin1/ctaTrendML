function [yHat, resid, maResid]  = econoModel2(x,y, modelOption,  modelOptionlagDiff, dateBenchNum, periodSignal, perEst, maResidPer)


%__________________________________________________________________________
%
% - Input - 
% x
% y
% dateBenchNum in numeric format
% modelOption: level vs difference
% RegOption: rolling or expanding(static)
% perEst: the period for estimation
% peridSignal: period to compare y and its moving average
 %maResid: the moving aveeage for the residuals
%__________________________________________________________________________

% Prelocate the matrices
startDate = findStart(y);
yHat = zeros(size(y));
may = expmav(y,periodSignal);
yyup = zeros(1,1); yydown = zeros(1,1);
dateup = zeros(1,1); datedown = zeros(1,1);
xup = zeros(1,size(x,2)); xdown = zeros(1,size(x,2));
nsteps = size(x,1);

% Level or difference
if strcmp(modelOption,'level') || strcmp(modelOption,'lev') 
    yy = y;
    xx = x;
elseif strcmp(modelOption,'difference') || strcmp(modelOption,'diff') || strcmp(modelOption,'dif')
    yy = Delta(y,'delta', modelOptionlagDiff);
    xx = Delta(x,'delta', modelOptionlagDiff);
end

for i=1:nsteps
    if y(i)>may(i)
        yyup = [yyup; yy(i)];
        dateup = [dateup; dateBenchNum(i)];
        xup = [xup; x(i,:)];
    else
        yydown = [yydown; yy(i)];
        datedown = [datedown; dateBenchNum(i)];
        xdown = [xdown; x(i,:)];
    end
end
yyup(1,:) = [];    yydown(1,:) = [];
dateup(1,:) = [];  datedown(1,:) = [];
xup(1,:) = [];     xdown(1,:) = [];

for i=startDate+perEst:nsteps
    if y(i) > may(i)
        [rowIdx,colIdx,vIdx] = find(dateup==dateBenchNum(i));        
        if rowIdx > 5
            yHat(i) = yHat(i-1);        
        elseif rowIdx > 5 && rowIdx < perEst
            ySnap = yyup(1:rowIdx,1);
            xSnap = xup(1:rowIdx,:);
            b = regress(ySnap,xSnap);
            yHat(i) = xSnap(size(xSnap,1),:) * b;   
        elseif rowIdx >= perEst
            ySnap = yyup(rowIdx - perEst+1:rowIdx,1);
            xSnap = xup(rowIdx - perEst+1:rowIdx,:);
            b = regress(ySnap,xSnap);
            yHat(i) = xSnap(size(xSnap,1),:) * b;             
        end            
    elseif y(i) <= may(i)
        [rowIdx,colIdx,vIdx] = find(datedown==dateBenchNum(i));
        if rowIdx < 5
            yHat(i) = yHat(i-1);        
        elseif rowIdx > 5 && rowIdx < perEst
            ySnap = yydown(1:rowIdx,1);
            xSnap = xdown(1:rowIdx,:);
            b = regress(ySnap,xSnap);
            yHat(i) = xSnap(size(xSnap,1),:) * b;   
        elseif rowIdx >= perEst
            ySnap = yydown(rowIdx - perEst+1:rowIdx,1);
            xSnap = xdown(rowIdx - perEst+1:rowIdx,:);
            b = regress(ySnap,xSnap);
            yHat(i) = xSnap(size(xSnap,1),:) * b;             
        end
    end
end

% output
resid = yy - yHat;
maResid = expmav(resid, maResidPer);

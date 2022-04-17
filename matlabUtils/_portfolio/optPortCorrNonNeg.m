function optWts = optPortCorrNonNeg(sr,rho,maxAbsCorr,toler) %#ok
% this function finds a simple uncontrained optimum of a portfolio 
%  problem w/ E[rtns] in SR units and a Correlation matrix; no negative 
%  allocations; allocations sum to 1.

mu = sr;
N = size(sr,2); 
temp = unique(rho); 
indx = temp < 0.99;
temp = temp(indx);
if maxAbsCorr < 1
    corrFactor = maxAbsCorr/max(temp);
    for i = 1:length(rho)
        for j = 1:length(rho)
            if i ~= j
                rho(i,j) = corrFactor*rho(i,j);
            end % if 
        end % for 
    end % for 
end % if 
% rIndx = abs(rho)>maxAbsCorr & abs(rho) < (1-toler);
% rho(rIndx)=sign(rho(rIndx))*maxAbsCorr;

invRho = inv(rho);
xTemp = invRho*mu'; %#ok
indx = (xTemp >= 0);
if sum(indx) < length(indx)
    rho2 = rho(indx,indx);
    invRho2 = inv(rho2);
    xTemp2 = invRho2*mu(indx)'; %#ok
    indx2 = (xTemp2 >= 0);
    if sum(indx2) < length(indx2)
        rho3 = rho2(indx2,indx2);
        invRho3 = inv(rho3);
        xTemp3 = invRho3*mu(indx2)'; %#ok
        indx3 = (xTemp3 >= 0);
        if sum(indx3) < length(indx3)
            temp3 = zeros(1,N);
            tIndx3 = find(indx);
            tIndx3 = tIndx3(indx2);
            tIndx3 = tIndx3(indx3);
            temp3(1,tIndx3) = xTemp3(indx3)'/sum(xTemp3(indx3));
            optWts = temp3;
        else
            temp3 = zeros(1,N);
            tIndx3 = find(indx);
            tIndx3 = tIndx3(indx2);
            temp3(1,tIndx3) = xTemp3'/sum(xTemp3);
            optWts = temp3;
        end % if
    else
        temp2 = zeros(1,N);
        temp2(1,indx) = xTemp2'/sum(xTemp2);
        optWts = temp2;
    end % if
else
    optWts = xTemp;
end % if
if size(optWts,1) > size(optWts,2)
   optWts = optWts';
end % if

end % fn
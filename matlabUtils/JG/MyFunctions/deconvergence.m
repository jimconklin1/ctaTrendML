function [cvmaf,mafvmas, spread] = deconvergence(x,periodf, periods, lag)
%
%__________________________________________________________________________
%
% This function computes the Moving Average Confluence indicator.
% INPUT....................................................................
% X                   = price
% periodf   = Minimum period for moving average.
% periods   = Maximum period for moving average.
% lag       = period in order to smooth macs.
% OUTPUT...................................................................
%[cvmaf,mafvmas, spread] = deconvergence(c, 55, 89, 10);
%__________________________________________________________________________
%
% Identify Dimensions------------------------------------------------------
[nsteps,ncols]=size(x);

maf = expmav(x,periodf);
mas = expmav(x,periods);

cvmaf = x ./ maf - ones(size(x));
mafvmas = maf ./ mas - ones(size(x));


for j=1:ncols
    % .. Step 1: find the first cell to start the code ..
    start_date=zeros(1,1);
    for i=1:nsteps
        if ~isnan(x(i,j)) && ~isnan(cvmaf(i,j)) && ~isnan(mafvmas(i,j))
            start_date(1,1)=i;
        break               
        end                                 
    end
    % Clean
    if start_date(1,1) > 1
        cvmaf(1:start_date(1,1)-1,j) = zeros(start_date(1,1)-1,1);
        mafvmas(1:start_date(1,1)-1,j) = zeros(start_date(1,1)-1,1);
    end
end


%spread = zeros(size(c));
%spread = x(lag+1:nsteps,:) - x(1:nsteps-lag,:) - maf(lag+1:nsteps,:) + maf(1:nsteps-lag,:);

spread = Delta(x,'roc',lag) - Delta(maf,'roc',lag) ;

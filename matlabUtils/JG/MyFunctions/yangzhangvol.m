function y = yangzhangvol(o,h,l,c,Lookback)
%
%__________________________________________________________________________
%
% The function expmav computes the Yang Zhang Volatility estimator
% INPUTS:
% - matrix of open, high, low, close
% - Lookback is the period over which the moving average is computed
% OUTPUT:
% - Yang-Zhang volatility estimator
%
%__________________________________________________________________________
 
% -- Prelocate Matris & Identify Dimensions --
y = NaN(size(c));
[nsteps,ncols]=size(y);
%
% Yang-Zhang's k
k = 0.34 / (1.34 + (Lookback+1)/(Lookback-1));
%
for j=1:ncols
    %
    % find the first starting cell (usefull when data is alligned)
    startDate = zeros(1,1);
    for i=1:nsteps
        if ~isnan(o(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i,j)) && ...
                o(i,j)~=0 && h(i,j)~=0 && l(i,j)~=0 && c(i,j)~=0
            startDate(1,1)=i;
        break               
        end                                 
    end
    %
    % Normalise ln(price)
    % note: start @ startDate+1 due to oNorm
    oNorm = log(o(startDate+1:end,j)) - log(c(startDate:end-1,j));
    u = log(h(startDate+1:end,j)) - log(o(startDate+1:end,j));
    d = log(l(startDate+1:end,j)) - log(o(startDate+1:end,j));
    cNorm = log(c(startDate+1:end,j)) - log(o(startDate+1:end,j));
    %
    % 1st component
    x = u .* (u-cNorm) + d .* (d-cNorm);
    Vrs = arithmav(x,Lookback);
    clear x
    %
    % 2nd & 3rd components
    oMu =  arithmav(oNorm,Lookback);
    cMu =  arithmav(cNorm,Lookback);
    Vo=zeros(size(oNorm));
    Vc=zeros(size(oNorm));
    for iii = Lookback:length(cNorm)
        % Vo
        oNormCenteredSnap = oNorm(iii-Lookback+1:iii) - repmat(oMu(iii),Lookback,1);
        oNCS2 = oNormCenteredSnap .* oNormCenteredSnap;
        oNCS2Cumsum = cumsum(oNCS2); 
        Vo(iii) = oNCS2Cumsum(Lookback) / (Lookback-1);
        % Vc
        cNormCenteredSnap = cNorm(iii-Lookback+1:iii) - repmat(cMu(iii),Lookback,1);
        cNCS2 = cNormCenteredSnap .* cNormCenteredSnap;
        cNCS2Cumsum = cumsum(cNCS2);
        Vc(iii) = cNCS2Cumsum(Lookback) / (Lookback-1);
    end
    %   
    % Yang-Zhang estimator
    yz = Vo + k*Vc + (1-k)*Vrs;
    %
    % Assign to final matrix
    y(startDate+1:end,j) = yz;

end
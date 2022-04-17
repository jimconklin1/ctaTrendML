function[nda, nds , snda, ndatp, sumnda] = naivedirection(X,lookback, smooth)
%
%__________________________________________________________________________
%
% This function looks at whether the current price is above or below that 
% of of the start of the lookback window
% INPUT: a matrix of data
%        lookback = a row vector of lags
% OUTPUT
% nda = the raw average contained within the [-1 , +1] interval
% nds = sign(nda)
%
% Note: in the macro-trend model designed by DB Quant, the lag structure is
%       lookback=[10,21,2*21,3*21,4*21,5*21,6*21,9*21,12*21];
%__________________________________________________________________________
%
% -- Dimensions & Parameters & Prelocate Matrices --
[nsteps,ncols] = size(X); 
nda = zeros(size(X)); 
sumnda = zeros(size(X));     
ndatp = zeros(size(X));     
nds = zeros(size(X));
[~,collook] = size(lookback); 
%
for j=1:ncols
    % Find the first cell to start the code
    start_date = zeros(1,1);
    for i=1:nsteps
        if ~isnan(X(i,j)), start_date(1,1)=i;
        break               
        end                                 
    end    
    for i=1+max(lookback)+start_date(1,1):nsteps
        % Prelocate vector for difference
        vdif = zeros(1,collook);
        for u=1:collook
            if X(i,j) > X(i-lookback(1,u),j)
                vdif(1,u) = +1;
            else
                vdif(1,u) = -1;
            end
        end
        % assign
        sumnda(i,j) = sum(vdif);
        nda(i,j) = mean(vdif); 
        nds(i,j) = sign(nda(i,j));      
    end
end
% Moving average of average
snda = arithmav(arithmav(nda, smooth), smooth);
% Turning point
for j=1:ncols
    for i=1+max(lookback)+start_date(1,1):nsteps
        if snda(i-1,j) <  snda(i-2,j)  && snda(i,j) > snda(i-1,j) 
            ndatp(i,j) = +1;
        elseif snda(i-1,j) >  snda(i-2,j) && snda(i,j) < snda(i-1,j) 
            ndatp(i,j) = -1;
        end
    end
end

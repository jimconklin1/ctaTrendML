function[Y] = expmav(X,Lookback)
%
%__________________________________________________________________________
%
% The function expmav computes the exponential moving average
% INPUTS:
% - X is a matrix " 'n' observations * 'p' assets "
% - Lookback is the period over which the moving average is computed
% OUTPUT:
% - exponential moving average
%
%__________________________________________________________________________
 
% -- Prelocate Matris & Identify Dimensions --
Y = zeros(size(X));
[nbsteps,nbcols]=size(Y);
%
% -- Weight --
f = 2 / (Lookback+1);
%
% -- Compute Exponential Moving Avergae --
for j=1:nbcols
    % .. Step 1: find the first cell to start the code ..
    start_date = zeros(1,1);
    for i=1:nbsteps
        if ~isnan(X(i,j)), start_date(1,1)=i;
        break               
        end                                 
    end
    if nbsteps > Lookback
        % .. Step 2: First is simple moving average ..
        Y(start_date(1,1)+Lookback-1,j) = mean(X(start_date(1,1):start_date(1,1)+Lookback-1,j));     
        % .. Step 3: Then Exponential moving average ..
        for k=start_date(1,1)+Lookback:nbsteps
            if ~isnan(X(k,j))
                Y(k,j) = Y(k-1,j) + f * (X(k,j) - Y(k-1,j));
                %Y(k,j) = f * X(k,j) + (1-f) * Y(k-1,j);
            else
                Y(k,j) = Y(k-1,j);
            end
        end
    end
end
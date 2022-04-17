function[tma, wgt] = triangularmav(X,Lookback)
%
%__________________________________________________________________________
%
% The function "triangularmav" computes the Triangular Moving Average 
% according to the formula mentionned in Kaufman, "New Trading Sytems and 
% Methods", Wiley, pp.265-266.
%
% It however seems the Kaufman's formula has a mistake as it does not
% make much sense - and is even wrong for the last point - to change
% the weight between the odd versus even Lookcback period in the way 
% weights are computed
%
% -- INPUTS:
% - X is a matrix " 'n' observations * 'p' assets "
% - Lookback is the period over which the moving average is computed
% -- OUTPUT:
% - triangular  moving average
%__________________________________________________________________________

% -- Prelocate Matrices & Identify Dimensions --
[nbsteps,nbcols] = size(X);
tma = zeros(size(X));
wgt = zeros(Lookback,1);
%
% -- Compute vector of weights --
%  Value till the middle of the window
wgt(1:floor((Lookback+2)/2)) =  (1:1:floor((Lookback+2)/2))';
% -- Case For Even value of Lookback (no need, so same below) --
if rem(Lookback,2) == 0 
    for u = floor((Lookback+2)/2) + 1 : Lookback
        wgt(u,1) = Lookback - u + 1;
    end
% Case For Odd value of Lookback
elseif rem(Lookback,2) == 1 
    for u = floor((Lookback+2)/2) + 1 : Lookback
        wgt(u,1) = Lookback - u + 1;
    end        
end
wgt = wgt / sum(wgt);
%
% -- Triangular Moving Average --
for j=1:nbcols
    % -- Find the first cell to start the code --
    start_date = zeros(1,1);
    for i=1:nbsteps
        if ~isnan(X(i,j)), start_date(1,1)=i;
        break               
        end                                 
    end
    % -- Compute the TMA --
    if nbsteps > Lookback
        for i = start_date(1,1) + Lookback - 1: nbsteps
            if ~isnan(X(i,j))
                tma(i,j) = sum (wgt .* X(i - Lookback + 1:i,j));
            else
                tma(i,j) = tma(i-1,j);
            end
        end
    end
end
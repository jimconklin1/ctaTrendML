function[Y] = HigherMoment(X,method,Period,MinMax)
%
%__________________________________________________________________________
%This function computes the 3rd and 4th moment of the distribution
% INPUT:
% - Variable
% - 'method': . 'skewness'
%             . 'kurtosis'
% MinMax : The code operates a troncature for extreme value
% Skewness: in general Min=-2 - Max = 2
% Kurtosis: in general Min=-3 - Max = 3
%__________________________________________________________________________
%
% Prelocate----------------------------------------------------------------
[nsteps,ncols] = size(X); 
Y = zeros(size(X));
% Compute------------------------------------------------------------------
switch method
    case 'skewness'
    for j=1:ncols
        for i=Period:nsteps
            Y(i,j) = skewness(X(i-Period+1:i,j));
        end
    end
    case 'kurtosis'
    for j=1:ncols
        for i=Period:nsteps
            Y(i,j) = kurtosis(X(i-Period+1:i,j));
        end
    end
end
Y(find(Y<MinMax(1,1))) = MinMax(1,1);
Y(find(Y>MinMax(1,2))) = MinMax(1,2);
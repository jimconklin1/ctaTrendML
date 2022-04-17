function Q = NominalRank(X,method)
%__________________________________________________________________________
%
% This function computes the cardinal ranks of a vector
% It can accept vectors with NaN
% Two methods are available as Matlab & Excel Methodologies give different
% results sometimes:
%                   - 'matlab': gives the Matlab Values
%                   - 'excel': gives the Matlab Values
%__________________________________________________________________________

% PRELOCATE MATRIX & DIMESNIONS--------------------------------------------
s = size(X);
if s(1) > 1 && s(2) > 1
   error('X must be a vector')
end
n = length(X);  Z = X(~isnan(X)); p = length(Z);
rank_Y = zeros(p,1); rank_X = zeros(p,1);

% STEP 1-------------------------------------------------------------------
Y = sort(Z);
for i=1:p, rank_Y(i) = i; end
Z_output = [ Y, rank_Y];
% STEP 2-------------------------------------------------------------------
switch method
    case 'matlab'
    for i=1:n
        if ~isnan(X(i)), target = X(i);
            for k=1:p
                if target == Z_output(k,1)
                    rank_X(i) = Z_output(k,2); 
                end
            end
        else
            rank_X(i) = NaN;
        end
    end
    case 'excel'
     for i=2:p
         if Z_output(i,1)==Z_output(i-1,1)
            Z_output(i,2)=Z_output(i-1,2);
         end
     end
    for i=1:n
        if ~isnan(X(i)), target = X(i);
            for k=1:p
                if target == Z_output(k,1)
                    rank_X(i) = Z_output(k,2);
                end
            end
        else
            rank_X(i) = NaN;
        end
    end
end
% Assign
Q=rank_X;
% STEP 2: CLEAN IF DUPLICATE-----------------------------------------------
fixOrder = 0;
[tmpSortedArr tmpSortIdx] = sort(Q);
for loop=2:size(Q,2)
    if (Q(tmpSortIdx(loop)) == Q(tmpSortIdx(loop-1)) && ~isnan(Q(tmpSortIdx(loop))))    % Two elements the same
        fixOrder = 1;
        for loop2=loop:size(Q,2)
            if (~isnan(Q(tmpSortIdx(loop2))))
                Q(tmpSortIdx(loop2)) = Q(tmpSortIdx(loop2))+1;
            end
        end
    end
end
if (fixOrder == 1)
    counter = 2;
    for loop=2:size(Q,2)
        if (~isnan(Q(tmpSortIdx(loop))))
            Q(tmpSortIdx(loop)) = counter;
            counter = counter + 1;
        end
    end
end     

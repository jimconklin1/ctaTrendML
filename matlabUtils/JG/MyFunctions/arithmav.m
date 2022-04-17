function[Y] = arithmav(X,nbd)

%__________________________________________________________________________
% The function expmav computes the arithmetic moving average
% Parameters:
% - X is a matrix m*n
% - nbd is the period over which the moving average is computed
%__________________________________________________________________________

%The function expmav computes the arithmetic moving average
% X is a m*n matrix
% nbd is the period over which the moving average is computed
Y = zeros(size(X));
[nbsteps,nbcols]=size(Y);
for j=1:nbcols
    % find the first cell to start the code
    start_date=zeros(1,1);
    for i=1:nbsteps
        if ~isnan(X(i,j))
            start_date(1,1)=i;
        break
        end
    end
    % Moving average
    for k=start_date(1,1)+nbd-1:nbsteps
        Y(k,j)=mean(X(k-nbd+1:k,j));
    end
end
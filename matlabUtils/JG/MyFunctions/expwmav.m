function[ewma] = expwmav(X,lambda)
%
%__________________________________________________________________________
%
% The function EXPWMAV computes the exponential weighted moving average
% INPUTS:
% - X :a matrix " 'n' observations * 'p' assets "
% - lambda: a decay factori
%   note: the half-life and lambda are normaly linked through the relation
%   hal-life = log(2)/lambda.
% OUTPUT:
% - exponential weighted moving average (ewma).
% note: the EWMA is 'projective', the simple Exponential  Moving Average is
% just a smoothing device.
%__________________________________________________________________________

% -- Prelocate Matris & Identify Dimensions --
ewma = zeros(size(X));
[nbsteps,nbcols]=size(ewma);
%
% -- Compute Exponential Moving Avergae --
for j=1:nbcols
    % .. Step 1: find the first cell to start the code ..
    start_date=zeros(1,1);
    for i=1:nbsteps
        if ~isnan(X(i,j))
            start_date(1,1)=i;
        break               
        end                                 
    end
    if start_date(1,1)<nbsteps
        % .. Step 2: First is simple moving average ..
        ewma(start_date(1,1),j) = X(start_date(1,1),j);     
        % .. Step 3: Then Exponential moving average ..
        for t=start_date(1,1)+1:nbsteps
            if ~isnan(X(t,j))
                ewma(t,j) = lambda * ewma(t-1,j) + (1-lambda) * X(t-1,j);
            else
                ewma(t,j)=emaw(t-1,j);
            end
        end
    end
end


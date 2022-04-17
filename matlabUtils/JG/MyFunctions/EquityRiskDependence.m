function[F] = EquityRiskDependence(c, tdayc,  risk, tdayrisk, lookback)
%__________________________________________________________________________
% This function computes the percentile ranks of a vector
% It can accept vectors with Nan
% method = 'matlab'is the old Matlab output
% method = 'excel' gives the excel outpout
%__________________________________________________________________________
%
% DIMENSION & PRELOCATE----------------------------------------------------
[nsteps,ncols]=size(c);

% merge data

% extract tail risk

% rank correlation

s = size(X);
if s(1) > 1 && s(2) > 1
   error('X must be a vector')
end
n = length(X);  Z = X(~isnan(X)); p = length(Z);
rank_Y = zeros(p,1); rank_X = zeros(p,1);
Y = sort(Z);
    for i=1:p, rank_Y(i) = 100/(p-1) * (i-1); end
    Z_output = [Y, rank_Y];
% MAIN LOOP----------------------------------------------------------------
switch method
    case 'matlab'
        for i=1:n
            if ~isnan(X(i)), target = X(i);
                for k=1:p
                    if target == Z_output(k,1), rank_X(i) = Z_output(k,2); end
                end
            else
            rank_X(i) = NaN;
            end
        end

    case 'excel'
        for i=2:p
            if Z_output(i,1)==Z_output(i-1,1);
                Z_output(i,2)=Z_output(i-1,2);
            end
        end
        for i=1:n
            if ~isnan(X(i)), target = X(i);
                for k=1:p
                    if target == Z_output(k,1), rank_X(i) = Z_output(k,2); end
                end
            else
            rank_X(i) = NaN;
            end
        end   
end
% ASSIGN-------------------------------------------------------------------
F=rank_X;
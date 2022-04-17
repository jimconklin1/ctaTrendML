%
%__________________________________________________________________________
%
% This function is used in the Maximium Diversified Portfolio Script
%
% LegendreShiftPoly function
%
% Based on recurrence relation:
% (n+1)Pn+1(x) - (1+2n)(2x-1)Pn(x) + nPn-1(x) = 0
% Given non-negative integer n, compute the Shifted Legendre polynomial
% P_n.
% Return the result as a vector whose mth element is the coeeficient of
% x^(n+1-m).
% polyval(LegendreShiftPoly(n),x) evaluate P_n(x)
%
%__________________________________________________________________________
%
%
function pk = LegendreShiftPoly(n)
    
    if n == 0
        pk = 1;
    elseif n == 1
        pk = [2 , -1]';
    else
        
        pkm2 = zeros(n+1,1);
        pkm2(n+1,1) = 1;
        pkm1 = zeros(n+1,1);
        pkm1(n+1,1) = -1;
        pkm1(n,1) = 2;
        
        for k = 2: n
            
            pk = zeros(n+1,1);
            
            for e = n-k+1:n
                pk(e) = (4*k-2)*pkm1(e+1,1) + (1-2*k) * pkm1(e,1) + (1-k) * pkm2(e,1);
            end
                                        
            pk(n+1) = (1-2*k) * pkm1(n+1,1) + (1-k) * pkm2(n+1,1);
            pk = pk / k;

            if k < n
                pkm2 = pkm1;
                pkm1 = pk;
            end
            
        end 
    end
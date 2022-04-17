function[r,sr] = WilliamsR(c,h,l,LookbackPeriod,SmoothR)
%__________________________________________________________________________
%
% The function computes the Williams R% which is - grossly - the
% inverse of the of Stochastic
%
% MODEL--------------------------------------------------------------------
% R = (Highest High - Close)/(Highest High - Lowest Low) * -100
% Lowest Low = lowest low for the look-back period
% Highest High = highest high for the look-back period
% R is multiplied by -100 correct the inversion and move the decimal.
%
% INPUT--------------------------------------------------------------------
% LookbackPeriod = Look-back period for lowest low and highest high
% SmoothR = Period to smooth R
%
% OUTPUT-------------------------------------------------------------------
% The model computes
% r = Williams R% 
% sr = the smoothed Williams R% 
%
% DIFFERENT SET UP---------------------------------------------------------
% Bloomberg default: 20,5,5,3
% Wikepdeia: typical values for look-back period are 5, 9, or 14 periods.
%             Smoothing the indicator over 3 periods is standard
%__________________________________________________________________________

% -- Dimensin & Prelocate Matrices --
[nsteps,ncols] = size(c); 
x = zeros(size(c)); r = zeros(size(c)); 
%
for j=1:ncols
    % -- Find the first cell to start the code --
    for i=1:nsteps
        if ~isnan(c(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j))
            start_date=i;
            break
        end
    end 
    for i=LookbackPeriod+start_date-1:nsteps
        % -- Define the range --
        MaxH = max(h(i-LookbackPeriod+1:i,j));
        MinL = min(l(i-LookbackPeriod+1:i,j));
        x(i,j) = MaxH - MinL;
        % -- Compute R% Williamson --
        if ~isnan(x(i,j)) && x(i,j)>0
            r(i,j) = -100*(MaxH-c(i,j)) / x(i,j);
        else
            r(i,j) = r(i-1,j);
        end
    end
end
%
% -- Cap R% Williamson --
r(find(r<-100)) = -100;
r(find(r>0)) = 0;                   
% -- Smoothed R --
sr=expmav(r,SmoothR);
function y = closelocvalue(c,h,l)
%__________________________________________________________________________
%
%The function computes the Stochastic
%
% MODEL--------------------------------------------------------------------
% The Close Location Vlaue is one of the indicators using the location of
% Close related to Low and High for the same period.
% It is trying to spot the tendency in the proce move of the security.
%
% INPUT--------------------------------------------------------------------
% LookbackPeriod = Look-back period for lowest low and highest high
% SmoothK = Period to smooth K which gives D
% SmoothD = Period to smooth K which gives DS
%
% OUTPUT-------------------------------------------------------------------
% The model computes
% K = Fast K
% D = Fast D
% SD= Slow D
%
% DIFFERENT SET UP---------------------------------------------------------
% Bloomberg default: 20,5,5,3
% Wikepdeia: typical values for look-back period are 5, 9, or 14 periods.
%             Smoothing the indicator over 3 periods is standard
%__________________________________________________________________________

% DIMENSION & PRELOCATE MATRIX---------------------------------------------
[nsteps,ncols] = size(c); 
y = zeros(size(c)); 
%
for j=1:ncols
    % -- Find the first cell to start the code --
    for i=1:nsteps
        if ~isnan(c(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j))
            start_date=i;
            break
        end
    end 
    % -- computer close location value --
    y(start_date:nsteps,j)= (( c(start_date:nsteps,j) - l(start_date:nsteps,j) ) - ...
                             ( h(start_date:nsteps,j) - c(start_date:nsteps,j) )) ./ ...
                             ( h(start_date:nsteps,j) - l(start_date:nsteps,j) )  ;
end
%              

function z = FractalReversalSnap(x, period)
%__________________________________________________________________________
%
% Another version for a "variance-ratio", "Hurst-exponent"
% inspired indicator
%
%__________________________________________________________________________

% -- load Fisher table according to critical value  --
[nsteps,ncols] = size(x);
z = zeros(1,ncols);

% -- 1-day log return --
xlag = ShiftBwd(x,1, 'z');
y = abs(log(x./xlag)); y(y == Inf) = 0; 

% -- n-day log return --
xlagn = ShiftBwd(x,period, 'z');
yn = log(x./xlagn); yn(yn == Inf) = 0; 

for j=1:ncols
    Ni = sum(y(nsteps-period:nsteps,j)) / (abs(yn(nsteps,j)) / period);
    z(1,j) = log(Ni) / log(period);
    if abs(z(1,j))==Inf, z(1,j)=NaN; end       
end

function[pdi, mdi, adx] = ADXFunction(h, l, c, Lookback_Period)
%
%__________________________________________________________________________
%
% This function computes the AVERAGE DIRECTIONAL INDEX (Wilder)
% It makes use the function "ADXOneAsset" below
%
% It computes +Di, -Di and ADX it for a basket of p assets
% (matrix of "n" rows (time stamps) by "p" columns (nb. of assets)).
%
% INPUT:
% - High, Low, Close
% - Lookback Period
% OUTPUT: - PDI (Plus Directional Index, +DI)
%         - MDI (Minus Directional Index, -DI)
%         - ADX (Average Directional Index)
%
% -- Comments --
% According to Wilder, the more directional the movement of a commodity or
% stock, the greater will be the difference between +DI(14 periods) and
% -DI(14 periods). 
% You go long (short) when +DI(14) crosses over (below) -DI(14).
% You only trade those markets that are high on a (positive only) ADX
% scale.
% LeBeau and Lucas review Wilder's work and conclude that the slope of the
% ADX is of greater importance than its level. A rising ADX indicates a
% strong trend is in process and that trend-following trading techniques
% should be used.
% They also conclude that a falling ADX indicates a trendless market and
% that countertrend strategies (such as overbought and oversold strategies)
% should be applied. No action can be your favor strategy then.
%__________________________________________________________________________
%
% -- Dimensins & Prelocate Matrices --
[nsteps,ncols] = size(c); 
clear nsteps
pdi = zeros(size(c));
mdi = zeros(size(c));
adx = zeros(size(c));
% -- Compute +DI, -DI, ADX --
for j=1:ncols
    [pdi(:,j),mdi(:,j),adx(:,j)] = ADXOneAsset(h(:,j),l(:,j),c(:,j),Lookback_Period);
end 

% Clean
pdi(find(pdi == Inf)) = 0;
pdi(find(pdi == -Inf)) = 0;
pdi(find(isnan(pdi))) = 0;
mdi(find(mdi == Inf)) = 0;
mdi(find(mdi == -Inf)) = 0;
mdi(find(isnan(mdi))) = 0;
adx(find(adx == Inf)) = 0;
adx(find(adx == -Inf)) = 0;
adx(find(isnan(adx))) = 0;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [pdi,mdi,adx] = ADXOneAsset(H,L,C,lag_dm)

%__________________________________________________________________________
%
% AVERAGE DIRECTIONAL INDEX
%
% This function computes pdi (+DI), mdi(-DI) and ADX for one and only asset.
% note: this function is never used as such, but always as a component 
% of ADXFunction
%
% Parameters :
% i) Time series is "n rows" (time stamp) and 4 columns (Open, High, Low, Close).
% ii) Un lag représentant le lissage choisi
%__________________________________________________________________________
%

% -- Identify dimensions, Prelocate Matrices --
n = length(C);
H1=H; L1=L; C1=C;
for i=1:n
    if isnan(H1(i,1)), H1(i,1)=0; end
    if isnan(L1(i,1)), L1(i,1)=0; end
    if isnan(C1(i,1)), C1(i,1)=0; end    
end

% -- 1. Compute +DM / -DM --
%n = length(C);
nt = lag_dm;
 
dH = diff(H1);
dH = [0;dH];
pdm = max(dH,0);
 
dL = -diff(L1);
dL = [0;dL];
mdm = max(dL,0);
 
% -- 2. Compute +DMn / -DMn --
pdmn = zeros(n,1);
mdmn = zeros(n,1);
% "Plus" movements
pdmn(1:nt-1) = NaN;
pdmn(nt) = sum(pdm(1:nt));
I = (nt+1:n);
for i = I
  pdmn(i) = ((nt-1)/nt)*pdmn(i - 1) + pdm(i);
end
% "Minus" movements
mdmn(1:nt-1) = NaN;
mdmn(nt) = sum(mdm(1:nt));
for i = I
  mdmn(i) = ((nt-1)/nt)*mdmn(i-1) + mdm(i);
end
 
% -- 3. Compute True Range --
tr = zeros(n,1);
I = 2:n;
for i = I
    tr(i) = max( [abs(H1(i) - L1(i)), abs(H1(i) - C1(i-1)), abs(L1(i) - C1(i-1))] );
end
trn = zeros(n,1);
trn(1:lag_dm-1) = NaN;
trn(lag_dm) = sum(tr(1:lag_dm));
I = (lag_dm+1:n);
for i = I
  trn(i) = ((nt-1)/nt)*trn(i - 1) + tr(i);
end
 
% -- 4. Compute +DI, -DI --
pdi = pdmn./trn*100;
mdi = mdmn./trn*100;
 
% -- 5. Compute DXn --
dx = floor((abs(pdi - mdi)./(pdi + mdi))*100);
% Clean dx (absent in the initial code)
for i=1:n
    if isnan(dx(i))
        dx(i)=0;
    end
end
 
% -- 6. Compute ADX --
adx = zeros(n,1);
adx(1:2*(nt-1)) = NaN;
adx(2*nt-1) = (1/nt)*sum(dx(nt:2*nt-1));
I = 2*nt:n;
for i = I
  adx(i) = ((nt - 1)*adx(i-1) + dx(i))/nt;
end
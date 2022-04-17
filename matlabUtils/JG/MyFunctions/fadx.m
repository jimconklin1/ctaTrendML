function [pdi,mdi,adx] = fadx(H,L,C,lag_dm)

%__________________________________________________________________________
%
% AVERAGE DIRECTIONAL INDEX
%
% This function compute pdi (+DI), mdi(-DI) and adx.
%
% Parameters :
% i) Time series is "n rows" (time stamp) and 4 columns (Open, High, Low, Close).
% ii) Un lag représentant le lissage choisi
%__________________________________________________________________________
%

% identify dimensions, Assign & Clean
n = length(C);
H1=H; L1=L; C1=C;
for i=1:n
    if isnan(H1(i,1)), H1(i,1)=0; end
    if isnan(L1(i,1)), L1(i,1)=0; end
    if isnan(C1(i,1)), C1(i,1)=0; end    
end

% (1) Calcul du +DM / -DM
%n = length(C);
nt = lag_dm;
 
dH = diff(H1);
dH = [0;dH];
pdm = max(dH,0);
 
dL = -diff(L1);
dL = [0;dL];
mdm = max(dL,0);
 
% (2) Calcul du +DMn / -DMn
pdmn = zeros(n,1);
mdmn = zeros(n,1);
 
% Partie "plus"
pdmn(1:nt-1) = NaN;
pdmn(nt) = sum(pdm(1:nt));
I = (nt+1:n);
for i = I
  pdmn(i) = ((nt-1)/nt)*pdmn(i - 1) + pdm(i);
end
 
% Partie "moins"
mdmn(1:nt-1) = NaN;
mdmn(nt) = sum(mdm(1:nt));
for i = I
  mdmn(i) = ((nt-1)/nt)*mdmn(i-1) + mdm(i);
end
 
% -- (3) Compute True Range --
tr = zeros(n,1);
 
I = 2:n;
for i = I
    tr(i) = max( [abs(H1(i) - L1(i)), abs(H1(i) - C1(i-1)), abs(L1(i) - C1(i-1))] );
end
 
% (4) Calcul de trn
trn = zeros(n,1);
trn(1:lag_dm-1) = NaN;
trn(lag_dm) = sum(tr(1:lag_dm));
I = (lag_dm+1:n);
for i = I
  trn(i) = ((nt-1)/nt)*trn(i - 1) + tr(i);
end
 
% (5) Calcul de +DI, -DI
pdi = pdmn./trn*100;
mdi = mdmn./trn*100;
 
% (6) Calcul de DXn
dx = floor((abs(pdi - mdi)./(pdi + mdi))*100);
% Clean dx (absent in the initial code)
for i=1:n
    if isnan(dx(i))
        dx(i)=0;
    end
end
 
% (7) Calcul de l'ADX
adx = zeros(n,1);
adx(1:2*(nt-1)) = NaN;
adx(2*nt-1) = (1/nt)*sum(dx(nt:2*nt-1));
I = 2*nt:n;
for i = I
  adx(i) = ((nt - 1)*adx(i-1) + dx(i))/nt;
end
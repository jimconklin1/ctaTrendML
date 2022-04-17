function Mimf = TrendFromSimpleEMD(x)

% Extract size
[ncols,nsteps]=size(x);

% Compute EMD
imf = EMDSimple(x);

% Extracte size imf
Nbimf=size(imf,2);
% Prelocate Cube
%Mimf=zeros(nsteps,Nbimf);
% Assign
Mimf=imf{1}';
for u=2:Nbimf
    Mimf=[Mimf , imf{u}'];
end

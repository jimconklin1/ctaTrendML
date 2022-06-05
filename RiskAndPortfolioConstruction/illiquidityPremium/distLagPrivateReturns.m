function p = distLagPrivateReturns(assetClass)
if nargin < 1
    assetClass = 'pe';
elseif isempty(assetClass)
    assetClass = 'pe';
end

switch assetClass
    case 'pe'
        phi = [0.6, 0.17, 0.23, 0, 0, 0,0,0,0,0]; 
    case 're'
        phi = [0.25, 0.2, 0.18, 0.15,0.22, 0,0,0,0,0]; 
    case 'infra'
        phi = [0.48, 0.3, 0.22, 0, 0, 0,0,0,0,0]; 
    case 'debt'
        phi = [0.5, 0.35, 0.15, 0, 0, 0,0,0,0,0]; 
end
psi(1) = 1;
psi(2) =  -(phi(2)*psi(1));
psi(3) =  -(phi(2)*psi(2)+phi(3)*psi(1));
psi(4) =  -(phi(2)*psi(3)+phi(3)*psi(2)+phi(4)*psi(1));
psi(5) =  -(phi(2)*psi(4)+phi(3)*psi(3)+phi(4)*psi(2)+phi(5)*psi(1));
psi(6) =  -(phi(2)*psi(5)+phi(3)*psi(4)+phi(4)*psi(3)+phi(5)*psi(2)+phi(6)*psi(1));
psi(7) =  -(phi(2)*psi(6)+phi(3)*psi(5)+phi(4)*psi(4)+phi(5)*psi(3)+phi(6)*psi(2)+phi(7)*psi(1));
psi(8) =  -(phi(2)*psi(7)+phi(3)*psi(6)+phi(4)*psi(5)+phi(5)*psi(4)+phi(6)*psi(3)+phi(7)*psi(2)+phi(8)*psi(1));
psi(9) =  -(phi(2)*psi(8)+phi(3)*psi(7)+phi(4)*psi(6)+phi(5)*psi(5)+phi(6)*psi(4)+phi(7)*psi(3)+phi(8)*psi(2)+phi(9)*psi(1));
psi(10) = -(phi(2)*psi(9)+phi(3)*psi(8)+phi(4)*psi(7)+phi(5)*psi(6)+phi(6)*psi(5)+phi(7)*psi(4)+phi(8)*psi(3)+phi(9)*psi(2)+phi(10)*psi(1));

psi = psi/phi(1);
p.phi = phi;
p.psi = psi;
end 




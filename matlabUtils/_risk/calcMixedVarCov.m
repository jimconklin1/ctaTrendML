function omega = calcMixedVarCov(rho,vol)
omega = zeros(size(rho)); 
for t = 1:length(rho) 
   volVec = vol(t,:); 
   omega(:,:,t) = rho(:,:,t).*(volVec'*volVec); 
end % for t
end 
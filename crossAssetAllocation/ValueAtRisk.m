function vatr = ValueAtRisk(mu,sigma,skew,kurt,alpha)
%Standardize
k2 = sigma*sigma;
k3 = skew/sigma^3;
k4 = kurt/sigma^4-3;

z=norminv(alpha);
vatr = z+(z.*z-1)/6*k3+(z.^3-3*z)/24*k4-(2*z.^3-5*z)/36*k3*k3;
vatr = mu+vatr*sigma;
vatr =max(-vatr,0.0);

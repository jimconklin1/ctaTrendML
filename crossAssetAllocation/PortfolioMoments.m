function [Mup,Vp, Sp, Kp] = PortfolioMoments(mus, covar,coskew,cokur,weights)

Mup = weights'*mus;
Vp = weights'*covar*weights;
Sp = weights'*coskew*Kronecker(weights,weights);
Kp = weights'*cokurt*Kronecker(weights,Kronecker(weights,weights));

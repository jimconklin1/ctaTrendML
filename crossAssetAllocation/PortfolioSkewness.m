function Sp = PortfolioSkewness(coskew,weights)
Sp = weights'*coskew*Kronecker(weights,weights);


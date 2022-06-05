function Kp = PortfolioKurtosis(cokurt,weights)
Kp = weights'*cokurt*Kronecker(weights,Kronecker(weights,weights));

function u=ExponentialUtility(lambda,mu, covar,coskew,cokurt,periods, w)

mup = mu'*w*periods;
varp = (w'*covar*w)*periods;
skewp = PortfolioSkewness(coskew,w)*periods;
kurtp = PortfolioKurtosis(cokurt,w)*periods+3*periods*(periods-1)*(w'*covar*w)^2;

u=-exp(-lambda*mup)-1/2*lambda*lambda*exp(-lambda*mup)*varp+1/6*lambda^3*exp(-lambda*mup)*skewp-1/24*lambda^4*exp(-lambda*mup)*kurtp;

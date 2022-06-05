function u=LogUtility(mu, covar,coskew,cokurt,periods, w)

mup = mu'*w*periods;
varp = (w'*covar*w)*periods;
skewp = PortfolioSkewness(coskew,w)*periods;
kurtp = PortfolioKurtosis(cokurt,w)*periods+3*periods*(periods-1)*(w'*covar*w)^2;

u=log(1+mup)-1/2/(1+mup)^2*varp+1/3/(1+mup)^3*skewp-1/4/(1+mup)^4*kurtp;

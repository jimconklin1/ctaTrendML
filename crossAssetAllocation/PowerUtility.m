function u=PowerUtility(gamma, mu, covar,coskew,cokurt,periods, w)

if gamma == 1
    u = LogUtility(mu,covar,coskew,cokurt,periods,w);
    return;
end

mup = mu'*w*periods;
varp = (w'*covar*w)*periods;
skewp = PortfolioSkewness(coskew,w)*periods;
kurtp = PortfolioKurtosis(cokurt,w)*periods+3*periods*(periods-1)*(w'*covar*w)^2;

%u = ((0.25+mup)^(1-gamma)-1)/(1-gamma) - 0.5*gamma*(0.25+mup)^(-gamma-1)*varp + 1/6*gamma*(gamma+1)*(0.25+mup)^(-gamma-2)*skewp - 1/24*gamma*(gamma+1)*(gamma+2)*(0.25+mup)^(-gamma-3)*kurtp;
u=((1+mup)^(1-gamma)-1)/(1-gamma)-0.5*gamma*(1+mup)^(-gamma-1)*varp+1/6*gamma*(gamma+1)*(1+mup)^(-gamma-2)*skewp-1/24*gamma*(gamma+1)*(gamma+2)*(1+mup)^(-gamma-3)*kurtp;
end 
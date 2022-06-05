function u=QuadraticUtility(lambda, mu, covar,periods, w)

mup = w'*mu*periods;
u = mup-0.5*lambda(w'*covar*w*periods+mup*mup);
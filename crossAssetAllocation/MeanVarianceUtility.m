function u=MeanVarianceUtility(lambda, mu, covar,periods, w)

u = (w'*mu-0.5*lambda*w'*covar*w)*periods;

end 
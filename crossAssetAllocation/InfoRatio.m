function u=InfoRatio(lambda, mu, covar,periods, w)

u = sqrt(12/periods)*(w'*mu)/sqrt(w'*covar*w);
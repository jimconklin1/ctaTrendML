%
%__________________________________________________________________________
% GRC portfolio.
%
% 
%__________________________________________________________________________ 

  sigma = [ 0.1; 0.2; 0.3; 0.4] ; 
  
  rho = [ 1.0 0.8  0.0  0.0 ; 
          0.8 1.0  0.0  0.0 ; 
          0.0 0.0  1.0 -0.5 ; 
          0.0 0.0 -0.5  1.0 
        ] ; 
  
  expCov = corr2cov(sigma, rho) ; 
  
  RiskWeights = [0.4; 0.3; 0.1; 0.2] ;

  InverseRiskWeights = 1./ RiskWeights ; 
  
  Ndim = length(sigma) ; 
  
  Aeq = ones(1,Ndim);
  Beq = 1;
  
  lbnds = zeros(Ndim,1);
  ubnds = ones (Ndim,1);
  
  qoptions = optimset('Display','iter', ...
                      'LargeScale','off', ...
                      'TolFun', 1e-20);
  
  qoptions = optimset('Display', 'iter', ...
                      'Algorithm','interior-point', ...
                      'MaxFunEvals', 500000, ...
                      'TolFun', 1e-20) ; 
  
  n1 = 1.0/Ndim;
  
  w0 = repmat(n1, Ndim, 1) ; % w0 = n1*ones(Ndim,1); 
  
  NLLfunction = @(w) fm_fitnessGRC(expCov, InverseRiskWeights, w) ; 
  
  [w, fval, sqpExit] = fmincon(NLLfunction, w0, ...
                               [], [], Aeq, Beq, lbnds, ubnds, [], ...
                               qoptions) ; 
  
  w; 
  s  = sqrt(w'*expCov*w)  ;
  c  = w .* ( expCov*w/sqrt(w'*expCov*w) );
  si = c / s; 
 
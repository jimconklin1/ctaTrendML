%
%__________________________________________________________________________
% ERC portfolio.
%
% Farid Moussaoui
% farid.moussaoui at gmail.com
% 
%__________________________________________________________________________

tic
  
  load dowData ; 
    
  prices = num ; 
  
  % prices(1,:)     : DJIA index prices 
  % prices(2:end,:) : Stocks prices 
  
  % tick2ret & geom2arith are available in the finance toolbox
  
  returns = tick2ret(prices,[],'continuous');
  numReturns = size(returns,1);
  
  [annualRet, annualCov] = geom2arith(mean(returns),cov(returns),numReturns);
  
  annualRet = annualRet';
  annualStd = sqrt(diag(annualCov));
  
  indexRet = annualRet(1) ;            % DJIA return 
  indexStd = annualStd(1) ;            % DJIA standard deviation 
  
  expRet  = annualRet(2:end) ;         % Stocks return 
  expStd  = annualStd(2:end) ;         % Stocks std
  expCov  = annualCov(2:end,2:end) ;   % Stocks covariance  
  
  Ndim = length(expRet) ; 
  
  Aeq = ones(1,Ndim);
  Beq = 1;
  
  lbnds = zeros(Ndim,1);
  ubnds = ones (Ndim,1);
  
  % qoptions = optimset('Display','off','LargeScale','off');
  
  qoptions = optimset('Display', 'iter', ...
                      'Algorithm','interior-point', ...
                      'MaxFunEvals', 500000, ...
                      'TolFun', 1e-20) ; 
  
  n1 = 1.0/Ndim;
  
  w0 = repmat(n1, Ndim, 1) ; % w0 = n1*ones(Ndim,1); 
  
  NLLfunction = @(x) fm_fitnessERC(expCov, x) ;
  
  [weights, fval, sqpExit] = fmincon(NLLfunction, w0, ...
                                     [], [], Aeq, Beq, lbnds, ubnds, [], ...
                                     qoptions) ;
  
  % Just check that we get the right ERC portfolio 
  
  s  = sqrt(weights'*expCov*weights)  ; 
  c  = weights .* ( expCov*weights/sqrt(weights'*expCov*weights) );
  si = c / s; 

  
toc
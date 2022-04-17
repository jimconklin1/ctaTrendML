%__________________________________________________________________________
% 
% This script builds an Equally Risk Contribution portfolio
% The code makes use of tick2ret & geom2arith available in
% the finance toolbox
%  
%__________________________________________________________________________

tic

    % load data (data not provided. Use any matrix with name 'price' 
    % as data)
    load price ; 
    % note: prices(1,:)     : Benchmark index prices 
    %       prices(2:end,:) : Stocks prices 
  
    returns = tick2ret(prices,[],'continuous');
    numReturns = size(returns,1);

    [annualRet, annualCov] = geom2arith(mean(returns),cov(returns),numReturns);

    annualRet = annualRet';
    annualStd = sqrt(diag(annualCov));
  
    indexRet = annualRet(1) ;            % Benchmark return 
    indexStd = annualStd(1) ;            % Benchmark standard deviation 

    expRet  = annualRet(2:end) ;         % Stocks return 
    expStd  = annualStd(2:end) ;         % Stocks std
    expCov  = annualCov(2:end,2:end) ;   % Stocks covariance  
  
    Ndim = length(expRet) ; 

    % Contraints for optimiser
    Aeq = ones(1,Ndim);
    Beq = 1;
    lbnds = zeros(Ndim,1);
    ubnds = ones (Ndim,1);
    MaxIter = 100000;
    qoptions = optimset('Display', 'iter', 'Algorithm','interior-point', ...
                      'MaxFunEvals', MaxIter, 'TolFun', 1e-20) ; 
    n1 = 1.0/Ndim;
    w0 = repmat(n1, Ndim, 1) ;

    NLLfunction = @(x) fm_fitnessERC(expCov, x) ;
    [weights, fval, sqpExit] = fmincon(NLLfunction, w0, ...
                                 [], [], Aeq, Beq, lbnds, ubnds, [], ...
                                 qoptions) ;
  
    % Check ERC portfolio 
    s  = sqrt(weights'*expCov*weights)  ; 
    c  = weights .* ( expCov*weights/sqrt(weights'*expCov*weights) );
    si = c / s; 

toc
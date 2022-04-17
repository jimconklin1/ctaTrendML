function [ddRisk, drawdown] = calcDDrisk(params, u) % , u, const)
% Inputs:
%    params = drawdown control parameter vector = [A,alpha,lambda,mu,sigma]
% 		  A = risk aversion factor, typically between 10 and 30
%     alpha = 1 - max allowed decayed drawdown limit (i.e., 1-15% = 0.85)
%    lambda = decay rate (approx 5% / yr)
%        mu = expected mean of excess return process
%     sigma = expected stdev of return of process
% 
%         u = 1 - current drawdown
% 
%     const = [const(1), const(2)], two small threshold constants

drawdown = u;
const = [1e-7, 1e-6]; 


smallConst = const(1); 
A = params(1);
alpha = params(2);
lambda = params(3);
mu = params(4);
sigma = params(5);
alpha = max([alpha, const(2)]);
lambda = max([lambda, const(2)]);

% minimum Sharpe ratio
if mu/sigma < 0.05
   muSigmaRatio = 0.05;
   mu = sigma*muSigmaRatio; %#ok
else
   muSigmaRatio = mu/sigma;
end

if(params(2) < 1);
   xi = calcXi(A, alpha, lambda, muSigmaRatio);
else
   error('Need to check how to compute xi.\n');    
end

if (drawdown >= 1-smallConst) ;
    drawdown = 1;
    ddRisk= ((xi-lambda)*A*2/(muSigmaRatio*muSigmaRatio));
elseif (drawdown <= alpha+smallConst) ;
    drawdown = alpha;
    ddRisk = 0;
else
    a1 = muSigmaRatio*muSigmaRatio/2;
    a3 = -lambda;
    a2 = (1-A)*xi + a1 + a3;
    factor = sqrt(a2*a2-4*a1*a3);
    theta1 = (-a2-factor)/(2*a1);
    
    aa = 0;
    bb = -theta1*A;
    
    %/* set up variable for Eqf3 */
    
    dd_A = A;
    dd_alpha = alpha;
    dd_lambda = lambda;
    dd_muSigmaRatio = muSigmaRatio;
    dd_drawdown = drawdown;
    dd_xi = xi;
    [~, ddRisk] = zeroFind(@EqF3, aa-smallConst, bb, smallConst);
end % if
  
  %% nested functions to share dd_* variables;
  
  function xi = calcXi(A, alpha, lambda, muSigmaRatio)
    
    smallConst = 1e-7;
    %/* alpha >= 1?? */
    aa = muSigmaRatio*muSigmaRatio/2*(1-alpha)/(alpha+(1-alpha)*A);
    bb = muSigmaRatio*muSigmaRatio/(2*A);
    
    dd_A = A;
    dd_alpha = alpha;
    dd_lambda = lambda;
    dd_muSigmaRatio = muSigmaRatio;
    
    [~,xi] = zeroFind(@Eq3_9, lambda+aa-smallConst, lambda+bb, smallConst);
    
  end

  function y = Eq3_9(xi)
    
    smallConst = 1e-7;
    
    a1 = dd_muSigmaRatio*dd_muSigmaRatio/2;
    a3 = -dd_lambda;
    a2 = (1-dd_A)*xi + a1 + a3;
    
    
    factor = sqrt(a2*a2-4*a1*a3);
    theta1 = (-a2-factor)/(2*a1);
    theta2 = (-a2+factor)/(2*a1);
    
    
    delta = -a2/factor;
    
    c = dd_alpha*dd_alpha*((-theta1)^(1-delta))*((theta2)^(1+delta));
    
    y1 = (dd_lambda-xi)*2/(dd_muSigmaRatio*dd_muSigmaRatio);
    
    if (abs(xi-dd_lambda-dd_muSigmaRatio*dd_muSigmaRatio/(2*dd_A)) < smallConst);
       y = -c;
    else
       y = ((abs(y1-theta1))^(1-delta))*((abs(y1-theta2))^(1+delta)) - c;
    end % if
  end
  
  function y = EqF3(Yu)
    smallConst = 1e-7; 
    a1 = dd_muSigmaRatio*dd_muSigmaRatio/2;
    a3 = -dd_lambda;
    a2 = (1-dd_A)*dd_xi + a1 + a3;

    factor = sqrt(a2*a2-4*a1*a3);
    theta1 = (-a2-factor)/(2*a1);
    theta2 = (-a2+factor)/(2*a1);

    delta = -a2/factor;

    c = dd_alpha*dd_alpha*((-theta1)^(1-delta))*((theta2)^(1+delta));

    if (abs(-dd_A*theta1-Yu) < smallConst);
      y =  -c*dd_A*dd_A/(dd_drawdown*dd_drawdown);
      return;
    end

    y = ((-dd_A*theta1-Yu)^(1-delta))*((dd_A*theta2+Yu)^(1+delta)) - ...
	      c*dd_A*dd_A/(dd_drawdown*dd_drawdown);
  end
  

end % main fn

function [err, rtb] = zeroFind(func, x1, x2, xThresh)

    err = 0; 
    JMAX = 50; 

    if (abs(x2-x1) < xThresh); 
      rtb = 0.5 *(x1+ x2);
      return;
    end  

    f = func(x1);
    fmid=func(x2);

    
    if (f*fmid >= 0.0);
      %/* If f(x1) && f(x2) are of the same sign, we need to search for
      % two polocals whose function values are of different sign  */
      
      bracket_found = 0;
      
      %/* initialize the best solution found so far */
      if (abs(f) < abs(fmid));
        rtb = x1;
        ftb = abs(f);
      else
        rtb = x2;
        ftb = abs(fmid);
      end
      
      %/* search over 1000 polocals */
      search_step = (x2-x1)/1000.0;
      
      while (x1 < x2);
        x1 = x1 + search_step;
        f = func(x1);
        if (f*fmid < 0.0);
          bracket_found = 1;
          if (abs(x2-x1) < xThresh);
            rtb = 0.5 *(x1+ x2);
            return;
          end
          break;
        elseif (abs(f) < ftb);
          %/* update the best solution found so far */
          ftb = abs(f);
          rtb = x1;
        end
      end
      
      if (bracket_found == 0);
        %/* we still cannot find a bracket for the root
        %retp the best solution we found so far. */
        return;
      end
    end
    
    if(f < 0.0);
      dx = x2-x1;
      rtb = x1;
    else
      dx = x1-x2;
      rtb = x2;
    end
    
    
    for j =(1:JMAX) ;
      
      dx = dx*0.5;
      xmid = rtb + dx;
      fmid = func(xmid);
      if (fmid <= 0.0);
        rtb = xmid;
      end
      if ((abs(dx) < xThresh) || (fmid == 0.0));
        return;
      end
    end
    
    err = 1;
    fprintf('Total search %f\n', JMAX);
    fprintf('Fail to find a satifying root after all search. \n');
    
    rtb=0;
    %retp(err, 0);			/* retp what ever */
end 

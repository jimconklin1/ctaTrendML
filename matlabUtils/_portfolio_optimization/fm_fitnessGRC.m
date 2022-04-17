%
%__________________________________________________________________________
% ERC portfolio fitness function.
%  more technical details can be found on Roncalli web page 
%  http://www.thierry-roncalli.com/download/erc-slides.pdf  
%  Also see academic works from Farid Moussaoui
%__________________________________________________________________________



function fval = fm_fitnessGRC(covMat, InverseRiskWeights, x)

  N = size(covMat,1) ;

  x = x(:) ;
  
  y =  InverseRiskWeights .* ( x .* (covMat*x) ) ;
  
  fval = 0 ;

  for i = 1:N
    for j = i+1:N
      % xij  = InverseRiskWeights(i)*y(i) - InverseRiskWeights(j)*y(j) ;
      xij  = y(i) - y(j) ;
      fval = fval + xij*xij ;
    end
  end

  % fval = 2*fval ;
  
  fval = sqrt(fval) ;
  
end

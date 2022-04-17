%
%__________________________________________________________________________
% ERC portfolio objective function.
% Technical details can be found on Roncalli web page 
% http://www.thierry-roncalli.com/download/erc-slides.pdf  
%__________________________________________________________________________
%
function fval = ERC_ObjectiveFunction(covMat, x) 

  N = size(covMat,1) ;   
  y = x .* (covMat*x) ; 
  fval = 0 ; 
  
  for i = 1:N
    for j = i+1:N
      xij  = y(i) - y(j) ; 
      fval = fval + xij*xij ; 
    end 
  end
  fval = sqrt(fval) ;
  
end

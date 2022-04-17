%
%__________________________________________________________________________
% ERC portfolio fitness function.
%  more technical details can be found on Roncalli web page 
%  http://www.thierry-roncalli.com/download/erc-slides.pdf  
%  Also see academic works from Farid Moussaoui
%
% Note: the objective function is
% f(w)=argmin(w) {Sum_i Sum_j[w(i)cov(r(i),r(p)) - w(j)cov(r(j),r(p))]^2}
% constraints: 0<=w(i)<=w(i)ub, Sum_i(w(i))=1
%
%__________________________________________________________________________

function fval = fm_fitnessERC(covMat, x) 
  
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

function xm_yield = ConvertBackXM(xm_price)

% This function takes xm price as input and convert back to yield as shown on Bloomberg.
%
% Output: xm_yield, a number or vector
% Input: xm_price, a number or vector

init_val	= 95;
options 	= optimoptions('fsolve','Display','off');
xm_yield 	= fsolve(@(x) xm_function(x, xm_price), init_val*ones(size(xm_price)), options);

end

function F = xm_function(xm_yield, xm_price)

F = ConvertXM(xm_yield) - xm_price;

end
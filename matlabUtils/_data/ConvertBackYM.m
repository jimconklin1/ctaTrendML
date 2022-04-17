function ym_yield = ConvertBackYM(ym_price)

% This function takes ym price as input and convert back to yield as shown on Bloomberg.
%
% Output: ym_yield, a number or vector
% Input: ym_price, a number or vector

init_val	= 95;
options 	= optimoptions('fsolve','Display','off');
ym_yield 	= fsolve(@(x) ym_function(x, ym_price), init_val*ones(size(ym_price)), options);

end

function F = ym_function(ym_yield, ym_price)

F = ConvertYM(ym_yield) - ym_price;

end
function ir_yield = ConvertBackIR(ir_price)

% This function takes ir price as input and convert back to yield as shown on Bloomberg.
%
% Output: ir_yield, a number or vector
% Input: ir_price, a number or vector

init_val	= 95;
options 	= optimoptions('fsolve','Display','off');
ir_yield 	= fsolve(@(x) ir_function(x, ir_price), init_val*ones(size(ir_price)), options);

end

function F = ir_function(ir_yield, ir_price)

F = ConvertIR(ir_yield) - ir_price;

end
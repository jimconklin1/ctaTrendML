function ir_price = ConvertIR(ir_yield)

% This function takes ir yield as input and convert to contract value.
%
% Output: ir_price, a number or vector
% Input: ir_yield, a number or vector

ir_price = 1000000 * 365 ./ (365 + (100 - ir_yield) * 90 / 100);

end
function ym_price = ConvertYM(ym_yield)

% This function takes ym yield as input and convert to contract value.
%
% Output: ym_price, a number or vector
% Input: ym_yield, a number or vector

temp = (100 - ym_yield) / 200;
v6 = (1 ./ (1 + temp)) .^ 6;
ym_price = 1000 .* (3 .* (1 - v6) ./ temp + 100 .* v6);

end
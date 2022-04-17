function xm_price = ConvertXM(xm_yield)

% This function takes xm yield as input and convert to contract value.
%
% Output: xm_price, a number or vector
% Input: xm_yield, a number or vector

temp = (100 - xm_yield) / 200;
v20 = (1 ./ (1 + temp)) .^ 20;
xm_price = 1000 .* (3 .* (1 - v20) ./ temp + 100 .* v20);

end
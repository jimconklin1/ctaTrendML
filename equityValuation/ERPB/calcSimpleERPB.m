function erpb = calcSimpleERPB(zeroRates, bbgData, dividend, buyback)
% Was 'calcERPB()'

calcDate = dividend(1);
v = table2array(zeroRates(find(zeroRates.CalcDate <= calcDate, 1, 'last'), 2 : end));
x = [0.25, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30];
xq = 0.25 : 0.25 : 100;
zeroCurve = interp1(x, v, xq);
zeroCurve(121 : end) = v(end);

currentPrice = bbgData.PX_LAST(find(bbgData.CalcDate <= calcDate, 1, 'last'));

function price = calcPrice(x)
    price = -1 * currentPrice;
    for i = 1 : length(dividend) - 1
        price = price + (dividend(i + 1) + buyback(i + 1)) / ((1 + x + zeroCurve(i)) ^ (0.25 * i));
    end
end

fun = @calcPrice;
x0 = 0;
options = optimset('Display', 'off');
erpb = fsolve(fun, x0, options);

end
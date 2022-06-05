function  [dividend, buyback, dateHeader] = calcProjectedPO(config, bbgData)

J = 400;
T = size(bbgData, 1);
dividend = zeros(T, J + T);
buyback = zeros(T, J + T);
dateHeader = [bbgData.DataDate', eomonth(bbgData.DataDate(end) + 91.25 : 91.25 : bbgData.DataDate(end) + (J * 91.25))];
growthRate = (1 + config.nomGrwth) .^ ((dateHeader(2 : end) - dateHeader(1 : end - 1)) ./ yeardays(year(dateHeader(2:end))));

for i = 1 : T
    dividend(i, i + 1) = bbgData.DVD_SH_12M(i) * growthRate(i);
    buyback(i, i + 1) = - 1 * bbgData.CF_DECR_CAP_STOCK(i) - bbgData.CF_INCR_CAP_STOCK(i);
    for j = 2 : J
        dividend(i, i + j) = dividend(i, i + j - 1) * growthRate(i + j - 1);
        buyback(i, i + j) = buyback(i, i + j - 1) * growthRate(i + j - 1);
    end
end

dividend(:, 1) = bbgData.OOSDate;
buyback(:, 1) = bbgData.OOSDate;

end
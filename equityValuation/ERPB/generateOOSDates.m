function oosDates = generateOOSDates(config)

startYear = year(config.dataStartDate);
endYear = year(config.dataEndDate);

oosDates = zeros((endYear - startYear) * 4, 2);
i = 1;

for y = startYear : endYear
    for q = 1 : 4
        dataDate = lbusdate(y, 3 * q);
        oosDate = addtodate(dataDate, config.oosDates, 'day');
        oosDates(i, 1) = dataDate;
        oosDates(i, 2) = oosDate;
        i = i + 1;
    end
end

oosDates = oosDates(oosDates(:, 1) >= datenum(config.dataStartDate), :);
oosDates = oosDates(oosDates(:, 1) <= datenum(config.dataEndDate), :);

oosDates = array2table(oosDates, 'VariableNames', {'DataDate', 'OOSDate'});

end
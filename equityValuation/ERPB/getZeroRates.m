function zeros = getZeroRates(startDate, endDate, frequency)

% zeros = getZeroRates('01/01/1990', '03/31/2020', 'quarterly');

c = blp;
from = datestr(datenum(startDate), 'mm/dd/yyyy');
to = datestr(datenum(endDate), 'mm/dd/yyyy');
data = history(c, {'I02503M Index', 'I02506M Index', 'I02501Y Index',...
                   'I02502Y Index', 'I02503Y Index', 'I02504Y Index',...
                   'I02505Y Index', 'I02506Y Index', 'I02507Y Index',...
                   'I02508Y Index', 'I02509Y Index', 'I02510Y Index',...
                   'I02515Y Index', 'I02520Y Index', 'I02530Y Index'},...
                   {'PX_LAST'}, from, to, {frequency, 'calendar'});
zeros = cell2mat(data(1));
for i = 2 : length(data)
    rates = cell2mat(data(i));
    zeros = [zeros, rates(:, 2)];
end

zeros(:, 2:end) = zeros(:, 2:end) / 100;
zeros = array2table(zeros, 'VariableNames', {'CalcDate', 'M3', 'M6', 'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9', 'Y10', 'Y15', 'Y20', 'Y30'});

end
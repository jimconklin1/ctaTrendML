function [erpb, fcst] = calcAnalyticalERPB_jc(config)

PubEqPath.addLibPath('_data', '_date');
c = blp;

indexData = history(c, config.indexId, {'PX_LAST', 'EARN_YLD', 'EQY_DVD_YLD_12M'}, config.calcStartDate, config.calcEndDate, config.caclFreq);
bondData = history(c, 'I02530Y Index', {'PX_LAST'}, config.calcStartDate, config.calcEndDate, config.caclFreq);

data = [indexData(:, [1, 2]), indexData(:, [3, 4]) / 100, bondData(:, 2) / 100];
ii = find(data(:,1)>config.lastEPSpriorQuarter,1);
T = size(data,1); 
TT = T - ii;
g = config.nomGrwth;
mult = ones(T,1); 
mult(ii+1:T,1) = (config.lastEPSfactor*(1:TT)'/TT + ones(TT,1) - (1:TT)'/TT);
data(ii+1:T,3) = data(ii+1:T,3).*mult(ii+1:T,1); 
data(:, 6) = data(:, 4) + data(:, 3) * config.nonDivPO2earn;
%data(:, 7) = (1 + config.nomGrwth) ./ (1 - data(:, 6)) - 1 - data(:, 5);
data(:, 7) = config.nomGrwth + data(:, 6) - data(:, 5);

% compute duration here using an annual grid:
%   dP/dr / P = -sum_i{ i*((1+g)/(1+r+ERPB) )^i*POyld:
data(:,8) = NaN(T,1);
for t = 1:T
   temp1 = 1:400;
   DF = (1 + g)/(1 + data(t,5) + data(t,7)); 
   temp2 = DF.^(1:400);
   data(t,8) = sum(temp1.*temp2)*data(t,6);
end 
erpb = array2table(data, 'VariableNames', {'CalcDate', 'Index', 'EarnYld', 'DivYld', 'Bond30Yld', 'POYld', 'ERPB','Duration'});

% CF calcs, quarterly
dTemp = eomonth(data(1,1));
if ismember(month(dTemp),[1,4,7,10]) 
   dTemp = eomonth(data(1,1)+58);
elseif ismember(month(dTemp),[2,5,8,11]) 
   dTemp = eomonth(data(1,1)+28);
end 
qDates =  makeStandardDates(dTemp,data(end,1),'quarterly');
qX = zeros(length(qDates),43); 
for t = 1:length(qDates)
   ii = find(data(:,1)<=qDates(t,1),1,'last'); 
   qX(t,1:5) = [data(ii,[2,6]),config.nonDivPO2earn*data(ii,3),data(ii,4),0.25*data(ii,2)*data(ii,6),];
   qX(t,6:45) = qX(t,5).*(1 + g/4).^(1:40);
end 
vNames = {'CalcDate','indxPx','POyld','divYld','bbYld',...
          'CF0','CF1','CF2','CF3','CF4','CF5','CF6','CF7','CF8','CF9', ...
          'CF10','CF11','CF12','CF13','CF14','CF15','CF16','CF17','CF18','CF19', ...
          'CF20','CF21','CF22','CF23','CF24','CF25','CF26','CF27','CF28','CF29', ...
          'CF30','CF31','CF32','CF33','CF34','CF35','CF36','CF37','CF38','CF39','CF40'};
fcst = array2table([qDates,qX],'VariableNames', vNames); 
% long history:
figure(1);
yyaxis left;
plot(erpb.CalcDate, [erpb.ERPB, erpb.Bond30Yld], 'LineWidth', 2);
datetick('x', 'ddmmmyyyy', 'keepticks');
xlim([data(1, 1), data(end, 1)]);
% ylim([0, 0.07]);
y = cellstr(num2str(get(gca, 'ytick')' * 100));
pct = char(ones(size(y, 1), 1) * '%'); 
new_yticks = [char(y), pct];
set(gca, 'yticklabel', new_yticks);

yyaxis right;
plot(erpb.CalcDate, erpb.Index, 'LineWidth', 2);
datetick('x', 'ddmmmyyyy', 'keepticks');
xlim([data(1, 1), data(end, 1)]);
% ylim([1600, 3400]);

label = split(config.indexId, ' ');
set(gcf, 'Position', [1000, 798, 840, 420]);
grid on;
legend(strcat(label{1}, ' ERPB'), '30Y US Govt YTM', strcat(label{1}, ' (RHS)'), 'Location', 'northwest');
title(strcat(config.indexId, ' ERPB'));

% short history:
figure(2);
yyaxis left;
dTemp = datenum(config.shortStartDate); 
t0 = find(erpb.CalcDate>=dTemp,1,'first'); 
plot(erpb.CalcDate(t0:end,:), [erpb.ERPB(t0:end,:), erpb.Bond30Yld(t0:end,:)], 'LineWidth', 2);
datetick('x', 'ddmmmyyyy', 'keepticks');
xlim([data(t0, 1), data(end, 1)]);
% ylim([0, 0.07]);
y = cellstr(num2str(get(gca, 'ytick')' * 100));
pct = char(ones(size(y, 1), 1) * '%'); 
new_yticks = [char(y), pct];
set(gca, 'yticklabel', new_yticks);

yyaxis right;
plot(erpb.CalcDate(t0:end,:), erpb.Index(t0:end,:), 'LineWidth', 2);
datetick('x', 'ddmmmyyyy', 'keepticks');
xlim([data(t0, 1), data(end, 1)]);
% ylim([1600, 3400]);

label = split(config.indexId, ' ');
set(gcf, 'Position', [1000, 798, 840, 420]);
grid on;
legend(strcat(label{1}, ' ERPB'), '30Y US Govt YTM', strcat(label{1}, ' (RHS)'), 'Location', 'northwest');
title(strcat(config.indexId, ' ERPB'));

end
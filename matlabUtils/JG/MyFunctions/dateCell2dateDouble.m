function sest = dateCell2dateDouble(datev)
%
%__________________________________________________________________________
%
% convert a date given on a cell format into a double format
%__________________________________________________________________________
%
nrows=length(datev); sest=zeros(nrows,1);
if iscell(datev(1)), datev = cell2mat(datev); end
t=datev;
t_year = year(t); t_month = month(t); t_day = day(t);
for n = 1:nrows
    t_year_n = num2str(t_year(n));
    t_month_n = num2str(t_month(n)); [Nn,Mn] = size(t_month_n);
    if Mn == 1, t_month_n = strcat('0', t_month_n); end
    t_day_n = num2str(t_day(n)); [Nn,Mn] = size(t_day_n);
    if Mn == 1, t_day_n = strcat('0', t_day_n); end
    sest_n = strcat(t_year_n, t_month_n, t_day_n);
    sest(n) = str2double(sest_n);
end
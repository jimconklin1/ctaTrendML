%__________________________________________________________________________
%
% Build Chrone Structure From XLS file
%__________________________________________________________________________
% ses = xls2chrone(xheader, x)
%--------------------------------------------------------------------------
%
% Build a generic chrone structure from a XLS table, the first column being 
% a vector of time stamps.
%__________________________________________________________________________
%
% © MWC Technology - S.Guglietta


function ses = xls2chrone(xheader, x)

[N,M] = size(x); tx = x2mdate(x(:,1)); dx = x(:,2:M);
%hx = {xheader};
hx = xheader;
tses = zeros(N,1);

for n = 1:N
    td = day(tx(n)); tm = month(tx(n)); ty = year(tx(n));
    td = num2str(td); tm = num2str(tm); ty = num2str(ty);
    if length(td) < 2
        td = strcat('0',td);
    end
    if length(tm) < 2
        tm = strcat('0',tm);
    end   
    tses_n = strcat(ty, tm, td); tses(n) = str2num(tses_n);
end

ses = chronebuilder(hx, tses, dx);

return
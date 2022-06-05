%{
for f = string(tot_ret.Properties.VariableNames(2:5))
    clf;
    plot(tot_ret.Date,cumsum(tot_ret.(f)));
    title(f);
end % for    
clf;

f = 'USD LIBOR 3M';
plot(tot_ret.Date,tot_ret.(f));
title(f);
%}

for f = string(tot_ret.Properties.VariableNames(2:5))
    disp(f + " -->    " + string(std(tot_ret.(f))*sqrt(260)*100) + "%");
end % for  
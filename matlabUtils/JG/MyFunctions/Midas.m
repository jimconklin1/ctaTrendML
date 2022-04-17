function y = Midas(x, timex, timebench)
%__________________________________________________________________________
%
%__________________________________________________________________________

%timex = tdaynumeco;
%timebench = tttdaynum;

nbench = length(timebench);
y = zeros(nbench,1);
yeom = zeros(nbench,1);
nx = length(timex);
ind_timex = zeros(nx,1);

year_bench = year(timebench);
month_bench = month(timebench);

% Identify first date of timex
start_timex = timex(1,1);

% Identify at which row of timebench start_timex is
[row,column] = find(timebench == start_timex);

% Initialize index 
ind_timex(1,1) = row;
count_timex = 1;

count = row;
for u=row:nbench-1
    count = count+1;
    if month(timebench(u)) ~= month(timebench(u+1)) 
        count_timex = count_timex + 1;
        ind_timex(count_timex,1) = count;
    end
end
        
for u=1:nx
    y(ind_timex(u)) = x(u);
    yeom(ind_timex(u)) = 1;
end
        
for u=2:nbench
    if yeom(u) ~= 1
        y(u) = y(u-1);
    end
end
    


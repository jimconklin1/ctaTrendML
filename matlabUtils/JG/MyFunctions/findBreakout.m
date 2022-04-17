function [sbs,sbl] = findBreakout(h,l,c, PeriodShort, PeriodLong, MemoShort, MemoLong)

% -- Extract data --
[nsteps,ncols] = size(c);

sbs = zeros(size(c));
sbl = zeros(size(c));

for i=MemoShort+PeriodShort+1:nsteps
    for j=1:ncols
        if  c(i,j) < min(l(i-PeriodShort-MemoShort:i-MemoShort,j)) 
            sbs(i,j)=-1;
        end
    end
end

for i=PeriodLong+MemoLong+1:nsteps
    for j=1:ncols
        if  c(i,j) > max(h(i-PeriodLong-MemoLong:i-MemoLong,j)) 
            sbl(i,j)=+1;
        end
    end
end
function  startDate = findStart(x)
%
%__________________________________________________________________________
%
% This utility finds the starting date in a time series
% (mostly useful when data is alligned)
%__________________________________________________________________________

[nsteps,ncols]=size(x);

startDate=zeros(1,ncols);

for j=1:ncols
    for i=1:nsteps
        if x(i,j)~=0 && ~isnan(x(i,j))
            startDate(1,j)=i;
            break
        end
    end
end
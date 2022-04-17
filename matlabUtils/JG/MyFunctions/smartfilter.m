%function [timecrosslow, timecrosshigh, y] = smartfilter(h,l,c,nbd)
nbd=21;
%__________________________________________________________________________
% The function expmav computes the arithmetic moving average
% Parameters:
% - X is a matrix m*n
% - nbd is the period over which the moving average is computed
%__________________________________________________________________________
%
%
% -- Prelocate matrices --
y = zeros(size(c));
timecrosslow = zeros(size(c));
timecrosshigh = zeros(size(c));
[nbsteps,nbcols]=size(y);
%
% -- Kestner Range --
emah=expmav(h,nbd);
emal=expmav(l,nbd);

for j=1:nbcols
    % find the first cell to start the code
    start_date=zeros(1,1);
    for i=1:nbsteps
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i,j)) && ...
             h(i,j)~=0 &&  l(i,j)~=0 && c(i,j)~=0  
            start_date(1,1)=i;
        break
        end
    end
    % Time
    for i=start_date(1,1)+nbd+1:nbsteps
        if c(i,j)>emal(i,j) && c(i-1,j)<emal(i-1,j)
            timecrosslow(i,j)=i;
        end
        if c(i,j)<emah(i,j) && c(i-1,j)>emah(i-1,j)
            timecrosshigh(i,j)=i;
        end
    end
end
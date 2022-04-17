function y = lrmemory(x,method,lookback,threshold)

%__________________________________________________________________________
% The function expmav computes the arithmetic moving average
% Parameters:
% - x is a matrix m*n
% - lookback is the period over which the moving average is computed
% - threshold 
%                                              Joel Guglietta - June 2015
%__________________________________________________________________________

% Prelocate matrices
[nsteps,ncols]=size(x);
y = zeros(size(x));

for j=1:ncols
    % find the first cell to start the code
    startDate=zeros(1,1);
    for i=1:nsteps
        if ~isnan(x(i,j))
            startDate(1,1)=i;
        break
        end
    end
    % Snap
    switch method
        case {'minimum','min','findMin','minmem',memmin','minMem','MinMem','MinMem'}
            for i=startDate(1,1)+lookback:nsteps
                xsnap=x(i-lookback+1:i,j);
                xsnap(xsnap>threshold)=0; % set to 0 all values > threshold
                xsnap(xsnap~=0)=1;        % set to 1 all values== 1 (i.e. <= threshold)
                y(i,j)=sum(xsnap);
            end
        case {'maximum','max','findMax','maxmem','memmax','maxMem','MaxMem','MaxMem'}
            for i=startDate(1,1)+lookback:nsteps
                xsnap=x(i-lookback+1:i,j);
                xsnap(xsnap<threshold)=0; % set to 0 all values < threshold
                xsnap(xsnap~=0)=1;        % set to 1 all values== 1 (i.e. >= threshold)
                y(i,j)=sum(xsnap);
            end            
    end
end
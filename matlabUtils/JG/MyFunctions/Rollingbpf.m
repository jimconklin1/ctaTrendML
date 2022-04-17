function y=Rollingbpf(x,up,dn,LookbackPeriod, method)
%
%__________________________________________________________________________
%
% Compute the Baxter King filter on a rolling basis
% makes use of two functions: - (bpf.m and filtk.m) bpass
% Parameter:
% According to Burns & Mitchell, for quarterly data use: [up=6, down=32]. 
% for monthly data, use [96,18, 12]
%
%
% methods : two methods, compute Band Pass over a rolling window, or since
% the beginning
%__________________________________________________________________________
%

% -- Prelocate & Dimensions --
[nbsteps,nbcols]=size(x);
y = zeros(size(x));
% -- Compute  --
for j=1:nbcols
    % find the first cell to start the code
    start_date = zeros(1,1);
    for i=1:nbsteps
        if ~isnan(x(i,j))
            start_date(1,1)=i;
        break
        end
    end
    % Compute
    switch method
        case {'rolling', 'roll'}
            for k = start_date(1,1) + LookbackPeriod : nbsteps
                snapx = x(k-LookbackPeriod+1:k,j);
                snapx_bpass = bpass(snapx,up,dn);
                y(k,j) = snapx_bpass(length(snapx_bpass));
            end
        case {'allts','all'}
            for k = start_date(1,1) + max(up,dn) : nbsteps
                snapx = x(start_date(1,1):k,j);
                snapx_bpass = bpass(snapx,up,dn);
                y(k,j) = snapx_bpass(length(snapx_bpass));
            end            
    end
    
end
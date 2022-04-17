function [tsdd, maxdd, timedd] = drawdown(X,method)
%__________________________________________________________________________
% -- Inputs --
% X = time series
% method : - 'level' (if time series is given in level)
%          - ' return' (if time series is given in returns)
% -- Output --
% tsdd = time series fro drawdown
% maxdd = maximum drawdown
% timedd = time when maxdrawdown happend
%__________________________________________________________________________
    
switch method
    
    case {'level', 'l'}
    
        n=length(X);
        Xret = zeros(size(X));
        Y = zeros(size(X));
        % Compute return
        for i=2:n
            if X(i-1)~=0,Xret(i)=X(i)/X(i-1)-1;end
        end
        % Cumulated return
        Y(1) = X(1);
        for i=2:n
            Y(i) = Y(i-1)+Xret(i);
        end
        % Drawdown time series
        Ymax=zeros(size(Xret));
        for i=2:n
            Ymax(i) = max(Y(2:i)) - Y(i);
        end   
        % Max drawdown
        maxd = max(Ymax(2:n));
        % Identify the date of max drawdown
        for i=2:n
            if Ymax(i) == maxd
                time_maxd = i;
                break
            end
        end     

    %case {'return'}
    case {'return', 'r'}
        
    Y = zeros(size(X));
    n=length(X);
    % Cumulated return
    Y(1) = X(1);
    for i=2:n
        Y(i) = Y(i-1)+X(i);
    end
    % Drawdown time series
    Ymax=zeros(size(X));
    for i=2:n
        Ymax(i) = max(Y(2:i)) - Y(i);
    end   
    % Max drawdown
    maxd = max(Ymax(2:n));
    % Identify the date of max drawdown
    for i=2:n
        if Ymax(i) == maxd
            time_maxd = i;
            break
        end
    end   
    
end

% Maximum loss
%max_loss = min(Y(2:n));
% Maximum gain
%max_gain = max(Y(2:n));
tsdd = Ymax;
maxdd = maxd;
timedd = time_maxd;





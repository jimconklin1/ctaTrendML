function [ts_drawdown,maxdrawdown,time_maxdrawdown,DD] = ComputeDrawdown(X,method,ArithGeo)

%__________________________________________________________________________
%
% Compute Drawdown
% Arguments:
% X = input time series
% 2 Methods: - 'price' : time series is a price series or equity curve
%            - 'return': time series is a return time series
% ArithGeo : Used to reconstruct equity curve (arithmetic or geometric)
% based on X if X is a return time series
% ArithGeo=1 .....> Arithmetic equity curve
% ArithGeo=2 .....> Geometric equity curve
%__________________________________________________________________________

switch method
    case 'price'    
        % Prelocate Matrix
        n=length(X);
        Xret = zeros(size(X));
        Y = zeros(size(X));
        Ymax=zeros(size(X));        
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
        % Other methodology
        DD=zeros(size(X)); peak=0; MDD=0;
        for i=2:n
            if X(i)>=max(X(1:i-1)), peak=X(i); end
            DD(i)= 100 * (peak - X(i)) / peak;
            if  DD(i) > MDD,  MDD = DD(i); end
        end        
    case 'return'
        % Prelocate Matrix        
        n=length(X);
        Y = zeros(size(X));        
        Ymax=zeros(size(X)); 
        % Cumulated return
        Y(1) = X(1);
        for i=2:n
            Y(i) = Y(i-1)+X(i);
        end
        % Drawdown time series
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
        % Recompute Equity curve
        ec=zeros(size(X)); 
        ec(1)=100;
        for i=2:n
            if ArithGeo==1
                ec(i)=ec(i-1)+100*X(i);
            elseif ArithGeo==2
                ec(i)=ec(i-1)*(1+X(i));
            end
        end     
        % Other methodology
        DD=zeros(size(X)); peak=0; MDD=0;
        for i=2:n
            if ec(i)>=max(ec(1:i-1)), peak=ec(i); end
            DD(i)= 100 * (peak - ec(i)) / peak;
            if  DD(i) > MDD,  MDD = DD(i); end
        end
end
% Output 
ts_drawdown=Ymax;
maxdrawdown=maxd;  
time_maxdrawdown=time_maxd;

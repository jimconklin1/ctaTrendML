function [z, zma] = FractalReversal(x, parameters, method)
%__________________________________________________________________________
%
% Another version for a "variance-ratio", "Hurst-exponent"
% inspired indicator
%
%__________________________________________________________________________

% -- load Fisher table according to critical value  --
[nsteps,ncols] = size(x);

% -- 1-day log return --
xlag = ShiftBwd(x,1, 'z');
y = abs(log(x./xlag)); y(y == Inf) = 0; 

switch method
    
    case{'history','History', 'hist', 'Hist', 'h', 'H'}
        
        period=parameters(1,1);
        maperiod=parameters(1,2);

        % -- n-day log return --
        xlagn = ShiftBwd(x,period, 'z');
        yn = log(x./xlagn); yn(yn == Inf) = 0;         

        z = zeros(size(x));
        
        for j=1:ncols
            % Find the first non zero 
            StartDate=zeros(1,1);
            for i=1:nsteps
                if ~isnan(x(i,j)) && x(i,j)~=0
                    StartDate(1,1)=i;
                break               
                end                                 
            end
            for i= StartDate(1,1) + period : nsteps
                Ni = sum(y(i-period:i,j)) / (abs(yn(i,j)) / period);
                z(i,j) = log(Ni) / log(period);
                if abs(z(i,j))==Inf, z(i,j)=z(i-1,j); end
            end
        end
        zma=expmav(z,maperiod);
        
    case {'snap', 'daysnap'}
        
        period=parameters(1,1);
        
        % -- n-day log return --
        xlagn = ShiftBwd(x,period, 'z');
        yn = log(x./xlagn); yn(yn == Inf) = 0;          
        
        z = zeros(1,ncols);

        for j=1:ncols
            Ni = sum(y(nsteps-period:nsteps,j)) / (abs(yn(nsteps,j)) / period);
            z(1,j) = log(Ni) / log(period);
            if abs(z(1,j))==Inf, z(1,j)=NaN; end       
        end

end
    
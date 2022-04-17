function y = Delta(x,method,period)
%
%__________________________________________________________________________
%
%The function compute the rate of change and normalises it or not
% INPUT--------------------------------------------------------------------
% X = matrix of price
% 'method'is :
% - 'difference'     :   computes the simple difference
% - 'diff'/'dif'     :   computes the simple difference
% - 'd'              :   computes the simple difference
%    period(1,1)     =   periode for rate of change
%
% - 'rate of change' :   computes the gross rate of change (roc)
% - 'roc' :   computes the gross rate of change (roc)
%    period(1,1)     =   periode for rate of change
%
% - 'information ratio': computes the normalised rate of change, ie,
%                        roc / std deviation(roc)
% - 'ir'               : computes the normalised rate of change, ie,
%                        roc / std deviation(roc)
%    period(1,1)     =   period for rate of change
%    period(1,2)     =   period for volatility and normalisation
% OUTPUT-------------------------------------------------------------------
% if 'method' = 'rate of change'
% output = - rate of change
% if 'method'='information ratio'
% output = - information ratio
%__________________________________________________________________________

% Define dimension & Prelocate matrix
[nsteps,ncols] = size(x); 
y = zeros(size(x));

switch method
    case {'difference', 'dif',  'diff', 'd', 'delta'}
        for j=1:ncols
            start_date=zeros(1,1);
            for i=1:nsteps
                if ~isnan(x(i,j))
                    start_date(1,1)=i;
                    break
                end
            end        
            for k=start_date(1,1)+period(1,1):nsteps
                if x(k-period(1,1)+1,j) ~= 0 && ~isnan(x(k-period(1,1)+1,j) )
                    y(k,j) = x(k,j) - x(k-period(1,1),j);
                end
            end
        end         
    case{'rate of change' , 'roc', 'rchg', 'ret', 'return'}
        for j=1:ncols
            start_date=zeros(1,1);
            for i=1:nsteps
                if ~isnan(x(i,j))
                    start_date(1,1)=i;
                    break
                end
            end
           for k=start_date(1,1)+period(1,1):nsteps
               if x(k-period(1,1),j) ~= 0 && ~isnan(x(k-period(1,1),j) )
                   y(k,j) = x(k,j) / x(k-period(1,1),j) -1;
               end
            end
        end   
    case {'information ratio', 'info ratio', 'inforatio', 'infratio', 'info-ratio', 'inf-ratio', 'inf ratio', 'ir'}
        % Gross rate of return
        yir = zeros(size(x));
        for j=1:ncols
            start_date=zeros(1,1);
            for i=1:nsteps
                if ~isnan(x(i,j))
                    start_date(1,1)=i;
                    break
                end
            end        
            for k=start_date(1,1)+period(1,1):nsteps
                if x(k-period(1,1),j) ~= 0 && ~isnan(x(k-period(1,1),j) )
                    y(k,j) = x(k,j) / x(k-period(1,1),j) -1;
                end
            end
        end    
        % Volatility
        yVol= zeros(size(y));    
        for j=1:ncols
            for k=start_date+period(1,1)+period(1,2)-1:nsteps
                yVol(k,j) = std(y(k-period(1,2)+1:k,j));
                if yVol(k,j)==0, yVol(k,j)=yVol(k-1,j); end
                yir(k,j) = y(k,j) /  yVol(k,j);
            end
        end  
        y = yir;
end
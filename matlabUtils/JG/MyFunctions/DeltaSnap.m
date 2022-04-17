function y = DeltaSnap(t, x, method, period)
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
% output = - rate of change
%          - information ratio
%__________________________________________________________________________

% Define dimension & Prelocate matrix
[nsteps,ncols] = size(x); 

switch method
    case {'difference', 'dif',  'diff', 'd', 'delta'}
        y = zeros(1,ncols);
        for j=1:ncols
            start_date=zeros(1,1);
            for i=1+1:nsteps
                if ~isnan(x(i,j))
                    start_date(1,1)=i;
                    break
                end
            end        
            if t > start_date(1,1)
                if x(t-period(1,1),j) ~= 0 && ~isnan(x(t-period(1,1),j) )
                    y(1,j) = x(t,j) - x(t-period(1,1),j);
                end
            end
        end         
    case{'rate of change' , 'roc', 'rchg', 'ret', 'return'}
        y = zeros(1,ncols);
        for j=1:ncols
            start_date=zeros(1,1);
            for i=1+1:nsteps
                if ~isnan(x(i,j))
                    start_date(1,1)=i;
                    break
                end
            end
           if t > start_date(1,1)
               if x(t-period(1,1),j) ~= 0 && ~isnan(x(t-period(1,1),j) )
                   y(1,j) = x(t,j) / x(t-period(1,1),j) - 1;
               end
            end
        end   
    case {'information ratio', 'info ratio', 'inforatio', 'infratio', 'info-ratio', 'inf-ratio', 'inf ratio', 'ir'}
        y = zeros(1,ncols);
        yir = zeros(1,ncols);
        ytemp = zeros(size(x));
        for j=1:ncols
            start_date=zeros(1,1);
            for i=1:nsteps
                if ~isnan(x(i,j))
                    start_date(1,1)=i;
                    break
                end
            end   
            if t > start_date(1,1)+period(1,1)+1
                for k=t-period(1,1)-period(1,2):t
                    if x(k-period(1,1),j) ~= 0 && ~isnan(x(k-period(1,1),j) )
                        ytemp(k,j) = x(k,j) / x(k-period(1,1),j) - 1;
                    end
                end  
            end
        end    
        % Volatility
        yVol= zeros(1,ncols);   
        for j=1:ncols
            y(1,j) = ytemp(t,j);
            yVol(1,j) = std(ytemp(t-period(1,2)+1:t,j));
            yir(1,j) = y(1,j) /  yVol(1,j);
        end 
        y = yir;
end
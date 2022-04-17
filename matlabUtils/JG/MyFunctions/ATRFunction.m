function[ATR,ATRstd] = ATRFunction(c,h,l,Lookback,LookbackVolat)
%
%__________________________________________________________________________
%
% This Function computes the ATR
% INPUT:
% - Matric of Close, High , Low
% - Lookback: Lookback period for N (Exp de ATR)
% - LookbackVOlat: Lookback period for std, dev, N (Exp de ATR)
% OUTPUT:
% ATR
% ATRstd
%__________________________________________________________________________
%
% -- Prelocate the matrix --
ATRg=zeros(size(c));
[nbsteps,nbcols]=size(c);

% The stop-loss is
% DDEV = ATR+f*ATRstd
% f=1.206 to 2.25
% Stop loss for long: trade high-DDEV
% Stop loss for short = trade low+DDEV

for j=1:nbcols
    % find the first cell to start the code
    for i=1:nbsteps
        if ~isnan(c(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j))
            start_date=i;
        break
        end
    end
    % Gross ATR
    for i=start_date+1:nbsteps
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i-1,j)) && ...
            h(i,j)>0 && l(i,j)>0 && c(i-1,j)>0
            %h2l=h(i,j)-l(i,j);
            %h2c=abs(h(i,j)-c(i-1,j));
            %l2c=abs(l(i,j)-c(i-1,j));
            %if h2l>h2c && h2l>l2c
            %    Yg(i,j)=h2l;
            %elseif  h2c>h2l && h2c>l2c
            %    Yg(i,j)=h2c;
            %elseif  l2c>h2l && l2c>h2c
            %    Yg(i,j)=l2c;                
            %end
            %Yg(i,j)=max(max(h2l,h2c),max(h2c,l2c));
            ATRg(i,j)=max(h(i,j),c(i-1,j))-min(l(i,j),c(i-1,j));            
        end
    end
end
ATR=expmav(ATRg,Lookback);
if nargout==2
    % Standard deviation of Average True range
    ATRstd   = VolatilityFunction(Yg,'simple volatility',Lookback,LookbackVolat,10e16);
end
clear ATRg

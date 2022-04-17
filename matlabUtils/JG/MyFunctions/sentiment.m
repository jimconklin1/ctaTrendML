function [y,sy]=sentiment(x,method, parameters)
%
%__________________________________________________________________________
% Computes the % of stock up or below MA
%__________________________________________________________________________
%
% -- Identify dimensions --
[nsteps,ncols]=size(x);
y=zeros(nsteps,1);
%
% -- Compute Market Sentiment --
switch method
    case {'cleanpctup', 'cleanpup', 'clean pct up'}
        fma=expmav(x,parameters(1,1));
        sma=expmav(x,parameters(1,2));
        incl=sma;
        incl(find(incl>0))= 1;
        sincl=zeros(nsteps,1);
        for i=1:nsteps,  sincl(i,1)=sum(incl(i,:)); end
        dma=fma-sma;
        dma(find(dma>0))= 1;
        dma(find(dma<0))= 0;
        for i=1:nsteps,  
            if sincl(i,1)>0
                y(i)=100*sum(dma(i,:))/sincl(i,1);
            end
        end
        sy=expmav(y,parameters(1,3));    
    case {'pctup', 'pup', 'pct up'}
        fma=expmav(x,parameters(1,1));
        sma=expmav(x,parameters(1,2));
        incl=sma;
        incl(find(incl>0))= 1;
        sincl=zeros(nsteps,1);
        for i=1:nsteps,  sincl(i,1)=sum(incl(i,:)); end
        dma=fma-sma;
        dma(find(dma>0))= 1;
        for i=1:nsteps,  
            if sincl(i,1)>0
                y(i)=sum(dma(i,:))/sincl(i,1);
            end
        end
        sy=expmav(y,parameters(1,3));
    case {'pctdeltaup', 'pdeltaup', 'deltaup', 'delta up', 'pct delta up', 'dup'}
        d=Delta(x,'dif',parameters(1,1));
        d(find(d>0))= 1;
        incl=x;
        incl(find(incl>0))= 1;
        sincl=zeros(nsteps,1);
        for i=1:nsteps,  sincl(i,1)=sum(incl(i,:)); end
        for i=1:nsteps,  
            if sincl(i,1)>0
                y(i)=sum(d(i,:))/sincl(i,1);
            end
        end     
        sy=expmav(y,parameters(1,2));
end


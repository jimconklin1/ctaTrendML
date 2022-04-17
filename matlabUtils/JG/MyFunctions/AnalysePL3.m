
%
%__________________________________________________________________________
%
% Analyse P&L
%
%__________________________________________________________________________
%
function [hplongavg, hpshortavg, swgtl, swgts] = AnalysePL3(c, s, wgt, HoldLong, HoldShort)

% -- Dimension --
[nsteps,ncols]=size(c);

% -- Total weight Long & Short --
% Total weight for Long
swgtl=zeros(nsteps,1);
for i=1:nsteps
    for j=1:ncols
        if s(i,j)==1
            swgtl(i)=swgtl(i)+wgt(i,j);
        end
    end
end
% Total weight for Short
swgts=zeros(nsteps,1);
for i=1:nsteps
    for j=1:ncols
        if s(i,j)==-1
            swgts(i)=swgts(i)+wgt(i,j);
        end
    end
end

% -- Compute Average Holding Period for Long Trades --
hplong=zeros(size(c));
for i=1:nsteps-1
    for j=1:ncols
        if HoldLong(i,j)~=0 && HoldLong(i+1,j)==0
           hplong(i,j)=HoldLong(i,j);
        else
            hplong(i,j)=0;
        end
    end
end
hplongavg=zeros(1,ncols);    counthplong=zeros(1,ncols);
for i=1:nsteps-1
    for j=1:ncols
        if hplong(i,j)~=0
          hplongavg(1,j)=hplongavg(1,j)+hplong(i,j);
          counthplong(1,j)=counthplong(1,j)+1;
        end
    end
end
for j=1:ncols
    if counthplong(1,j)>0
        hplongavg(1,j)=hplongavg(1,j)/counthplong(1,j);
    end
end
% -- Compute Average Holding Period for Short Trades --
hpshort=zeros(size(c));
for i=1:nsteps-1
    for j=1:ncols
        if HoldShort(i,j)~=0 && HoldShort(i+1,j)==0
           hpshort(i,j)=HoldShort(i,j);
        else
            hpshort(i,j)=0;
        end
    end
end
hpshortavg=zeros(1,ncols);    counthpshort=zeros(1,ncols);
for i=1:nsteps-1
    for j=1:ncols
        if hpshort(i,j)~=0
          hpshortavg(1,j)=hpshortavg(1,j)+hpshort(i,j);
          counthpshort(1,j)=counthpshort(1,j)+1;
        end
    end
end
for j=1:ncols
    if counthpshort(1,j)>0
        hpshortavg(1,j)=hpshortavg(1,j)/counthpshort(1,j);
    end
end


%function ZZ = ZigZag(xdates, x, xvolume, direction, percentX)
 
xdates = datagb.dateBench;
x = datagb.c(:,1);
direction = 0;
%Volume=xvolume;
Dateset = x;
Datestartstr = Dateset(1);
 
% =============================================
% ============== ZigZag =======================
% =============================================
 
%When a change is detected Direction
percentX=3;
 
% direction =  0 unknown slope of the current Arms
% direction =  1 positive slope of the current Arms
% direction = -1 negative slope of the current Arms
%direction=0;
 
% In ZZ the turning points are stored . The first
% ZigZag - point is the first available for x.
ZZ=0;
ZZ(1,1)=Dateset(1);
ZZ(1,2)=x(1);
 
% In SF  the times are a Direction change
% saved and displayed . Important since the time of
% Direction change not from the date of decision
% coincides for a Direction change. ZigZag looks
% not special in the future in the past. 
SF=0;
SF(1,1)=direction;
 
% Algorithm
j=1;
for i=2:length(x)
 
    % Current price deviation in percent for the last
    % Found highest or lowest ZigZag Course

    relx  = (x(i)-ZZ(j,2))/ZZ(j,2)*100;
 
    % Section will only run through once at the beginning 
    % Here is first after the first possible Direction
    % searched. Here the current price from the first course must
    % differ by at least a percentage , so that then a
    % Direction can be decided. This date and
    % the acute elle course form the second point of the
    % ZigZag-curve
    if (abs(relx)>=percentX) && (direction==0)
        j=j+1;
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=x(i);
        direction=sign(relx);
    end
 
    % If the price continues to rise save it in the
    % current ZigZag point
    if (x(i)>=ZZ(j,2))   && (direction==1)
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=x(i);
    end
        
    % If the current price of the last peak of ZZ
    % under percentage is and Rich actuation is positive,
    % must now take place Direction change . The price
    % therefore tends to be.
    % For this, a new ZigZag - point with the current
    % price generate and modify the Direction.
    if (relx < -percentX) && (direction==1)
        direction=-1;
        j=j+1;
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=x(i);
    end
 
    % If the price falls further save it in the
    % current ZigZag-point.
    if (x(i)<ZZ(j,2))    && (direction==-1)
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=x(i);
    end
    
    % if the last price is lower than ZZ
    % is below per cent and the Rich actuation is positive,
    % must now take place Direction change . Of course
    % increases accordingly tend.
    % For this, a new ZigZag - point with the current
    % Course generate and modify the Direction

    if (relx >= percentX) && (direction==-1)
        direction=1;
        j=j+1;
        ZZ(j,1)=Dateset(i);
        ZZ(j,2)=x(i);
    end
 
    % When the relx -percentX moved within +
    % and no new high, lowest value was found
    % do nothing to compare with the next course

    
    % Direction for each day of the course
    SF(i,1)=direction;
end
 
% Last Trade shall terminate the ZigZag Course . Regardless of whether
% positive or negative Direction . The Direction can
% change only through future courses 
j=j+1;
ZZ(j,1)=Dateset(i);
ZZ(j,2)=x(i);
 
% show
figure
hold on
 
plot(Dateset,x, 'linewidth',3,'color','k')
axis([Dateset(1) Dateset(end) min(x) max(x)]);
dateaxis('x',2,Datestartstr)
 
avg1= 3;        % 3 days
avg2= 15;       % 15 days
 
[Avg1set,Avg2set]=movavg(x, avg1, avg2, 1);
plot(Dateset,Avg1set,'linestyle','--', 'linewidth',2,'color','g')
plot(Dateset,Avg2set,'linestyle','--', 'linewidth',2,'color','c')
 
plot(ZZ(:,1),ZZ(:,2)','linestyle','--', 'linewidth',3,'color','r')
DHLx=max(x)-min(x);
plot(Dateset,(SF+1)/2*DHLx*0.9+min(x)+DHLx*0.05,'linestyle','--', 'linewidth',1,'color','b')


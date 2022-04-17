

function grosswgtL = longWeight(rowIdx, nbStocksLong, volat, Q, nbStocksExcluded )

    ncols = size(volat,2);

    grosswgtL=zeros(1,ncols); 
    volatInv = volat(rowIdx,:) .^ -1;
    volatInv(volatInv==Inf) = NaN;
    mvolatInv = nanmean(volatInv);
    volatInv(isnan(volatInv)) = mvolatInv;
    volatx=zeros(1,1);   
    volIdx=zeros(1,1);
    for j=1:ncols
        if Q(1,j) >= (ncols-nbStocksExcluded) - nbStocksLong + 1
            volatx = [volatx, volatInv(1,j)];
            volIdx = [volIdx,j];
        end
    end
    volatx(:,1)=[];         volIdx(:,1)=[];
    plw = PercentileRank(volatx','excel')'; plw = AdjustedPercentile1(plw, 3);
    plw = plw/sum(plw);
    if size(plw,2)==nbStocksLong
        for u=1:nbStocksLong,   grosswgtL(1,volIdx(:,u)) = plw(1,u);     end
    else
        grosswgtL=ones(1,ncols)/nbStocksLong;
    end
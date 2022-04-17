

function grosswgtS = shortWeight(rowIdx, nbStocksShort, volat, Q, nbStocksExcluded )

    ncols = size(volat,2);
    volatInv = volat(rowIdx,:);
    volatInv(volatInv==Inf) = NaN;
    mvolatInv = nanmean(volatInv);
    volatInv(isnan(volatInv)) = mvolatInv;
    volatx=zeros(1,1);   
    volIdx=zeros(1,1);
    for j=1:ncols
        if Q(1,j) <= nbStocksShort
            volatx = [volatx, volatInv(1,j)];
            volIdx = [volIdx,j];
        end
    end
    volatx(:,1)=[];        volIdx(:,1)=[];
    plw = PercentileRank(volatx','excel')'; plw = AdjustedPercentile1(plw, 3);
    plw = plw/sum(plw);
    if size(plw,2)==nbStocksShort
        for u=1:nbStocksShort,   grosswgtS(1,volIdx(:,u)) = plw(1,u);    end
    else
        grosswgtS=ones(1,ncols)/nbStocksShort; % safety proceudre if data issue
    end    
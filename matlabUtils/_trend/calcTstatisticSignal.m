function [signal,  signalCubeStruct,  rawTstatCubeStruct] = calcTstatisticSignal(data,config,portConfig,fParam,spliceDate,TZ)


if isempty (spliceDate) || isnan (spliceDate)
    simStartDate = config.simStartDate; 	
else  
    simStartDate = spliceDate; 
end
t0 = find(data.dates >= simStartDate , 1 ); 
%data2 = startDataTrunc(data,config,t0); 

subStratConfig = portConfig.subStrat(fParam.subStrategyNum); 
% select subset of chosen asset class:
data.header = data.header(:,subStratConfig.indx);
data.close = data.close(:,subStratConfig.indx);
data.range = data.range(:,subStratConfig.indx);
data.values = data.values(:,subStratConfig.indx);
data.timezone = data.timezone(:,subStratConfig.indx);
data.startDates = data.startDates(:,subStratConfig.indx);
data.endDates = data.endDates(:,subStratConfig.indx);




[T,N] = size(data.values);
K = length(fParam.lookbacks); 
signalCube = zeros(T,N,K); 
normTstatCube = zeros(T,N,K); 
rawTstatCube= nan(T,N,K);
logCumRtn= log(calcCum  (data.close, 1  ) );
logCumRtn(isnan (data.close)) = nan; 


if isfield (fParam, 'fetchTstatOption')  
        fetchTstat= fParam.fetchTstatOption ; 
else 
    fetchTstat= false ; 
end 




    


for k =1 : K
    L = fParam.lookbacks(k);
    if fetchTstat 
        oldtstatCube = fetchTstats( data.header, L , data.dates(t0) , data.dates(end) , TZ );
        lastTstatIndex= find (sum(~isnan(oldtstatCube.values),2)==length(data.header), 1, 'last');
        if isempty (oldtstatCube.dates ) || isempty (lastTstatIndex)
            calcTstatIndex =  t0; 
        else 
            rawTstatCube(:,:,k)= alignNewDatesJC(oldtstatCube.dates(1:lastTstatIndex),oldtstatCube.values(1:lastTstatIndex,:), data.dates );
            calcTstatIndex  =find(data.dates <= oldtstatCube.dates(lastTstatIndex) , 1 , 'last') ; 
        end 
    else 
        calcTstatIndex =  t0;
    end 
    X= 1:L; 
    for t =calcTstatIndex:T
        Ys = logCumRtn(t-L+1:t,: );
        rawTstatCube (t, sum(~isnan(Ys))/L <0.5, k )= 0 ;
        Ns= find (~isnan(logCumRtn(t,:))& (rawTstatCube (t, :, k )~=0 ));
        for n=Ns
            Y= Ys(:,n); 
            stats= regstats(Y,X,'linear',{'tstat'});%mdl = fitlm(X,Y);
            rawTstatCube(t,n,k)= stats.tstat.t(2);%mdl.Coefficients.tStat(2);
        end 
    end 
     if fetchTstat 
         storeNewTstat (data.dates(calcTstatIndex:end), rawTstatCube(calcTstatIndex:end, :, k), L ,data.header   );
     end 

    normTstatCube(:, :, k)= rawTstatCube(:, :, k)/sqrt(L-1);
    signalCube(:, :, k) = squashTstat( normTstatCube(:, :, k), fParam )  ; 
end 
signal0= mean(signalCube, 3 ); 





% structure output variable: 
%t0 = find(data.dates== data2.dates(1));
% t0 =strt_i ; 
signal.assetIDs = data.header; 
signal.dates = data.dates(t0:end,:); 
signal.values = signal0(t0:end,:); 
signal.assets = data.header; 
signalCubeStruct.assetIDs = data.header; 
signalCubeStruct.dates = data.dates(t0:end,:); 
signalCubeStruct.values = signalCube(t0:end,:,:);
signalCubeStruct.assets = data.header; 


rawTstatCubeStruct.assetIDs = data.header; 
rawTstatCubeStruct.dates = data.dates(t0:end,:); 
rawTstatCubeStruct.values = rawTstatCube(t0:end,:,:);
rawTstatCubeStruct.lookbacks = fParam.lookbacks;
rawTstatCubeStruct.assets = data.header; 


end % fn
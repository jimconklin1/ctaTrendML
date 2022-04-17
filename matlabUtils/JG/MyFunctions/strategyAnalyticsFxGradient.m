%
%__________________________________________________________________________
%
% Strategy analytics for period reshuffle
% strategyStyle:
% - stratregy style is times series 
% - or cross/section, periodic
% Inputs:
%       - vector column of time stamp
%       - signals
%       - weights
%       - portoflio equity curve
%       - assetReturns, matrix of individual asset return (usal name in my
%       setup: netret)
%__________________________________________________________________________
%

function analyticsT = strategyAnalyticsFxGradient(datesStamp, s,wgt, ptfec, assetReturns, strategyStyle, doChart)

% dimensions
[nsteps,ncols] = size(s);
% find when strategy starts
startRow=zeros(1,1);
for i=1:nsteps
    if ptfec(i)~=100
        startRow(1,1)=i;
        break
    end
end
        
% Gross exposure
grossExpo = sum(wgt,2);
grossExpo1yMa = arithmav(grossExpo,256);
% Net exposure
netWgt = s .* wgt;
netExpo = sum(netWgt,2);
netExpo1yMa = arithmav(netExpo,256);
% Daily returns
dailyReturns = Delta(ptfec(startRow-1:nsteps,:),'roc',1);
% Number of days in the market, Percentage of total days
sumsAbs = sum(abs(s(startRow-1:nsteps,:)),1)/(nsteps-startRow+1);
pctDaysInvolved = 100*mean(sumsAbs); % if several assets, take the simple average across assets

% Compute the number of trades & Hit ratio
if strcmp(strategyStyle,'TimeSeries') || strcmp(strategyStyle,'timeSeries') || strcmp(strategyStyle,'ts')
   
    % Number of trades
    ds = abs(Delta(s(startRow-1:nsteps,:),'dif',1));
    dsSum = sum(ds,1);
    totNbTrades = sum(dsSum);
    % Hit ratio
    hr = zeros(1,ncols);
    for j=1:ncols
        tempX=zeros(nsteps,2);
        for i=startRow-1:nsteps
            if (s(i,j)~=s(i-1,j) && s(i-1,j)~=0) || (s(i,j)==0 && s(i-1,j)~=0)
                tempX(i,1)=1;
                if assetReturns(i,j) > 0
                    tempX(i,2)=1;
                end
            end
        end
        hr(1,j) = sum(tempX(:,2))/sum(tempX(:,1));
    end
    hitRatio = 100*mean(hr);
    
elseif strcmp(strategyStyle,'periodWeek')
    
    % Hit ratio
    hr = zeros(nsteps,ncols);
    countX = 0;
    for i=startRow-1:nsteps
        if datesStamp(i)~=datesStamp(i-1) 
            countX=countX+1;
            dRetr = assetReturns(i,:)-assetReturns(i-1,:);
            nbPositive = sign(dRetr)>0;
            hr(i,:) = nbPositive;
        end
    end
    shr = sum(hr,1)/countX;
    hitRatio = 100*mean(shr);      
    
elseif strcmp(strategyStyle,'periodMonth')
    
    % Number of trades
    dsX=zeros(1,1);
    for i=startRow-1:nsteps
        if datesStamp(i)~=datesStamp(i-1)
            dsSum = sum(abs(s(i,:)-s(i-1,:)));
            dsX = [dsX;dsSum];
        end
    end 
    totNbTrades = sum(dsX);
    
    % Hit ratio
    hr = zeros(nsteps,ncols);
    countX = 0;
    for i=startRow-1:nsteps
        if datesStamp(i)~=datesStamp(i-1) 
            countX=countX+1;
            dRetr = assetReturns(i,:)-assetReturns(i-1,:);
            nbPositive = sign(dRetr)>0;
            hr(i,:) = nbPositive;
        end
    end
    shr = sum(hr,1)/countX;
    hitRatio = 100*mean(shr);    
   
end

% positive / negative returns
totPerReturns = dailyReturns;%(startRow-1:nsteps,:);
nbTotPerReturns = size(totPerReturns,1);
totPerReturnsPositive = totPerReturns(totPerReturns > 0);
totPerReturnsNegative = totPerReturns(totPerReturns < 0);
% Information & Sortino Ratio & Maximum Drawdown
totPerIr = 16 * mean(totPerReturns) / std(totPerReturns);
totPerSR = 16 * mean(totPerReturns) / std(totPerReturnsNegative);
[totPerHistMaxDd, totPerMaxDd, totPerMaxDddate] = drawdown(totPerReturns,'return');
% bus day
totPerBusDays = computeBusDate(totPerReturns);
totPerBusDaysPctPosdays = 100 * totPerBusDays / size(totPerReturnsPositive,1);
totPerBusDaysPctdays = 100 * totPerBusDays / size(totPerReturns,1); 
% transaction cost, % of gross
%totPerTc = totPerallGeoplWeightedComb(nbTotPerReturns) / totPerallGeoplGrossWeightedComb(nbTotPerReturns) - 1;
% turnover, % AUM
%totPerturnoverPtf = turnoverPtf(startIsDateIdx : nsteps); 
% FX-level contribution
%totPerfxnetretCumsum = fxnetretCumsum(startIsDateIdx : nsteps, :);
%totPerFxContrib = 100 * totPerfxnetretCumsum(end,:) / sum(totPerfxnetretCumsum(end,:),2);    
    
outputTotPer = [ nbTotPerReturns ,       pctDaysInvolved, totNbTrades, ...   
                100*mean(totPerReturns), 100*median(totPerReturns), ...    
                totPerIr,                totPerSR,        hitRatio, ...                
                100*size(totPerReturnsPositive,1) / nbTotPerReturns , ...
                100*max(totPerReturns),  100*min(totPerReturns), ...
                100*mean(totPerReturnsPositive), 100*mean(totPerReturnsNegative), ...
                100*totPerMaxDd,  ...
                totPerBusDays, totPerBusDaysPctPosdays, totPerBusDaysPctdays];              
% Positive day
VariableNames = {'TotalNbofDays',  'pctDaysInvolved',   'totNbTrades', ...
                 'AvgDailyReturn', 'MedianDailyReturn', ...
                 'InfoRatio',      'SortinoRatio',      'hitRatio', ...  
                 'PctPositiveDays', ...
                 'MaxDailyReturn', 'MinDailyreturn', ...
                 'AvgPositiveDailyReturn', 'AvgNegativeDailyReturn', ...
                 'MaxDrawdown', ...
                 'Nbusday', 'NbusdayPctPositiveDays', 'NbusdayPctAllDays'};

analyticsT = array2table(outputTotPer, 'VariableNames', VariableNames);        
             
if doChart == 1
    
    fig = figure;
    %subplot(2,2,1);
    x=1;      y=5;    width=1500;  height=700; 
    set(fig,'Position',[x y width height]);
    dataT = cell(length(VariableNames),2);
    for u=1:17
        dataT(u,1) = VariableNames(u);
        dataT(u,2) = num2cell(outputTotPer(u));
    end
    columnname =   {'Analytics', 'Value'};
    columnformat = {'char', 'numeric'}; 
    hTable = uitable('Units','normalized','Position', [0.2 0.5 0.15 0.48],  'Data', dataT, 'ColumnName', columnname, 'ColumnFormat', columnformat, 'RowName',[]);
    % Find the size of data
    dataSize = size(dataT);
    % Create an array to store the max length of data for each column
    maxLen = zeros(1,dataSize(2));
    % Find out the max length of data for each column
    % Iterate over each column
    for i=1:dataSize(2)
          % Iterate over each row
          for j=1:dataSize(1)
              len = length(dataT{j,i});
                % Store in maxLen only if its the data is of max length
                if(len > maxLen(1,i))
                    maxLen(1,i) = len;
                end
          end
    end
    % Some calibration needed as ColumnWidth is in pixels
    maxLenMod = [maxLen(1,1),9.5];
    cellMaxLen = num2cell(maxLenMod*7);
    %set(hTable, 'Data', data);
    % Set ColumnWidth of UITABLE
    set(hTable, 'ColumnWidth', cellMaxLen);

    hold on
            
    subplot(2,2,2);  
    %x=150;      y=50;    width=1800;  height=900; 
    set(fig,'Position',[x y width height]);
    tsobjPtfec = fints(datesStamp, ptfec);
    plot(tsobjPtfec);   title('geometric equity curve'); legend('geometric equity curve');
    %set(gca,'Position',[0.15 0.4 4, 4])
    subplot(2,2,3); 
    tsobjnetExp = fints(datesStamp, [netExpo, netExpo1yMa]); 
    plot(tsobjnetExp);   title('Net Exposure');  legend('Net Epxosure','1-year moving average');
    subplot(2,2,4);
    tsobjtotExp = fints(datesStamp, [grossExpo, grossExpo1yMa]); 
    plot(tsobjtotExp);   title('Total Exposure');  legend('Gross Epxosure','1-year moving average');
%     
end
   
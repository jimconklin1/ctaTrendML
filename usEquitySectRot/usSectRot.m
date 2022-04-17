%
%__________________________________________________________________________
%
% US Sector Rotation
% The model is simply based on momenta & stability
% Naive rebalancing at the end of the month
% 
%__________________________________________________________________________
%

function [output,bestSectorT, shT, wgthT, drhT] = usSectRot(configData,dataSet,factors)

% -- upload data --
o = dataSet.o;  h = dataSet.h;  l = dataSet.l;  c = dataSet.c;
dateNum = dataSet.dateNum;
dateBench = dataSet.dateBench;
% -- upload factors --
c5dr = factors.c5dr;
c12mr = factors.c12mr;
c6mr = factors.c6mr;
c3mr = factors.c3mr;
% residmom12m = factors.residmom12m;
% mompure12m = factors.mompure12m; 
kpv = factors.kpv;
%pkpv = factors.pkpv;
%pvrt = factors.pvrt;
vrp = factors.vrp;
volat = factors.volat;
universe = dataSet.instrumentList;
%
%__________________________________________________________________________
% Set Dimension & Prelocation
[nsteps,ncols]=size(c); nbStocks=ncols;                       % Dimensions
vwap = c; p = ChoseExecutionPrice(o,h,l,c,vwap, 'vwap', 0.7); % Execution price (tomorrow open price)
%
% Pre-locate matrix--------------------------------------------------------
ptfret=zeros(size(c,1),1);
volptf=zeros(size(c,1),1);
s=zeros(size(c));           % Signals
ExecP=zeros(size(c));       % Execution Prices
nb=zeros(size(c));          % Number of Shares
wgt=zeros(size(c));         % Weightts
tottrancost=zeros(size(c));     
grossreturn=zeros(size(c));     %ec=zeros(size(c));
tcforec=zeros(size(c)); 
GeoEC=zeros(size(c)); 
HoldPeriodLong=zeros(size(c));  % Holding Period Short
HoldPeriodShort=zeros(size(c)); % Holding Period Long
MaxIncLong=zeros(size(c));      % Maximun Price Incursion of Long Trade
MinIncShort=zeros(size(c));     % Minimum Price Incursion of Short Trade 
dateNumPushFwd = zeros(nsteps,1);
dateNumPushFwd(1:nsteps-1) = dateNum(2:nsteps);
dateNumPushFwd(end)=dateNumPushFwd(end-1);
%
capital=100000;                                   % Capital
beep = 0.0001; TC = beep * configData.transCost;  % Transaction cost
%

% -- not enough points for 2 etf --
residmom12m(:,4) = NaN(nsteps,1);  residmom12m(:,9) = NaN(nsteps,1);
c12mr(:,4) = NaN(nsteps,1);        c12mr(:,9) = NaN(nsteps,1);
c6mr(:,4) = NaN(nsteps,1);         c6mr(:,9) = NaN(nsteps,1);
c1mr(:,4) = NaN(nsteps,1);         c1mr(:,9) = NaN(nsteps,1);
kpv(:,4) = NaN(nsteps,1);          kpv(:,9) = NaN(nsteps,1);
nbStocksExcluded = 2;

% Step 5.: Extract Trading Signal__________________________________________
for i = 200:nsteps %- 250

    % update transaction cost
    %TC = tcMat(i,:);
    
    if month(dateNum(i)) ~= month(dateNumPushFwd(i))
        f1 = c12mr(i,:);        f1pg = PercentileRank(f1','excel')';   f1p = AdjustedPercentile1(f1pg, 3);  %  solution with residuals
        f2 = c6mr(i,:);         f2pg = PercentileRank(f2','excel')';   f2p= AdjustedPercentile1(f2pg, 3); % solution with lagged modelled momenta 
        f3 = c5dr(i,:);         f3pg = PercentileRank(f3','excel')';   f3p = AdjustedPercentile1(f3pg, 3); % spread in 2 year rate 
        f4 = kpv(i,:);          f4pg = PercentileRank(f4','excel')';   f4p = AdjustedPercentile1(f4pg, 3); % spread in 2 year rate         
        mrf = 1 *f1p  + 1 * f2p + 1 * (100-f3p) + 1 * (100-f4p);
        %mrf = 1 * f1p  + 0.3 * (100-f3p)  + 0.5 * (100-f4p);
        Q = NominalRank(mrf','excel')';
        mrfRk = Q; 
        
        % -- Compute weights for long stocks : invert in volatility --
        % The LOWER volatility, the higher the weight
        nbStocksLong = 3;
        grosswgtL = longWeight(i, nbStocksLong, volat, Q, nbStocksExcluded );
        
        % -- Compute weights for short stocks : positive in volatility -- 
        % The HIGHER volatility, the higher the weight
        nbStocksShort = 3;
        grosswgtS = shortWeight(i, nbStocksShort, volat, Q, nbStocksExcluded );     
        
    end

    % -- Algo --
    for j=1:ncols
        % - Enter Short - 
        if  month(dateNum(i)) ~= month(dateNumPushFwd(i)) && mrfRk(1,j) <= nbStocksShort && vrp(i) < 0 
            s(i,j)=-1 ;                                     % Compute # of Shares
            wgt(i,j) = grosswgtS(1,j);%1/nbStocksShort;                     % Weights
            ExecP(i,j)=+p(i,j)*(1-TC(1,j));                 % Entry price - Short
            HoldPeriodShort(i,j) = 0;                       % Short Trade Duration
            MinIncShort(i)=c(i);                            % Minimum Price Incursion of Short Trade 
        % - Hold Short Position -.5
        elseif s(i-1,j) == -1 && month(dateNum(i)) == month(dateNumPushFwd(i)) %&& vrp(i) < 10
            s(i,j)=-1;                                      % Update Signal
            nb(i,j)=nb(i-1,j);                              % Update # of Shares
            wgt(i,j)=wgt(i-1,j);                            % Update Weights
            ExecP(i,j)=ExecP(i-1,j);                        % Update Execution Price
            HoldPeriodShort(i,j)=HoldPeriodShort(i-1,j)+1;  % Update Short Trade Duration
            MinIncShort(i)=min(c(i),MinIncShort(i-1));      % Update Minimum Price Incursion of Short Trade 
        end
        % - Enter Long -  
        if   month(dateNum(i)) ~= month(dateNumPushFwd(i)) && mrfRk(1,j) >= (ncols-nbStocksExcluded) - nbStocksLong + 1 %&& (vrp(i) > 0 || vrp(i) >= vrp(i-5))
            s(i,j)=+1;                                      % Signal %c(i,j) < mas(i,j)
            nb(i,j)=1;%capital/p(i,j);                      % Compute # of Shares
            wgt(i,j) = grosswgtL(1,j);%1/nbStocksLong;                      % Weights
            ExecP(i,j)=-p(i,j)*(1+TC(1,j));                 % Entry price - Long
            HoldPeriodLong(i,j)=0;                          % Long Trade Duration            
            MaxIncLong(i,j)=c(i,j);                         % Maximun Price Incursion of Long Trade
        % - Hold Long Position 
        elseif s(i-1,j)==1  &&  month(dateNum(i)) == month(dateNumPushFwd(i)) %&&   vrp(i) > -5
            s(i,j)=+1;                                      % Update Signal 
            nb(i,j)=nb(i-1,j);                              % Update # of Shares
            wgt(i,j) = wgt(i-1,j);                          % UpdateWeights                  
            ExecP(i,j)=ExecP(i-1,j);                        % Update Execution Price
            HoldPeriodLong(i,j)=HoldPeriodLong(i-1,j)+1;    % Update Holding Period            
            MaxIncLong(i,j)=max(c(i,j),MaxIncLong(i-1,j));  % Update Maximun Price Incursion of Long Trade
        end    
    end
    % -- Profit --
    for j=1:nbStocks
        [grossreturn_i , tcforec_i] = Compute_StockFuture_PL(i, j, c, p, ExecP, s, wgt, nb, TC);
        grossreturn(i,j) = grossreturn_i;   
        tcforec(i,j) = tcforec_i;
    end
end
%
% -- Compute Equity Curve for Portfolio --
[ptfec, ptfpl,cumulnetret, stratreturn, netret] = Compute_EquityCurve(c, grossreturn, tcforec);
%
% -- Analyse P&L --
 analyticsBo = strategyAnalytics(dateNum, s, wgt, ptfec, netret, 'timeSeries', 1);
%
% -- Export Output --
output.s = s;
output.wgt = wgt;
output.s = s;
output.ptfec = ptfec;
output.pl = ptfpl;
dailyReturn = Delta(ptfec,'roc',1);
output.dailyReturn = dailyReturn;
%
% -- table --
nameT = cell2table(universe', 'VariableNames', {'Instruments'});
sT = array2table(s(end,:)', 'VariableNames', {'chosenSector'});
bestSectorT = [nameT , sT ];

%historical signals
sha = [dateNum, s];
nameList = {'date', 'XLY', 'XLP', 'XLE', 'XLFS', 'XLF', 'XLV', 'XLI', 'XLB', 'XLRE', 'XLK', 'XLU'};
shT = array2table(sha, 'VariableNames', nameList);
%
%historical weights
wgtha = [dateNum, wgt];
nameList = {'date', 'XLY', 'XLP', 'XLE', 'XLFS', 'XLF', 'XLV', 'XLI', 'XLB', 'XLRE', 'XLK', 'XLU'};
wgthT = array2table(wgtha, 'VariableNames', nameList);
%
% dailyr return
drha = [dateNum, dailyReturn];
drhT = array2table(drha, 'VariableNames', {'date','dailyReturn'});







function portStruct = calcDDandPnL3(configPortfolio, dataSet, portStruct)

% NOTE: version 2, unlike calcDDandPnl(), does not use the portfolio
%   structures of the suite of trend models.  Rather, 

T = size(portStruct.dates,1); 
if isfield(portStruct,'indx')
   nn = portStruct.indx; 
elseif isfield(portStruct,'assetIndx')   
   nn = portStruct.assetIndx; 
else 
   nn = 1:size(portStruct.header,2); 
end 
N = length(nn); 

if ~isfield(dataSet,'values') && isfield(dataSet,'close')
   rtnCl = dataSet.close(:,nn); 
else
   rtnCl = dataSet.values(:,nn); 
end
rtnCl = alignNewDatesJC2(dataSet.dates,rtnCl,portStruct.dates,[],true);
TC = configPortfolio.TC; % dim = 1 x N
t1 = max(findFirstGood(portStruct.wts(:,1),NaN),3); 
minTrd = configPortfolio.minTrade;
% if isfield(configPortfolio,'borrowFees')
%    shortSecs = configPortfolio.borrowFees(:,1)';
%    shortBrrwRate = configPortfolio.borrowFees{:,2}';
%    shtIndx = mapStrings(portStruct.header,shortSecs,false);
% else 
%    shtIndx = [];
% end 
pnl = zeros(T,N); 
pnlPos = zeros(T,N); 
% pnlTrdg = zeros(T,N); 
pnlTC = zeros(T,N); 
% pnlBrrw = zeros(T,2); 
pnlTot = zeros(T,1); 
cumPnl = ones(T,1); 
if ~configPortfolio.ddOpt
    for t = t1+1:T
        pnlPos(t,:) = portStruct.wts(t-2,:).*rtnCl(t,:); % 24-hour lag assumed
%        pnlTrdg(t,:) = (portStruct.wts(t-1,:)-portStruct.wts(t-2,:)).*(pxCl(t,:)./pxOp(t,:)-1);
        pnlTC(t,:) = -0.5*abs(portStruct.wts(t-1,:)-portStruct.wts(t-2,:)).*TC/10000; % TCs are full bid-ask equiv
%         if ~isempty(shtIndx) && nansum(portStruct.wts(t-1,shtIndx)<0)>0
%            pnlBrrw(t,shtIndx) = portStruct.wts(t-1,shtIndx)*shortBrrwRate(shtIndx)/(260*10000);
%         end 
%        pnl(t,:) = nansum([pnlPos(t,:); pnlTrdg(t,:); pnlTC(t,:); pnlBrrw(t,:)],1); 
        pnl(t,:) = nansum([pnlPos(t,:); pnlTC(t,:)],1); 
        pnlTot(t,:) = sum(pnl(t,:),2); 
        cumPnl(t,1) = cumPnl(t-1,1)*(1+pnlTot(t,:)); 
    end % for
else % drawDown = true
    if ~isfield(configPortfolio,'targVol') && isfield(configPortfolio,'portVolTarget')
       baseVol = configPortfolio.portVolTarget;
    else
       baseVol = configPortfolio.targVol;
    end 
    dd = configPortfolio.dd;
    wts = portStruct.wts;
    ddWts = wts;
    ddVol = repmat(baseVol,[T,1]);
    drawdown = zeros(T,1);
    Ddrawdown = zeros(T,1); % decayed draw-down
    cumPnl = ones(T,1); 
    HWmark = ones(T,1); 
    decayedHWmark = ones(T,1);
    hwDate = dataSet.dates;
    ddParams = [dd.A,(1-dd.maxDD),dd.lambda,dd.mu,dd.sigma]; 
    ddSR = dd.mu/dd.sigma;
    temp = ddWts(t1-2:t1,:); 
    temp(isnan(temp))=0; 
    ddWts(t1-2:t1,:) = temp;
    for t = t1:T
        % see block A, below, for example code on draw-down mechanics
        u = (1-Ddrawdown(t-1)); 
        vScale = ddScale(ddParams, u); 
        ddVol(t) = vScale*ddSR/ddParams(1); 
        if (ddVol(t) > baseVol)
            ddVol(t) = baseVol; 
        end 
        if (ddVol(t) < dd.minVol)
            ddVol(t) = dd.minVol; 
        end 
        if ismember(portStruct.dates(t),dataSet.holidays.datenum_holiday)
            ddWts(t,:) = ddWts(t-1,:); 
        else % note: here we impose minimum trade change; default units assume NAV of 1
            ddWts(t,:) = ddWts(t-1,:); 
            tempWts = (ddVol(t)/baseVol)*wts(t,:);
            bool = abs(tempWts - ddWts(t-1,:)) > minTrd;
            ddWts(t,bool) = tempWts(:,bool); 
        end % if
        
        % basic PnL calcs:
        pnlPos(t,:) = ddWts(t-2,:).*rtnCl(t,:); % 24-hour lag assumed
%        pnlTrdg(t,:) = (ddWts(t-1,:)-ddWts(t-2,:)).*(pxCl(t,:)./pxOp(t,:)-1);
        pnlTC(t,:) = -0.5*abs(ddWts(t-1,:)-ddWts(t-2,:)).*TC/10000; % TCs are full bid-ask equiv
%         if ~isempty(shtIndx) && nansum(ddWts(t-1,shtIndx)<0)>0 
%            pnlBrrw(t,shtIndx) = ddWts(t-1,shtIndx)*shortBrrwRate(shtIndx)/(260*10000);
%         end 
%        pnl(t,:) = nansum([pnlPos(t,:); pnlTrdg(t,:); pnlTC(t,:); pnlBrrw(t,:)],1); 
        pnl(t,:) = nansum([pnlPos(t,:); pnlTC(t,:)],1); 
        pnlTot(t,:) = sum(pnl(t,:),2); 
        cumPnl(t,1) = cumPnl(t-1,1)*(1+pnlTot(t,:)); 
        
        % decayed draw-down mechanics:
        if cumPnl(t,1) >= HWmark(t-1,1)
           hwDate(t,1) = t;
           HWmark(t,1) = cumPnl(t,1);
        else 
           hwDate(t,1) = hwDate(t-1,1);
           HWmark(t,1) = HWmark(t-1,1);
        end 
        tempDecayedHW = decayedHWmark(t-1,1)*exp(-dd.lambda/260);
        if cumPnl(t,1) >= tempDecayedHW
           decayedHWmark(t,1) = cumPnl(t,1);
        else
           decayedHWmark(t,1) = tempDecayedHW;
        end % if
        drawdown(t) = 1-cumPnl(t,1)/HWmark(t,1);
        Ddrawdown(t) = 1-cumPnl(t,1)/decayedHWmark(t,1);
    end % for t
    ddTrades = nan(T,N); 
    ddTrades(t1,:) = ddWts(t1,:);
    for t = t1+1:T
        ddTrades(t,:) = ddWts(t,:) - ddWts(t-1,:);
    end % for t
    portStruct.ddWts = ddWts;
    portStruct.ddTrades = ddTrades;
    portStruct.ddVol = ddVol;
end
% Under convention above, weights traded on date "t" are indexed wts(t-1),
%   since they are generated from data on close t-1.

% Convention for "bringing weights forward to trade day":
% portStruct.dates = busdate(portStruct.dates,1); NOT FOR VERSION 3...
portStruct.tradeDates = portStruct.dates; 
portStruct.pnlPos = pnlPos(2:end,:); 
portStruct.pnlPos(T,:)=0; 
% portStruct.pnlTrdg = pnlTrdg(2:end,:); 
% portStruct.pnlTrdg(T,:)=0; 
portStruct.pnlTC = pnlTC(2:end,:); 
portStruct.pnlTC(T,:)=0; 
% portStruct.pnlBrrw = pnlBrrw(2:end,:); 
% portStruct.pnlBrrw(T,:)=0; 
portStruct.pnlDD = pnl(2:end,:); 
portStruct.pnlDD(T,:)=0; 
portStruct.pnlTotDD = pnlTot(2:end,:); 
portStruct.pnlTotDD(T,:)=0; 
portStruct.cumPnlDD = cumPnl(2:end,:); 
portStruct.cumPnlDD(T,:) = portStruct.cumPnlDD(T-1,:); 
portStruct.rawRtns = rtnCl(2:end,:);
portStruct.rawRtns(T,:) = 0; 

if configPortfolio.ddOpt
   portStruct.ddrawdown = Ddrawdown(2:end,:);
   portStruct.ddrawdown(T,:) = portStruct.ddrawdown(end,:);
end

end % fn

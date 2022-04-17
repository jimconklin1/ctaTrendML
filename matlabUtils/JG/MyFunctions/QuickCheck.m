
LoadData = 1;
if LoadData == 1
    o=xp1(:,2);h=xp1(:,3);
    l=xp1(:,4);c=xp1(:,5);
    vol=xp1(:,6);
    % factor
    vol5d=Delta(vol,'roc',5);
    vol1d=Delta(vol,'roc',1);
    r1d=Delta(c,'roc',1);
    r5d=Delta(c,'roc',5);
    c2o=c./o;
    rsix = RSIFunction(c,3,3,20);
    %masrsix=expmav(rsix,13);    mafrsix=expmav(rsix,3);
    % -- Trend Strenght Index --
    [tsiatr, matsiatr] = TrendStrengthIndex(c,h,l, 'atr', [10,3]);   
    %[tsiwb, matsiwb] = TrendStrengthIndex(c,h,l, 'absdif', [32,5,3]);
    % -- Volatility --
    atr = ATRFunction(c,h,l,14,3);
    % -- Auto-correlation --
    %r1d = Delta(c,'roc',1);
    %ac60r1d = autocorr(r1d, 60, 1);       maac60r1d  = expmav(ac60r1d,3);
    %ac120r1d = autocorr(r1d, 120, 1);     maac120r1d  = expmav(ac120r1d,3);
    % -- MACD Normal, Fast & Sell Set-up --
    %[macdg, macds, hist, fhist, shist, ~, ~] = MACDFunction(c,'with 0',12,26, 9,[3,8],21);
    %[macdgf, macdsf, histf, fhistf, shistf, ~, ~] = MACDFunction(c,'with 0',6,19, 9,[3,8],21);
    %[macdgs, macdss, hists, fhists, shists, ~, ~] = MACDFunction(c,'with 0',19,39, 9,[3,8],21);
    % -- Stochastic Momentum --
    [sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[2,13,13,3]);  
    %[sm, smi, ssmi] = StochasticMomentumIndex(c,h,l,[3,13,13,13]);
    % -- Lane Stochastic -- 
    [lk,ld,lsd] = StochasticFunction(c,h,l,'ama',3,3,3);   
end

RunLogisticClassifier=1;
if RunLogisticClassifier==1
    x=[vol5d,vol1d,r5d,c2o,rsix,atr];
    cdif=c-ShiftBwd(c,1, 'z');
    cdif(cdif>0)=2;
    cdif(cdif<=0)=1;
    [probe,probf] = logitmodel(x, cdif, 30, 1);
end

%yf(isnan(yf))=0;
%ye(isnan(ye))=0;
%ppp=probf(:,2)-probe(:,2);
% mp=arithmav(ppp,89);
pl=zeros(size(c));
for i=20:nsteps-1
    if probe(i,1) > 0.999 && c(i)<c(i-1)%mp(i-1) && ppp(i)>mp(i)
        pl(i+1)=c(i+1)-c(i);
    elseif probe(i,2) > .9995 && smi(i)>smi(i-3)
        pl(i+1)=-c(i+1)+c(i);
    end
end
cumpl=cumsum(pl);plot(cumpl)

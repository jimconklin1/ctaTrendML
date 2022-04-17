function[s, sumprofit, sumgrossprofit]  =  DualMASyst(o, h, l, c, maf, mas)
%
%__________________________________________________________________________
%
% DUAL MOVING AVERAGE SYSTEM
%
%__________________________________________________________________________
%
%__________________________________________________________________________
% Set Dimension & Prelocation
% Dimensions---------------------------------------------------------------
nsteps=length(c);
% -- Execution price (tomorrow open price) --
ExecutionPriceSolution=1;
% -- Open Only --
if ExecutionPriceSolution==1 % Open price
    p(1:nsteps-1,1)=o(2:nsteps,1); p(nsteps,1)=p(nsteps-1,1);
% -- ATP --
elseif ExecutionPriceSolution==2 
    p(1:nsteps-1,1)=(o(2:nsteps,1)+h(2:nsteps,1)+l(2:nsteps,1)+c(2:nsteps,1))/4; p(nsteps,1)=p(nsteps-1,1);
% -- ATP geared toward Open --    
elseif ExecutionPriceSolution==3 
    open_weight=0.7;
    p(1:nsteps-1,1)=open_weight*o(2:nsteps,1) + (1-open_weight)/3*(h(2:nsteps,1) + l(2:nsteps,1) + c(2:nsteps,1)); p(nsteps,1)=p(nsteps-1,1);
% -- VWAP Only --
elseif ExecutionPriceSolution==4
    p(1:nsteps-1,1)=vwap(2:nsteps,1); p(nsteps,1)=p(nsteps-1,1);
% -- Average VWAP & Open --
elseif ExecutionPriceSolution==5
    open_weight=0.5;
    p(1:nsteps-1,1)=open_weight*o(2:nsteps,1)+(1-open_weight)*vwap(2:nsteps,1); p(nsteps,1)=p(nsteps-1,1); 
end
%
% Pre-locate matrix--------------------------------------------------------
    % .. Signals ..
    s=zeros(size(c));
    % .. Execution Prices ..
    ExecP=zeros(size(c));  
    % .. Number of Shares ..
    nb=zeros(size(c));
    % .. Weightts ..
    wgt=zeros(size(c));    
    % .. Profit ..
    profit=zeros(size(c));          sumprofit=zeros(size(c));
    grossprofit=zeros(size(c));     sumgrossprofit=zeros(size(c));
    tottrancost=zeros(size(c));     GeoEC=zeros(size(c)); 
    HoldShort=zeros(size(c));       HoldLong=zeros(size(c));  
%
% -- Capital --
capital=100000;
% -- Transaction cost --
TC=0.0025;
%
% Select Model-------------------------------------------------------------
Model=1;
%
% Step 5.: Extract Trading Signal__________________________________________
for i=144:nsteps   
    % Step 5.1. : Compute Min & Max----------------------------------------
    % No extra condition...................................................
    if Model==1     
        % Enter Short Stock------------------------------------------------
        if  s(i-1)~=-1 && maf(i)<mas(i)    
            % Signal
            s(i)=-1;  
            % Compute Number of Shares
            nb(i)=1;%capital/p(i); 
            % Sell Stock
            ExecP(i)=+p(i)*(1-TC); 
            % Short Trade Duration
            HoldShort(i)=0;         
        % Hold Short Stock.................................................
        elseif s(i-1)==-1 && maf(i)<mas(i)
            % Keep Signal
            s(i)=-1;  
            % Keep nb of shares
            nb(i)=nb(i-1);
            % Keep Execution Price
            ExecP(i)=ExecP(i-1);  
            % Increment Trade Duration
            HoldShort(i)=HoldShort(i-1)+1;         
        % Enter Long Stock-------------------------------------------------
        elseif s(i-1)~=1 && maf(i)>mas(i)
            % Signal
            s(i)=+1;  
            % Compute Number of Shares
            nb(i)=1;%capital/p(i);          
            % Buy Stock
            ExecP(i)=-p(i)*(1+TC);  
            % Long Trade Duration            
            HoldLong(i)=0;
        % Hold Long Stock...................................................
        elseif s(i-1)==1 && maf(i)>mas(i)
            % Keep Signal
            s(i)=+1;
            % Keep nb of shares
            nb(i)=nb(i-1);          
            % Keep Execution Price
            ExecP(i)=ExecP(i-1); 
            % Increment Trade Duration            
            HoldLong(i)=HoldLong(i-1)+1;          
        end              
    end
    % Step 5.2..: Profit---------------------------------------------------
    Ftc1=0; Ftc2=0; Ftc3=0;
    % Ftc1 = Factor when Trade Out
    % Ftc2 = Factor when Trade In
    % Ftc3 = Factor when Nb of shares is different for same signals
    if s(i-1)==s(i-2);
        Ftc1=0; % Factor when Trade Out
        Ftc2=0; % Factor when Trade In
    elseif s(i-2)==0 && s(i-1)~=0
        Ftc1=0; % Factor when Trade Out
        Ftc2=1; % Factor when Trade In
    elseif s(i-2)~=0 && s(i-1)==0
        Ftc1=1; % Factor when Trade Out
        Ftc2=0; % Factor when Trade In
    elseif (s(i-2)==1 && s(i-1)==-1) || (s(i-2)==-1 && s(i-1)==1)
        Ftc1=1; % Factor when Trade Out
        Ftc2=1; % Factor when Trade In
    end   
    if s(i)~=s(i-1) || (s(i)==s(i-1) && nb(i)==nb(i-1)) 
        Ftc3=0;
    elseif (s(i)==s(i-1) && nb(i)~=nb(i-1)) 
        Ftc3=1;
    else
        Ftc3=0;
    end
    grossprofit(i)= s(i-1)*nb(i-1)*(p(i)-p(i-1)) ; 
    tottrancost(i)= Ftc1*TC*nb(i-2)*p(i-1) + Ftc2*TC*nb(i-1)*p(i-1) + Ftc3*TC*abs(nb(i-1)-nb(i-1))*p(i)  ;
    profit(i)=grossprofit(i)-tottrancost(i);
    % Step 5.3.: Sumprofit-------------------------------------------------
    sumgrossprofit(i)=sumgrossprofit(i-1)+grossprofit(i);
    sumprofit(i)=sumprofit(i-1)+profit(i);
end

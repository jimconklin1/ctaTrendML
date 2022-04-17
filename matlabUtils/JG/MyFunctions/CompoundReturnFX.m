function[pr,cstpr,cltpr,dcpr] = CompoundReturnFX(fx,DirectOrIndirect,...
                                                 ForwardOrRates,method,...
                                                 PeriodReturn,USDPosition,NbDaysYr,CumulPeriod)
%
% _________________________________________________________________________
%
% This function computes the compounded rate of returns for a FX compared to
% a base currency, aka, the USD based on the covered interest parity.
% It computes, Return(i)=Spot(i)/Forward(i-1)-1.
% Note that the CompoundReturn for the Base currency is identically Zero by
% construction.
%
% The forward exchange rate is :
%       - either reconstructed with the difference between the country and
%         the base-currency libor,
%       - or simply the market forward given by Bloomberg.
%       note: solution 1 is better.
% The sign of the difference between te country and the USD interest rates 
% depends upon the fact the close exchange rate are quoted in direct or 
% indirect ways.
%
% It also computes the cumulated rate of return over two periods (one short
% and one long) and the difference between these two cumulated returns.
%
% INPUT--------------------------------------------------------------------
%
%   fx = close spot exchange rates.........................................

%   "DirectOrIndirect" (+1/-1)...........................................
%   relates to the direction of the FX database
%
%   DirectOrIndirect = 1 - the database is INDIRECT
%   direct =   nb. of USD                 to buy 1 unit of domestic currency
%              note: Delta(E)/E <(>) 0 ....> Depreciation (Appreciation)
%
%   DirectOrIndirect = -1 - the database is DIRECT
%   indirect = nb. of domestic currencies to buy 1 USD
%              note: Delta(E)/E <(>) 0 ....> Appreciation (Depreciation)
%
%   ForwardOrRates   = Forward Exchange Rates or Libor.......................
%   note1 : this will impact the 'method' used (herebelow)
%   note 2: if the Libor rate is used, the number of column is equal to 
%   nb of columns in the FX database + 1.
% 
%   'method'...............................................................
%   relates to the fact that returns are computed with Market Forward
%   Exchange Rates or Reconstructed Forward Exchange Rates with Libor
% 
%   'method' =  - 'market_forward'
%               - 'reconstructed_forward'
%   
%   PeriodReturn = The priod used to compute gross return
%   note: if the database is monthly and one looks for monthly return, then
%   PeriodReturn=1.
%   If the database is daily and one looks for monthly returnm then
%   PeriodReturn=22.
%
%   USDPosition............................................................
%   The column number in the matrix of factors where the USD data 
%   is located
%
%   NbDaysYr...............................................................
%   Number of days in a year (e.g.: 260).
%
%   CumulPeriod............................................................
%   CumulPeriod(1,1) = COmpute the average period (Rescaling) or not
%   note: The rescaling applies as we use the following formula to compute
%   the returns:    step 1. - Cumulated returns over p days 
%                   step 2. - (Cumulated returns over p days) ^ 1/Period
%                              with periods in number of months for monthly
%                              returns
%   CumulPeriod(1,1) = 0 - No Rescaling
%   CumulPeriod(1,1) = 1 - Rescaling in number of months
%   CumulPeriod(1,2) = short-term period for cumulated returns
%   CumulPeriod(1,3) = long-term period for cunulated returns
%
% OUTPUT-------------------------------------------------------------------
%
% mr = matrix of monthly return
%
% cdr = matrix of cumulated returns
%
% PROCESS------------------------------------------------------------------
%
% Step 1.: Compute the continuously compounded rate (ccr) with the libor (r)
%          ccr = 12 * (ln(1+(r/100)/12))
%          note: r is downloaded through Bloomberg, and thus it is needed
%          to divide it by 100.
%
% Step 2.: Reconstruct the Implied Forward Exchange (IF) rate versus the USD
%          If the database is direct
%          IF(i)=Spot(i) * exp((ccr_usd(i) - ccr_country(i))/12);
%          If the database is indirect
%          IF(i)=Spot(i) * exp((ccr_country(i) - ccr_usd(i))/12);
%          We have the indicator function "direct_or_indirect"
%          IF(i)=Spot(i) * exp(direct_or_indirect*(ccr_usd(i) - ccr_country(i))/12)
%
% Step 3.: Compute the monthly return between the Spot (S) Forward Exchange
%          (F) Rates
%          pr(i)=S(i)/F(i-1)-1
%
% Step 4.: Compute the cumulated return
% 
% Note:BT database is monthly and direct quotation
% DirectOrIndirect    = 1;
% PeriodReturn        = 1;
% USDPosition         = 6(BT), my database, 1
% CumulPeriod         = [3,6];
% The method used 'reconstructed_forward'
% [pr,cstpr,cltpr,dcpr] = CompoundReturnFX1(fx,1,ForwardOrRates,...
%                                         'reconstructed_forward',1,...
%                                         1,[3,6]);
%__________________________________________________________________________

% Define dimesions & Prelocate matrices
[nsteps,ncols]=size(fx);      % Dimension
pr=zeros(nsteps,ncols+1);     % Period Returns
cstpr=zeros(nsteps,ncols+1);  % Cumulated Period Returns - Short-term period
cltpr=zeros(nsteps,ncols+1);  % Cumulated Period Returns - Long-term period
dcpr=zeros(nsteps,ncols+1);   % Delta in cumulated returns

% Error Message
if (CumulPeriod(1,1) < PeriodReturn && CumulPeriod(1,2) < PeriodReturn)
     error('CumulPeriod must be higher thant PeriodReturn');
end

% Compute Number of days in a month
NdDaysMth=round(NbDaysYr/12);

switch method
    case 'reconstructed_forward'
        % Step 1.: Add a 0 column vector for the USD to the exchange rate
        % matrix
        if USDPosition==1
            fx=[zeros(nsteps,1), fx];
        elseif USDPosition==ncols
            fx=[fx , zeros(nsteps,1)];
        end
        % Step 2.: Compute the continuously compounded interest rate (ccr)
        ccr=12 .* (log(ones(size(ForwardOrRates))+(ForwardOrRates ./ 100)./12));
        % Step 3.: Compute the implied forward exchange rate
        ImpliedForward=zeros(nsteps,ncols+1);
        for j=1:ncols+1
            if j==USDPosition
                ImpliedForward(:,j) = zeros(nsteps,1);
            else
                ImpliedForward(:,j) = fx(:,j) .* exp(DirectOrIndirect .* (ccr(:,USDPosition)-ccr(:,j)) ./NbDaysYr);
            end
        end
        % Step 3.: Compute the daily return between the Spot (S) and Forward Exchange (F) Rates
            % Push Forward the Forward Exchange Rates for convenience of
            % calculus
            ImpliedForward(PeriodReturn+1:nsteps,:)=ImpliedForward(1:nsteps-PeriodReturn,:);
            % Clean
            ImpliedForward(1:PeriodReturn,:)=zeros(PeriodReturn,ncols+1);
            % Compute Return
            for j=1:ncols+1
                if j~=USDPosition
                    pr(PeriodReturn+1:nsteps,j)=fx(PeriodReturn+1:nsteps,j) ./ ...
                         ImpliedForward(PeriodReturn+1:nsteps,j) - ones(nsteps-PeriodReturn,1);
                end
            end
    case 'market_forward'
    % Assign forward rate
    ForwardOrRates(PeriodReturn+1:nsteps,:)=ForwardOrRates(1:nsteps-PeriodReturn,:); 
    ForwardOrRates(1:PeriodReturn,:)=zeros(PeriodReturn,ncols+1);
    % Compute Return
    for j=1:ncols
        pr(PeriodReturn+1:nsteps,j+1)=fx(PeriodReturn+1:nsteps,j) ./ ...
                                        ForwardOrRates(PeriodReturn+1:nsteps,j) - ones(nsteps-PeriodReturn,1);
    end 
end

% Compute cumulated returns
prPlusOne=pr+ones(size(pr));
prPlusOne(1,:)=zeros(1,ncols+1); 
prPlusOne(:,USDPosition)=zeros(nsteps,1);
% Compute Duration of period in number of days
PowerPeriod=zeros(1,3);
PowerPeriod(1,2)=round(CumulPeriod(1,2)/NdDaysMth);
PowerPeriod(1,3)=round(CumulPeriod(1,3)/NdDaysMth);
% Cumulated returns for the Short-term period
for i=CumulPeriod(1,2):nsteps
    for j=1:ncols+1
        if j~=USDPosition
            mysumprod=cumprod(prPlusOne(i-CumulPeriod(1,2)+1:i,j));
            if CumulPeriod(1,1)==0
                cstpr(i,j)=mysumprod(length(mysumprod),1)-1;
            elseif CumulPeriod(1,1)==1
                cstpr(i,j)=mysumprod(length(mysumprod),1)^(1/PowerPeriod(1,2))-1;
            end
        end
    end
end
% Cumulated returns for the Long-term period
for i=CumulPeriod(1,3):nsteps
    for j=1:ncols+1
        if j~=USDPosition
            mysumprod=cumprod(prPlusOne(i-CumulPeriod(1,3)+1:i,j));
            if CumulPeriod(1,1)==0
                cltpr(i,j)=mysumprod(length(mysumprod),1)-1;
            elseif CumulPeriod(1,1)==1   
                cltpr(i,j)=mysumprod(length(mysumprod),1)^(1/PowerPeriod(1,3))-1;
            end
        end
    end
end
% Delta
dcpr=cstpr-cltpr;
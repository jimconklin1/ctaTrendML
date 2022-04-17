function duration = ComputeSwapDuration(SwapRate, TSDatenum, Tenor, Period, Basis)
%
%__________________________________________________________________________
%
% This function compute Duration in a recursive way using the matlab
% function "bnddury"
%
% Tenor: in number of years, for exemple 5, for a 5-year swap
% Basis:Day-count basis of the instrument. A vector of integers. 
        % 0 = actual/actual
        % 1 = 30/360 (SIA)
        % 2 = actual/360
        % 3 = actual/365
        % 4 = 30/360 (PSA)
        % 5 = 30/360 (ISDA)
        % 6 = 30/360 (European)
        % 7 = actual/365 (Japanese)
        % 8 = actual/actual (ISMA)
        % 9 = actual/360 (ISMA)
        % 10 = actual/365 (ISMA)
        % 11 = 30/360E (ISMA) 
        % 12 = actual/365 (ISDA)
        % 13 = BUS/252
% BaseYear: depends upon the basis for a given country (360 or 365)
% Period: Coupons per year of the bond (2 if semi-annual).
%
% note: TSDatenum is under format usally named tdaynum in my function
%__________________________________________________________________________
%

% -- Prelocation --
duration = zeros(size(SwapRate));
% -- Base year --
if Basis == 0 || Basis == 1 || Basis == 4 || Basis == 5 || Basis == 6 || Basis == 9  || Basis == 11 
    BaseYear=360;
elseif Basis == 2 || Basis == 3 || Basis == 7 || Basis == 8 || Basis == 10  || Basis == 12 
    BaseYear=365;
elseif Basis == 13
    BaseYear=252;
end

Yield = SwapRate/100;                   % Yield
CouponRate = Yield;                     % by assumption
Settle = datestr(TSDatenum);            % convert date to date string
MaturityDouble = TSDatenum + repmat(Tenor*BaseYear,length(TSDatenum),1); 
Maturity = datestr(MaturityDouble);     % convert date to date string 

for i=1:length(SwapRate)
    CouponRate_snap = CouponRate(i);
    duration(i) = bnddury(Yield(i), CouponRate(i), Settle(i,:), Maturity(i,:), Period, Basis);
end
   
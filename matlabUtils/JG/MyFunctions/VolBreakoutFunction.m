function[CleanSignal,MaCleanSignal] = VolBreakoutFunction(x,NbStd,MinLookbackPeriod,MaxLookbackPeriod,PeriodSmooth)

%__________________________________________________________________________
%
% This function computes a vilatilityh breakout indicator over severeal
% days
% INPUT....................................................................
% X                   = price
% MinLookbackPeriod   = Minimum period for moving average.
% MaxLookbackPeriod   = Maximum period for moving average.
% OUTPUT...................................................................
%
% Gross MACD = macdg = Fast Ex. Mov. Avg. - Slow Ex. Mov. Avg.
% 
% Signal MACD = macds = expmov(macdg,PeriodSignal);
%__________________________________________________________________________

% Identify Dimensions------------------------------------------------------
[nsteps,ncols]=size(x);
CleanSignal=zeros(size(x));

% Compute Daily Difference
xdif = RateofChange(x,'difference',1);
% Compute Volatility
xdiffvol=VolatilityFunction(xdif,'simple volatility',100,10,10e10);
% Dimension of Prelocate Row Matrix of Gross Breakout
DimRMGB=MaxLookbackPeriod-MinLookbackPeriod;

for j=1:ncols
    for i=MaxLookbackPeriod+1:nsteps
        % Prelocate Row Matrix of Gross Breakout
        RowMatrixGrossBreakout=zeros(1,MaxLookbackPeriod);%note: simple like this      
        Myx=x(i,j); MyStd=xdiffvol(i,j);
        % Extract Gross Signal
        for u=MinLookbackPeriod:MaxLookbackPeriod 
            if Myx >= x(i-u,j)     + NbStd * power(u,0.5) * MyStd
                RowMatrixGrossBreakout(1,u)=1;
            elseif Myx <= x(i-u,j) - NbStd * power(u,0.5) * MyStd
                RowMatrixGrossBreakout(1,u)=-1;
            end
        end
        % Clean Signal
        for u=MinLookbackPeriod:MaxLookbackPeriod 
            MySignal=RowMatrixGrossBreakout(1,u);
            for q=u+1:MaxLookbackPeriod 
                if MySignal==1 && RowMatrixGrossBreakout(1,u)==-1
                    MySignal=-1;
                elseif MySignal==-1 && RowMatrixGrossBreakout(1,u)==1
                    MySignal=1;
                end
            end
            RowMatrixGrossBreakout(1,u)=MySignal;
        end
        % Assign to row 'i'
        CleanSignal(i,j)=sum(RowMatrixGrossBreakout(1,:));
    end
end
MaCleanSignal=expmav(CleanSignal,PeriodSmooth);


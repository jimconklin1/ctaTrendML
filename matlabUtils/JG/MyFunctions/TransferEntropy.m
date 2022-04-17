function [P1 P2 P3 P4 P5 P6 P7] = TransferEntropy(x,LookbackPeriod, ForecastPeriod)
%
%__________________________________________________________________________
%
% The variable can take two States S1 and S2
% The code compute the transfer entropy between two variables X and Y or 
% between a variable X d-lagged and itself
% 
% For the ease of notation we note X0, the variable now, and Xl the
% variable lagged
%
% Step 1: Compute p(x(n+1),x(n),y(n))
%
% P_S1X0_S1Xl_S1Yl  
% P_S1X0_S1Xl_S2Yl
% P_S1X0_S2Xl_S1Yl
% P_S1X0_S2Xl_S2Yl

% P_S2X0_S1Xl_S1Yl
% P_S2X0_S1Xl_S2Yl
% P_S2X0_S2Xl_S1Yl
% P_S2X0_S2Xl_S2Yl
%
% Step 2: Compute p(x(n+1),x(n))
%
% P_S1X0_S1Xl
% P_S1X0_S2Xl
% P_S2X0_S1Xl
% P_S2X0_S2Xl
%
% P_S1Xl_S1Xl
% P_S1Xl_S2Xl
% P_S2Xl_S1Xl
% P_S2Xl_S2Xl
%
% Step 3: Compute p(x(n)
%
% P_S1X0
% P_S2X0
%
%__________________________________________________________________________
%
%
[nsteps,ncols]=size(x);
%Prelocate Matrices
P1=zeros(nsteps,ncols);
P2=zeros(nsteps,ncols);
P3=zeros(nsteps,ncols);
P4=zeros(nsteps,ncols);
P5=zeros(nsteps,ncols);
P6=zeros(nsteps,ncols);
P7=zeros(nsteps,ncols);

if ncols>1
    
    %if x(i-ForecastPeriod+1
    
elseif ncols==1
    
    for i=LookbackPeriod+ForecastPeriod+1:nsteps
        % Extract Vector
        xv_now=x(i-LookbackPeriod+1:i,1);
        xv_lag=x(i-LookbackPeriod-ForecastPeriod+1:i-ForecastPeriod,1);
        % Number of observation
            % Step 1
            Nobs2=LookbackPeriod-1;
            % Step 2 & Step 3
            Nobs1_3=LookbackPeriod;
        % Prelocate variable
        P_S1X0_S1Xl_S1Yl  = 0;
        P_S1X0_S1Xl_S2Yl  = 0;
        P_S1X0_S2Xl_S1Yl  = 0;
        P_S1X0_S2Xl_S2Yl  = 0;
        P_S2X0_S1Xl_S1Yl  = 0;
        P_S2X0_S1Xl_S2Yl  = 0;
        P_S2X0_S2Xl_S1Yl  = 0;
        P_S2X0_S2Xl_S2Yl  = 0;
        P_S1X0_S1Xl  = 0;
        P_S1X0_S2Xl  = 0;
        P_S2X0_S1Xl  = 0;
        P_S2X0_S2Xl  = 0;
        P_S1Xl_S1Xl  = 0;
        P_S1Xl_S2Xl  = 0;
        P_S2Xl_S1Xl  = 0;
        P_S2Xl_S2Xl  = 0;  
        P_S1X0  = 0;  
        P_S2X0  = 0;  
            
        for u=1:length(xv)-ForecastPeriod
            % Past Condition
            if xv(u-ForecastPeriod+1,1)<S1In 
                P1v=P1v+1;
            else
                P2v=P2v+1;
            end
            % Present Consequence
            if x(u,1)>S1Out
                P3v=P3v+1;
            else
                P4v=P4v+1;
            end  

            if x(u-ForecastPeriod+1,1)<S1In && x(u,1)>S1Out
                P5v=P5v+1;
            end 
            if x(u-ForecastPeriod+1,1)<S1In && x(u,1)<=S1Out
                P6v=P6v+1;
            end 

            if x(u-ForecastPeriod+1,1)>=S1In && x(u,1)>S1Out
                P7v=P7v+1;
            end 
            if x(u-ForecastPeriod+1,1)>=S1In && x(u,1)<S1Out
                P8v=P8v+1;
            end 
        end
        % Assigne
        P1(i,1)=P1v/ForecastPeriod;
        P2(i,1)=P2v/ForecastPeriod;
        P3(i,1)=P3v/ForecastPeriod;
        P4(i,1)=P4v/ForecastPeriod;
        P5(i,1)=P5v/ForecastPeriod;
        P6(i,1)=P6v/ForecastPeriod;
        P7(i,1)=P7v/ForecastPeriod;
    end
    
end
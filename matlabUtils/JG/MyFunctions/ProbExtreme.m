function[pxt,pxtma] = ProbExtreme(x,method,inputx)
%
%__________________________________________________________________________
%
% This function computes the percentage of times the price exceeds the
% channel
% INPUT....................................................................
% X                   = price
% maperiod = Period for moving average.
% vol      = vol (as a %) for the channel.
% smooth   = Period for smoothing the probabability.
% OUTPUT...................................................................
% pxt   = probability.
% pxtma = smoothed probability.
%__________________________________________________________________________
%
% -- Identify Dimensions --
[nsteps,ncols]=size(x);
pxt=zeros(size(x));
%
% -- different solution --
switch method
    
    case 'solution1'

        % -- Input variables
        %inputx=zeros(1,3);    
        maperiod=inputx(1,1); vol=inputx(1,2);smooth=inputx(1,3);
        % -- Compute moving average & Channels --
        ma=expmav(x,maperiod);  chup=(1+vol/200)*ma;  chdn=(1-vol/200)*ma;
        % -- Set Up Input Matrix for Slope --
        for j=1:ncols
            % Find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end            
            % Extract Columns
            Diff_chup=x(:,j)-chup(:,j);               Diff_chdn=x(:,j)-chdn(:,j);
            CountUp=zeros(nsteps,1);  CountDn=zeros(nsteps,1);
            % Compute Distance to Channel Lower & Upper Bounds
            for i=start_date:nsteps
                if Diff_chup(i)>0, CountUp(i)=1;  end
                if Diff_chdn(i)<0, CountDn(i)=1;  end            
            end
            SumDiff=CountUp+CountDn;
            clear Diff_chup    Diff_chdn    CountUp   CountDn
            CumSumDiff=zeros(nsteps,1); ProbDiff=zeros(nsteps,1);
            % Compute Probability
            for i=start_date+1:nsteps
                CumSumDiff(i)=CumSumDiff(i-1)+SumDiff(i);
            end
            clear SumDiff
            length_a=nsteps-start_date+1; count_a=(1:1:length_a)';
            ProbDiff(start_date:nsteps,1)=100*(CumSumDiff(start_date:nsteps,1)./count_a);
        end
        % Assign
        pxt(:,j)=ProbDiff(:,1);
        clear ProbDiff    
        %  -- Smooth Probability --
        pxtma=expmav(pxt,smooth);    
        
    case 'solution2'
            
        % -- Input variables
        %inputx=zeros(1,3);    
        maperiod=inputx(1,1); vol=inputx(1,2);smooth=inputx(1,3);
        % -- Compute moving average & Channels --
        ma=expmav(x,maperiod);  chup=(1+vol/200)*ma;  chdn=(1-vol/200)*ma;        
        % -- Set Up Input Matrix for Slope --
        for j=1:ncols
            % Find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end                 
            % Extract Columns
            Diff_chup=x(:,j)-chup(:,j);               Diff_chdn=x(:,j)-chdn(:,j);
            CountUp=zeros(nsteps,1);  CountDn=zeros(nsteps,1);
            % Compute Distance to Channel Lower & Upper Bounds
            for i=start_date:nsteps
                if Diff_chup(i)>0, CountUp(i)=1;  end
                if Diff_chdn(i)<0, CountDn(i)=1;  end            
            end
            SumDiff=CountUp+CountDn;
            clear Diff_chup    Diff_chdn    CountUp   CountDn
            ProbDiff=zeros(nsteps,1);
            % Compute Probability
            PeriodCount=2*220;
            for i=start_date+PeriodCount+1:nsteps
                ProbDiff(i)=100*sum(SumDiff(i-PeriodCount+1:i))/PeriodCount;
            end     
        end
        % Assign
        pxt(:,j)=ProbDiff(:,1);
        clear ProbDiff    
        %  -- Smooth Probability --
        pxtma=expmav(pxt,smooth);    
        
    case 'solution3'
            
        % -- Input variables
        %inputx=zeros(1,3);    
        maperiod=inputx(1,1); vol=inputx(1,2);smooth=inputx(1,3);
        % -- Compute moving average & Channels --
        ma=expmav(x,maperiod);  chup=(1+vol/200)*ma;  chdn=(1-vol/200)*ma;        
        % -- Set Up Input Matrix for Slope --
        for j=1:ncols
            % Find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end               
            % Prelocate
            SumDiff=zeros(nsteps,1);   CumSumDiff=zeros(nsteps,1); ProbDiff=zeros(nsteps,1);
            % Compute
            for i=start_date+1:nsteps
               if (x(i-1,j)>chup(i-1,j) && x(i,j)<chup(i,j)) || ...
                   (x(i-1,j)<chdn(i-1,j) && x(i,j)>chdn(i,j))    
                    SumDiff(i)=1;
                    CumSumDiff(i)=CumSumDiff(i-1)+SumDiff(i);
               end
            end
            length_a=nsteps-start_date+1; count_a=(1:1:length_a)';
            ProbDiff(start_date:nsteps,1)=100*(CumSumDiff(start_date:nsteps,1)./count_a);   
        end
        % Assign
        pxt(:,j)=ProbDiff(:,1);
        clear ProbDiff    
        %  -- Smooth Probability --
        pxtma=expmav(pxt,smooth);    
        
    case 'solution4'
            
        % -- Input variables
        %inputx=zeros(1,3);    
        maperiod=inputx(1,1); vol=inputx(1,2);smooth=inputx(1,3);
        % -- Compute moving average & Channels --
        ma=expmav(x,maperiod);  chup=(1+vol/200)*ma;  chdn=(1-vol/200)*ma;        
        % -- Set Up Input Matrix for Slope --
        for j=1:ncols
            % Find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end               
            % Prelocate
            SumDiff=zeros(nsteps,1);   ProbDiff=zeros(nsteps,1);
            % Compute
            for i=start_date+1:nsteps
               if (x(i-1,j)>chup(i-1,j) && x(i,j)<chup(i,j)) || ...
                   (x(i-1,j)<chdn(i-1,j) && x(i,j)>chdn(i,j))    
                    SumDiff(i)=1;
               end
            end
            % Compute Probability
            PeriodCount=2*220;
            for i=start_date+PeriodCount+1:nsteps
                ProbDiff(i)=100*sum(SumDiff(i-PeriodCount+1:i))/PeriodCount;
            end       
        end
        % Assign
        pxt(:,j)=ProbDiff(:,1);
        clear ProbDiff    
        %  -- Smooth Probability --
        pxtma=expmav(pxt,smooth);    
        
    case 'solution5'
            
        % -- Input variables
        %inputx=zeros(1,3);    
        maperiod=inputx(1,1); PeriodCount=inputx(1,2); smooth=inputx(1,3);
        % -- Compute moving average & Channels --
        ma=expmav(x,maperiod);          
        % -- Set Up Input Matrix for Slope --
        for j=1:ncols
            % Find the first cell to start the code
            for i=1:nsteps
                if ~isnan(x(i,j)), start_date=i;
                break
                end
            end              
            % Prelocate
            SumDiff=zeros(nsteps,1);   ProbDiff=zeros(nsteps,1);
            % Compute
            for i=start_date+1:nsteps
               if (x(i-1,j)>ma(i-1,j) && x(i,j)<ma(i,j)) || ...
                   (x(i-1,j)<ma(i-1,j) && x(i,j)>ma(i,j))    
                    SumDiff(i)=1;
               end
            end
            % Compute Probability
            for i=start_date+PeriodCount+1:nsteps
                ProbDiff(i)=100*sum(SumDiff(i-PeriodCount+1:i))/PeriodCount;
            end   
        end
        % Assign
        pxt(:,j)=ProbDiff(:,1);
        clear ProbDiff    
        %  -- Smooth Probability --
        pxtma=expmav(pxt,smooth);           
 
end

%
% -- Plot
PlotOption=0;
if PlotOption==1
    xtime=1:1:length(x);
    subplot(2,1,1);plotyy(xtime,x,xtime,pxt);
    subplot(2,1,2);plotyy(xtime,x,xtime,pxtma);
end
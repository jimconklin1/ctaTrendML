function[PRevUp, PRevDown, PRevTot] = ProbReversionFunction(X,EqLine,RevPeriod)
%
%__________________________________________________________________________
%The function computes the Probability of reversion after Period day when a
%given variable has been higher / lower than the median
%
% The probability is computed from the start
% Input
% X = Asset
% EqLine = its median or moving average
% RevPeriod = Period after whch we expect a reversion
%__________________________________________________________________________
%
%
%Prelocate matrices
[nbsteps,nbcols] = size(X); 
PRevUp=zeros(size(X));      CountRevUp=zeros(size(X));
PRevDown=zeros(size(X));    CountRevDown=zeros(size(X));
PRevTot=zeros(size(X));     CountRevTot=zeros(size(X));

TimeVector=(1:1:nbsteps)';
CleanPeriod=round(nbsteps/5);

for j=1:nbcols
    % Step 1.: find the first cell to start the code
    start_date=zeros(1,1);
    for i=1:nbsteps
        if ~isnan(X(i,j)) && X(i,j)~=0 && EqLine(i,j)~=0 &&  ~isnan(EqLine(i,j))
            start_date(1,1)=i;
        break
        end
    end
    %
    % Step 2.: Count Reversion
    for i=start_date(1,1)+RevPeriod+1:nbsteps
        % Step 2.1.: Compute Probability of Upward Reversal After a
        % Downward Movement  
        if X(i-RevPeriod,j)<EqLine(i-RevPeriod,j) && X(i,j)>X(i-RevPeriod,j)
            CountRevUp(i,j)=CountRevUp(i-1,j)+1;
        else
            CountRevUp(i,j)=CountRevUp(i-1,j);
        end
        % Step 2.2.: Compute Probability of Downwars Reversal After a
        % Upward Movement            
        if X(i-RevPeriod,j)>EqLine(i-RevPeriod,j) && X(i,j)<X(i-RevPeriod,j)
            CountRevDown(i,j)=CountRevDown(i-1,j)+1;
        else
            CountRevDown(i,j)=CountRevDown(i-1,j);
        end   
        % Step 2.3.: Compute Probability of Downwars Reversal After a
        % Upward Movement            
        if (X(i-RevPeriod,j)<EqLine(i-RevPeriod,j) && X(i,j)>X(i-RevPeriod,j)) || ...
           (X(i-RevPeriod,j)>EqLine(i-RevPeriod,j) && X(i,j)<X(i-RevPeriod,j))
            CountRevTot(i,j)=CountRevTot(i-1,j)+1;
        else
            CountRevTot(i,j)=CountRevTot(i-1,j);
        end                
    end
    %
    % Compute Probability
    PRevUp(:,j) = CountRevUp(:,j) ./ TimeVector;
    PRevDown(:,j) = CountRevDown(:,j) ./ TimeVector;
    PRevTot(:,j) = CountRevTot(:,j) ./ TimeVector;   
    % Clean firt prob
    CleanZone=zeros(CleanPeriod,1);
    PRevUp(1:CleanPeriod,j)=CleanZone;
    PRevDown(1:CleanPeriod,j)=CleanZone;
    PRevTot(1:CleanPeriod,j)=CleanZone;
end    
    clear TimeVector

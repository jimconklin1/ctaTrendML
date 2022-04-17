function [bo, meanRetLong, meanRetShort] =  BreakoutFinder(c, method, lagPeriods, returnAnalysisPeriod)

%__________________________________________________________________________
%
% This function computes the Min & the Max over a given period then
% computes the distance form the current observed to this Min and Max. 
%
% INPUT
%
% c                   = a matrix of closed price (time-bars x observation)
% lagPeriod           = a structure (1 x n) of time lags
% method:             the user has two methods
% - {'and', 'And', 'andMethod', 'AndMethod'}: all breakout MUST have the
%    same direction
% case {'sum', 'Sum', 'sumMethod', 'SumMethod'}: the sum of all breakout
% note: the 'or' method does not have much sense, save as a majoity vote
% rule, which is essentially the sign of the 'sum' method.
% indeed assume 4 breakouts sending the following signals: +1, -1, -1,+1
% 'or' methods will send a flat signal.
% If we have 3 signals: +1, -1, -1, which one prevails? the +1, or the -1.
% Here, the most sensible rule is to use a 'majority vote', hence,
% sign(sum).
%
% OUTPUT
% bo = matrix of breakout
% meanRetLong = average return for Long
% meanRetShort = average return for Short
%
%__________________________________________________________________________

% Identify Dimensions------------------------------------------------------
[nsteps,ncols]=size(c);
bo = nan(size(c));

nbLagPeriods = size(lagPeriods,2);

if nargin == 4
    nbRetPeriods = size(returnAnalysisPeriod,2);
    meanRetLong = nan(ncols, nbRetPeriods);    
    meanRetShort = nan(ncols, nbRetPeriods);
end

% Min & Max time series----------------------------------------------------
for j=1:ncols
    
    cSnap = c(:,j); % snap
    %tsStart = StartFinder(cSnap, 'znan'); % find the first cell to start the code
        
    % Compute a matrix of lag
    cSnapLag = ShiftBwd(cSnap,lagPeriods(1,1), 'z');
    if nbLagPeriods > 1
        for u=2:nbLagPeriods 
            cSnapLag = [cSnapLag , ShiftBwd(cSnap,lagPeriods(1,u), 'NaN')];
        end
    end
    
    % Compute difference
    diffLagcSnap = repmat(cSnap,1,nbLagPeriods) - cSnapLag;
    
    % Now Compute the signal for the breakout
    switch method
        case {'and', 'And', 'andMethod', 'AndMethod'}
                for i=1:nsteps
                    if diffLagcSnap(i,:) > 0 
                        bo(i,j) = 1;
                    elseif diffLagcSnap(i,:) < 0 
                        bo(i,j) = -1;
                    end
                end              
        case {'sum', 'Sum', 'sumMethod', 'SumMethod'}
            bo(:,j) = sum(diffLagcSnap,2);
        case {'or', 'Or', 'orMethod', 'OrMethod'}  
            bo(:,j) = sign(sum(diffLagcSnap,2));
    end
    
    % -- Return analysis --
    if nargin == 4
        ySnap = bo(:,j);
        xSnapLag = ShiftBwd(cSnap,returnAnalysisPeriod(1,1), 'NaN');
        ySnapLag = ShiftBwd(ySnap,returnAnalysisPeriod(1,1), 'NaN');
        if nbRetPeriods > 1
            for u=2:nbRetPeriods
                xSnapLag = [xSnapLag , ShiftBwd(cSnap,returnAnalysisPeriod(1,u), 'NaN')];
                ySnapLag = [ySnapLag , ShiftBwd(ySnap,returnAnalysisPeriod(1,u), 'NaN')];
                ySnapLagLong = ySnapLag; ySnapLagLong(ySnapLagLong == -1) = NaN;
                ySnapLagShort = ySnapLag; ySnapLagShort(ySnapLagShort == 1) = NaN;
                
            end
        end        
        zSnapLong = sign(ySnapLagLong) .* (repmat(cSnap,1,nbRetPeriods) ./ xSnapLag - ones(nsteps,nbRetPeriods));
        zSnapShort = sign(ySnapLagShort) .* (repmat(cSnap,1,nbRetPeriods) ./ xSnapLag - ones(nsteps,nbRetPeriods));
        zSnapmeanLong = nanmean(zSnapLong,1);
        zSnapmeanShort = nanmean(zSnapShort,1);
        meanRetLong(j,:) = zSnapmeanLong;
        meanRetShort(j,:) = zSnapmeanShort;
    end

end
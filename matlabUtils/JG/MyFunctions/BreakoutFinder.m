function [boLong, boShort,  meanRetLong, meanRetShort] =  BreakoutFinder(c, method, lagPeriods, memPeriod, returnAnalysisPeriod)

%__________________________________________________________________________
%
% INPUT
%
% c                   = a matrix of closed price (time-bars x observation)
% lagPeriod           = a structure (1 x n) of time lags
% method:             the user has two methods
% memPeriod is the memory period (usually 1 day)
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
% boLong = matrix of Long breakout
% boShort= matrix of Short breakout
% meanRetLong = average return for Long breakouts
% meanRetShort = average return for Short breakouts
%
%__________________________________________________________________________

% -- Identify Dimensions & Prelocate matrices --
[nsteps,ncols]=size(c);
nbLagPeriods = size(lagPeriods,2);
boLong = nan(size(c));
boShort = nan(size(c));
if nargin == 5
    nbRetPeriods = size(returnAnalysisPeriod,2);
    meanRetLong = nan(ncols, nbRetPeriods);    
    meanRetShort = nan(ncols, nbRetPeriods);
end

% -- Find breakouts --
for j=1:ncols
    
    cSnap = c(:,j); % snap
    %tsStart = StartFinder(cSnap, 'znan'); % find the first cell to start the code

    MinTs = nan(nsteps,nbLagPeriods); % pre locate matrix for maxima
    MaxTs = nan(nsteps,nbLagPeriods); % pre locate matrix for minima
       
    for u=1:nbLagPeriods 
        myLagPeriod = lagPeriods(1,u);
        for i = myLagPeriod + memPeriod + 1 : nsteps
            MinTs(i,u)=min(cSnap(i-myLagPeriod+1-memPeriod:i-memPeriod));
            MaxTs(i,u)=max(cSnap(i-myLagPeriod+1-memPeriod:i-memPeriod));
        end
    end
    
    % Compute difference
    diffLagcSnapLong = repmat(cSnap,1,nbLagPeriods) - MaxTs;
    diffLagcSnapShort = repmat(cSnap,1,nbLagPeriods) - MinTs;
    
    % Now Compute the signal for the breakout
    switch method
        case {'and', 'And', 'andMethod', 'AndMethod'}
                for i=1:nsteps
                    if diffLagcSnapLong (i,:) > 0 
                        boLong(i,j) = 1;
                    elseif diffLagcSnapShort(i,:) < 0 
                        boShort(i,j) = -1;
                    end
                end              
        case {'sum', 'Sum', 'sumMethod', 'SumMethod'}
            boLong(:,j) = sum(diffLagcSnapLong,2);
            boShort(:,j) = sum(diffLagcSnapShort,2);
        case {'or', 'Or', 'orMethod', 'OrMethod'}  
            boLong(:,j) =  sign(sum(diffLagcSnapLong,2));
            boShort(:,j) = sign(sum(diffLagcSnapShort,2));
    end
    
    % -- Return analysis --
    if nargin == 5
        boSnapLong = boLong(:,j);    % snap long breakouts
        boSnapShort = boShort(:,j);  % snap shortbreakouts
        % Initialise ...
        xSnapLagMat = ShiftBwd(cSnap,returnAnalysisPeriod(1,1), 'NaN');
        boSnapLongLagMat = ShiftBwd(boSnapLong,  returnAnalysisPeriod(1,1), 'NaN');
        boSnapShortLagMat = ShiftBwd(boSnapShort,returnAnalysisPeriod(1,1), 'NaN');
        % ...and if many periods for returns, concatenate
        if nbRetPeriods > 1
            for u=2:nbRetPeriods
                xSnapLagMat = [xSnapLagMat , ShiftBwd(cSnap,returnAnalysisPeriod(1,u), 'NaN')];
                boSnapLongLagMat =  [boSnapLongLagMat ,   ShiftBwd(boSnapLong,returnAnalysisPeriod(1,u), 'NaN')];
                boSnapShortLagMat = [boSnapShortLagMat , ShiftBwd(boSnapShort,returnAnalysisPeriod(1,u), 'NaN')];
            end
        end    
        % Compute returns {BO[n-days ago] * (Price/Price[n-days ago]-1)}
        zSnapLong = sign(boSnapLongLagMat)   .* (repmat(cSnap,1,nbRetPeriods) ./ xSnapLagMat - ones(nsteps,nbRetPeriods));
        zSnapShort = sign(boSnapShortLagMat) .* (repmat(cSnap,1,nbRetPeriods) ./ xSnapLagMat - ones(nsteps,nbRetPeriods));
        % Average out returns
        zSnapmeanLong = nanmean(zSnapLong,1);
        zSnapmeanShort = nanmean(zSnapShort,1);
        % Assign result
        meanRetLong(j,:) = zSnapmeanLong;
        meanRetShort(j,:) = zSnapmeanShort;
        
    end

end
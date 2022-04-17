function [macsSign, macs, macsSignSumVal, corretClass]  = creepIndex(x, model, movAvgType, Lookback, deltaLag, SignalStrength, lagPeriod, volPeriod, corrPeriod)
%
%__________________________________________________________________________
%
% This function computes the Moving Average Confluence indicator based on
% two methodologies:
% - first derivative of a set of moving averages
% - sum of crossses
% INPUT....................................................................
% X                   = price
% 'method'            = 'arithmetic' or 'exponential' moving averages
%                       element in the data base.
% FastLookback        = row vetor of periods for fast moving average.
% SlowLookback        = row vetor of periods for slow moving average.
% SignalStrength      = variance risk ratio to weight direction by trend
%                      strength
% OUTPUT...................................................................
% macs = moving average confluence.
% mamacs = smoothed moving average confluence.
% Paramter based on Fibonacci
%FastLookback = [1, 1, 1,  2, 2,  3,  3,  3,  3,  5,  5,  5,  8,  8,  13, 13,  13,  21, 21,  21];
%SlowLookback = [5, 8, 13, 8, 13, 13, 21, 34, 55, 21, 34, 55, 34, 55, 55, 89,  144, 89, 144, 233];  
%FastLookback = [1,  2,  3,  3,  3,  5,  5,  5,  8,  8,  13, 13,  13,  21, 21,  21];
%SlowLookback = [13, 13, 13, 21, 34, 21, 34, 55, 34, 55, 55, 89,  144, 89, 144, 233]; 
% macs = MACSFunction(x, 'exp', FastLookback, SlowLookback)
%__________________________________________________________________________
%
% Identify Dimensions------------------------------------------------------
[nsteps,ncols] = size(x);
macs = zeros(size(x));            % macs = sum of sign(difference)
macsSign = zeros(size(x));        % macsSign = sign(macs)
macsSumVal = zeros(size(x));      % Sum of value of differences
macsSignSumVal = zeros(size(x));  % Sign of sum of value of differences
L = size(Lookback,2); 
diffCube = zeros(nsteps, ncols, L); 
%
% -- Create cube for signal based on moving averages --
if strcmp(model, 'mavDelta') || strcmp(model, 'MovAvgDelta') || strcmp(model, 'mavDynamics')  || strcmp(model, 'mavDiff')  || strcmp(model, 'MovAvgDynamics') ...
         || strcmp(model, 'mavD') ||   strcmp(model, 'MovAvD') || strcmp(model, 'mad') 
    for u=1:L
        if strcmp(movAvgType,'exponential') || strcmp(movAvgType,'exp') || strcmp(movAvgType,'ema')
                maf = expmav(x,Lookback(1,u)); % moving average
        elseif strcmp(movAvgType,'arithmetic') || strcmp(movAvgType,'arith') || strcmp(movAvgType,'ama')            
                maf = arithmav(x,Lookback(1,u)); % moving average  
        elseif strcmp(movAvgType,'triangularmav') || strcmp(movAvgType,'Triang') || strcmp(movAvgType,'triang') || strcmp(movAvgType,'tri')             
                maf = triangularmav(x,Lookback(1,u)); % moving average   
        elseif strcmp(movAvgType,'kama')            
                maf = TrendSmoother(x,'kama', [10, 2, Lookback(1,u)]);% moving average  
        end
        maf2mas = Delta(maf,'d',deltaLag); 
        diffCube(:,:,u) = maf2mas / Lookback(1,u)^0.5;   % Assign to cube "Observations x Assets x Indicators"
    end
elseif strcmp(model, 'MovAvgCross') || strcmp(model, 'mavCross') || strcmp(model, 'mac') 
    for u=1:L
        % Fast moving average (1st row)
        if strcmp(movAvgType,'exp2exp') || strcmp(movAvgType,'expvexp') || strcmp(movAvgType,'ema2ema') || strcmp(movAvgType,'emavema')
                maf = expmav(x,Lookback(1,u)); % Fast moving average
                mas = expmav(x,Lookback(2,u)); % Slow moving average
        elseif strcmp(movAvgType,'arith2arith') || strcmp(movAvgType,'arithvarith') || strcmp(movAvgType,'ama2ama') || strcmp(movAvgType,'amavama')          
                maf = arithmav(x,Lookback(1,u)); % Fast moving average
                mas = arithmav(x,Lookback(2,u)); % Slow moving average 
        elseif strcmp(movAvgType,'tri2tri') || strcmp(movAvgType,'trivtri') || strcmp(movAvgType,'triang2triang') || strcmp(movAvgType,'triangvtriang')             
                maf = triangularmav(x,Lookback(1,u)); % Fast moving average    
                mas = triangularmav(x,Lookback(2,u)); % Slow moving average 
        elseif strcmp(movAvgType,'exp2tri') || strcmp(movAvgType,'ema2tri') || strcmp(movAvgType,'expvtri') ||  strcmp(movAvgType,'emavtri') || strcmp(movAvgType,'exp2triang') || strcmp(movAvgType,'expvtriang')             
                maf = expmav(x,Lookback(1,u)); % Fast moving average    
                mas = triangularmav(x,Lookback(2,u)); % Slow moving average                 
        end
        maf2mas = maf-mas; 
        diffCube(:,:,u) = maf2mas / (Lookback(2,u)-Lookback(1,u))^0.5;   % Assign to cube "Observations x Assets x Indicators"
    end    
end

% -- Compute signal strength if needed --
if strcmp(SignalStrength,'VRR') || strcmp(SignalStrength,'vrr') || strcmp(SignalStrength,'vrrWeight')
    %vrrLookback = [5, 8, 13, 21, 34, 55, 89];
    vrrLookback = [8, 13, 21, 34, 55, 55, 55];
    V = length(vrrLookback);
    vrrCube = zeros(nsteps, ncols, V);
    for u=1:V
        vrrU = RollingVRTest(log(x),vrrLookback(u), 'het'); % lookback for cube
        vrrU(vrrU==Inf)=0; vrrU(vrrU==-Inf)=0; vrrU(isnan(vrrU))=0;
        vrrCube(:,:,u) = vrrU;   % Assign to cube "Observations x Assets x Incidators"
        vrrCubeJunk = vrrCube;
    end   
    % reshape vrrCube
    vrrCube = zeros(size(diffCube));
    for u=1:5 % vrrLookback = 5;
        vrrCube(:,:,u) = vrrCubeJunk(:,:,1);
    end
    for u=6:7 % vrrLookback = 8
        vrrCube(:,:,u) = vrrCubeJunk(:,:,2);
    end  
    for u=8:9 % vrrLookback = 13;
        vrrCube(:,:,u) = vrrCubeJunk(:,:,3);
    end    
    for u=10:11 % vrrLookback = 21;
        vrrCube(:,:,u) = vrrCubeJunk(:,:,4);
    end     
    for u=12:15 % vrrLookback = 34;
        vrrCube(:,:,u) = vrrCubeJunk(:,:,5);
    end       
    for u=16:18 % vrrLookback = 55;
        vrrCube(:,:,u) = vrrCubeJunk(:,:,6);
    end     
    for u=19:20 % vrrLookback = 89;
        vrrCube(:,:,u) = vrrCubeJunk(:,:,7);
    end     
    % Now compute indicator by Asset
    for j=1:ncols
        % Build matrix of indicators for Asset j
        jSlice = zeros(nsteps,1);
        jvrrSlice = zeros(nsteps,1);
        for u=1:length(FastLookback)
            jSlice = [jSlice , diffCube(:,j,u)];
            jvrrSlice = [jvrrSlice , vrrCube(:,j,u)];
        end
        jSlice(:,1)=[]; jvrrSlice(:,1)=[];
        jSliceWgt = jSlice .* jvrrSlice;
        jSignSum = (sum(jSliceWgt, 2)); % sum of signals
        macs(:,j) = jSignSum; % Assign to final output
    end    

elseif strcmp(SignalStrength,'no') || strcmp(SignalStrength,'simple') 
    for j=1:ncols
        % Extract asset j
        jSlice = squeeze(diffCube(:,j,:));
        % Sign of Sum of the value
        jSliceSumVal = (sum(jSlice, 2));
        macsSumVal(:,j) = jSliceSumVal;         % Sum of value of differences
        jSliceSignSumVal = sign(jSliceSumVal);
        macsSignSumVal(:,j) = jSliceSignSumVal; % Sign of sum of value of differences
        % Sign of Sum of Sign of value
        jSliceSign = sign(jSlice);              % 
        jSliceSumSign = (sum(jSliceSign, 2));   % sum of signals
        macs(:,j) = jSliceSumSign;              % macs = sum of sign(difference)
        macsSign(:,j) = sign(jSliceSumSign);    % macsSign = sign(macs)
    end 

elseif strcmp(SignalStrength,'Ic') || strcmp(SignalStrength,'ic') 
    for j=1:ncols
        % Extract asset j
        jSlice = squeeze(diffCube(:,j,:));
        % Sign of Sum of the value
        jSliceSumVal = (sum(jSlice, 2));
        macsSumVal(:,j) = jSliceSumVal;         % Sum of value of differences        
        jSliceSignSumVal = sign(jSliceSumVal);
        macsSignSumVal(:,j) = jSliceSignSumVal; % Sign of sum of value of differences
        % Sign of Sum of Sign of value
        jSliceSign = sign(jSlice);              % 
        jSliceSumSign = (sum(jSliceSign, 2));   % sum of signals
        macs(:,j) = jSliceSumSign;              % macs = sum of sign(difference)
        macsSign(:,j) = sign(jSliceSumSign);    % macsSign = sign(macs)
    end 
    % compute delta
    retClass = zeros(size(x));
    corretClass = zeros(size(x));
    nbLags = size(lagPeriod,2); 
    for j=1:ncols
        xSnap = x(:,j);
        xSnapRetSpectrum = zeros(nsteps,nbLags);
        for u=1:nbLags
            xSnapRetSpectrum(:,u) = Delta(xSnap,'roc',u) / u ^0.5;
        end
        volr1dx = VolatilityFunction(xSnapRetSpectrum(:,1),'std', volPeriod, 20, 10e10);
        xTemp = xSnapRetSpectrum ./ repmat(volr1dx, 1, nbLags);
        sXtemp = sum(xTemp,2);
        %retClassTemp = binaryClass(sXtemp, 0, 0);
        retClassTemp = sXtemp;
        retClass(:,j) = retClassTemp;
        method = 1;
        if method == 1
            corrtemp = cor2v(macs(:,j), retClassTemp, max(lagPeriod),0,corrPeriod,'pearson');
        elseif method == 2
            corrtemp = cor2v(macsSumVal(:,j), retClassTemp, max(lagPeriod),0,corrPeriod,'pearson');
        end
        corretClass(:,j)=corrtemp;
    end
    % Clean corr
    for j=1:ncols
        for i=25:nsteps
            if isnan(corretClass(i,j)),
                 corretClass(i,j) = mean(corretClass(i-21:i-1,j));
            end
        end
    end
end


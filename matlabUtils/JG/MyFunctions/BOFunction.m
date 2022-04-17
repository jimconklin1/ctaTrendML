function macs = BOFunction(x, FastLookback, SlowLookback, SignalStrength)
%
%__________________________________________________________________________
%
% This function computes the Moving Average Confluence indicator.
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
macs = zeros(size(x));
L = length(FastLookback);
diffCube = zeros(nsteps, ncols, L);
%
% -- Create cube for signal based on moving averages --
for u=1:L

    maf = Delta(x,'d',FastLookback(u)); % Fast moving average
    mas = Delta(x,'d',SlowLookback(u)); % Fast moving average

    maf2masSign = sign(maf-mas);     % Sign of differences
    clear maf mas
    diffCube(:,:,u) = maf2masSign;   % Assign to cube "Observations x Assets x Incidators"
end

% -- Compute signal strength if needed --
if strcmp(SignalStrength,'VRR') || strcmp(SignalStrength,'vrr') || strcmp(SignalStrength,'vrrWeight')
    vrrLookback = [5, 8, 13, 21, 34, 55, 89];
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

    % Now compute indicator by Asset
    for j=1:ncols
        % Build matrix of indicators for Asset j
        jSlice = zeros(nsteps,1);
        for u=1:length(FastLookback)
            jSlice = [jSlice , diffCube(:,j,u)];
        end
        jSlice(:,1)=[];
        jSignSum = sign(sum(jSlice, 2)); % sum of signals
        macs(:,j) = jSignSum; % Assign to final output
    end

end


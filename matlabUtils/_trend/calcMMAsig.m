function [signal,MMAstruct, signalCube] = calcMMAsig(data,mmaParams,opt)
% calculate Mixed Moving Average signal
% generate MAs, mixing weights:
if nargin < 2 || ~isstruct(mmaParams)
    freqOpt = 'long';
else
    if isfield(mmaParams,'front')
      aa = mmaParams.front(1);
      while aa(end) < mmaParams.front(2)
        nextOne = max([aa(end)+1,round(aa(end)*mmaParams.intervalFactor)]);
        aa = [aa,nextOne]; %#ok
      end % while
      freqOpt.a = aa;
      freqOpt.b = mmaParams.front2backRatio; 
    elseif isfield(mmaParams,'a')&&isfield(mmaParams,'b')
      freqOpt = mmaParams;  
    end 
end 

MMAstruct  =  makeMMAsSimple(freqOpt); 
cumValues = calcCum(data.values,0); 
if nargin > 2 && opt==2 
    % this option conditions the magnitude of the trend signal by 
    %   volatility dynamics; first, creating the conditioning multiplier:
    volMult = modifyMomentumByVol(data,MMAstruct);
    % generate signal using weighted lookbacks, passing the volatility
    % conditioning multiplier: 
    signal = MMAsignals(cumValues,MMAstruct.ma, MMAstruct.wts, volMult);
elseif nargin > 2 && opt==3
    signal = MMAsignalsEnhanced(cumValues, data, MMAstruct.ma, MMAstruct.wts); 
else
    % this option uses no volatility conditioning: 
    [signal,signalCube] = MMAsignals(cumValues, data.values, MMAstruct.ma, MMAstruct.wts);
end % if
signal(isnan(data.values)) = nan; 
for j =1 :size (signalCube,3)
    tempsignalCube= signalCube(:,:,j); 
    tempsignalCube(isnan(data.values)) = nan; 
    signalCube(:,:,j)=tempsignalCube; 
end 

end % fn
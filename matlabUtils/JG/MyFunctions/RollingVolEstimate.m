%
%__________________________________________________________________________
% Here is the MATLAB code that one could use to estimate historical volatility using different methods
% 
% Historical Close-to-Close volatility
% Historical High Low Parkinson Volatility
% Historical Garman Klass Volatility
% Historical Garman Klass Volatility modified by Yang and Zhang
% Historical Roger and Satchell Volatility
% Historical Yang and Zhang Volatility
% Average of all the historical volatilities calculated above
%
%__________________________________________________________________________


function vol = RollingVolEstimate(o,h,l,c, parameters)
% Estimate Volatility using different methods
% EstimateVol(O,H,L,C)gives an estimate of volatility based on Open, High,
% Low, Close prices.
% INPUTS:
% o : Open Price
% h : High Price
% l : Low Price
% c : Close Price
% n--Number of historical days used in the volatility estimate
% OUTPUT:
% Vol is a structure with volatilities using different methods.
% hccv -- Historical Close-to-Close volatility
% hhlv -- Historical High Low Parkinson Volatility
% hgkv -- Historical Garman Klass Volatility
% hgkvM -- Historical Garman Klass Volatility modified by Yang and Zhang
% hrsv -- Historical Roger and Satchell Volatility
% hyzv -- Historical Yang and Zhang Volatility
% AVGV -- Average of all the historical volatilities calculated above

[nsteps,ncols=size(c);
vol = zeros(size(c));

lookbackPeriod = parameters(1,1); %Number of historical days used in the volatility estimate
retPeriod = parameters(1,2);
yearNbDays = 256; %Number of trading Days in a year

for j=1:ncols
    
    % extract
    openx = o(:,j);
    highx = h(:,j);
    lowx = l(:,j);
    closex = c(:,j);
    rowStartIdx = StartFinder(c, 'znan');
    closexRet = Delta(closex, 'roc',retPeriod);
    
    for i= rowStartIdx + n : nsteps
        
        openxSnap = openx(i-lookbackPeriod+1:i,j);
        highxSnap = highx(i-lookbackPeriod+1:i,j);
        lowxSnap = lowx(i-lookbackPeriod+1:i,j);
        closexSnap = closex(i-lookbackPeriod+1:i,j);
        closexRetSnap = closexRet(i-lookbackPeriod+1:i,j);
        lengthSnap = size(closexSnap ,1);
       
        switch method

            case {'hccv', 'Close-to-Close', 'close-to-close', 'c2c'}
                
                vol(i,j) = sqrt((yearNbDays/(lookbackPeriod -2)) * sum((losexRetSnap - mean(closexRetSnap)).^2));
                
            case {'hhlv', 'Parkinson', 'parkinson', 'park'}
                
                vol(i,j) = sqrt((yearNbDays/(4*lookbackPeriod *log(2))) * sum((log(highxSnap ./ lowxSnap)).^2));
                
            case {'hgkv', 'Garman Klass', 'Garman-Klass', 'GK', 'gk'}
                
                vol(i,j) = sqrt((yearNbDays/lookbackPeriod) * ...
                           sum((0.5*(log(highxSnap./lowxSnap)).^2) - ...
                           (2*log(2) - 1).*(log(closexSnap./openxSnap)).^2));
                
            case {'hgkvM', 'Garman Klass Volatility modified by Yang and Zhang', 'Garman Klass Modified', 'GKM', 'gkm'}
                
                        sqrt((yearNbDays/n) * ...
                            sum((log(openxSnap(2:lengthSnap)./closexSnap(1:lengthSnap-1))).^2 + ...
                            (0.5*(log(highxSnap(2:lengthSnap)./lowxSnap(2:lengthSnap))).^2) - ...
                            (2*log(2) - 1)*(log(closexSnap(2:end)./openxSnap(2:lengthSnap))).^2));
  
            case {'hrsv', 'Roger and Satchell', 'Roger Satchell', 'rs', 'RS'}
                
                vol(i,j) = sqrt((yearNbDays/lookbackPeriod) * ...
                           sum((log(highxSnap./closexSnap).*log(high./open)) +  ...
                          (log(lowxSnap./closexSnap).*log(loxSnapw./openxSnap))));
                
            case {'hyzv ', 'Yang and Zhang', 'YangZhang', 'Yang-Zhang', 'YZ', 'yz'}
                
                muO = (1/lookbackPeriod)*sum(log(openxSnap(2:lengthSnap)./closexSnap(1:lengthSnap-1)));
                sigmaO = (yearNbDays/(lookbackPeriod-1)) * sum((log(openxSnap(2:lengthSnap)./closexSnap(1:lengthSnap-1)) - muO).^2);
                muC = (1/lookbackPeriod)*sum(log(closexSnap./openxSnap));
                sigmaC = (yearNbDays/(lookbackPeriod-1)) * sum((log(close./open) - muC).^2);
                %sigmaRS = hrsv();
                sigmaRS = sqrt((yearNbDays/lookbackPeriod) * ...
                           sum((log(highxSnap./closexSnap).*log(high./open)) +  ...
                          (log(lowxSnap./closexSnap).*log(loxSnapw./openxSnap))));
                      
                sigmaRS = sigmaRS^2;
                k = 0.34/(1+((lookbackPeriod+1)/(lookbackPeriod-1)));
                
                vol(i,j)  = sqrt(sigmaO+(k*sigmaC)+((1-k)*(sigmaRS)));
                
            case {'AVGV', 'averageAll', 'avgv'}

        end
    
    end
    
end






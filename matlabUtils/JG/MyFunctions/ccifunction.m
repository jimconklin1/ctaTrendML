function cci = ccifunction(h,l,c,MAPer,StdPer,alpha)

%__________________________________________________________________________
% The function computes the Commodity Channel Index developped by
% Lambert
% CCI = (Typical Price  -  20-period SMA of TP) / (.015 x Mean Absolute Deviation)
% Typical Price (TP) = (High + Low + Close)/3
% Constant = .015
% Parameters:
% - h is a matrix m*n of High
% - l is a matrix m*n of Low
% - c is a matrix m*n of Close
% - nbd is the period over which the moving average is computed
% - alpha is the Lambert's parameter usually set at 0.015
% - Lambert set the constant at .015 to ensure that approximately 70 to 80%
%   of CCI values would fall between -100 and +100. 
%   This percentage also depends on the look-back period. A shorter CCI 
%   (10 periods) will be more volatile with a smaller percentage of values
%   between +100 and -100. Conversely, a longer CCI (40 periods) will have
%   a higher percentage of values between +100 and -100.
%__________________________________________________________________________

% nbd is the period over which the moving average is computed
%Dimension & Prelocate matrix
cci = zeros(size(c));
[nsteps,ncols]=size(c);
%
% Computew Typical price
tp = (h+l+c)/3;
% Computes the arithmetic moving average
smatp = arithmav(tp, MAPer);
% Deviation from smatp
devtp = tp-smatp;
smadevtp = arithmav(abs(devtp), StdPer);
% Commodity Channel index
cci(MAPer+StdPer:nsteps,1:ncols)  = 1/alpha * devtp(MAPer+StdPer:nsteps,1:ncols) ./ smadevtp(MAPer+StdPer:nsteps,1:ncols) ;
% Clean
for i=MAPer+StdPer:nsteps:nsteps
    for j=1:ncols
        if isnan(cci(i,j)) || ~isfinite(cci(i,j))
            cci(i,j) = cci(i-1,j);
        end
    end
end

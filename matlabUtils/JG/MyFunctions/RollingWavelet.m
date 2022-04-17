function y = RollingWavelet(x,lookback,method, lev, MyWavelet)
%
% PURPOSE: computes Rolling wavelet
%---------------------------------------------------
% 'haar' Haar wavelet
% 'db'   Daubechies wavelets
% 'sym'  Symlets
% 'coif' Coiflets
% 'bior' Biorthogonal wavelets
% 'rbio' Reverse biorthogonal wavelets
% 'meyr' Meyer wavelet
% 'dmey' Discrete approximation of Meyer wavelet
% 'gaus' Gaussian wavelets
% 'mexh' Mexican hat wavelet
% 'morl' Morlet wavelet
% 'cgau' Complex Gaussian wavelets
% 'shan' Shannon wavelets
% 'fbsp' Frequency B-Spline wavelets
% 'cmor' Complex Morlet wavelet
%---------------------------------------------------
[nsteps,ncols]=size(x);
y=zeros(size(x));


switch method
    
    case { 'db', 'Daubechies'}
        for j=1:ncols
            for i=lookback:nsteps
                xSnap=x(i-lookback+1:i,j);
                xd = wden(xSnap,'sqtwolog','s','sln',lev, MyWavelet);
                y(i,j)=xd(length(xd));
            end
        end
        
    case { 'sym', 'Symlets'}
        for j=1:ncols
            for i=lookback:nsteps
                xSnap=x(i-lookback+1:i,j);
                xd = wden(xSnap,'sqtwolog','s','sln',lev,MyWavelet);
                y(i,j)=xd(length(xd));
            end
        end        
        
end


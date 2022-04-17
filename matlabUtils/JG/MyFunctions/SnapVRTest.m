function [vrt,zvrt] = SnapVRTest(x,q,cor)
%
%__________________________________________________________________________
%
% Compute the Variance Ratio Test for the whole time series. 
% This function makes use of VRTest which gives a point estimate only.
%
% note: q values must be between 2 and n/2-1, with n -s size of the vector
%
% -- Inputs --
% x    = the time series (a matrix of 'n' rows - observations/days - 
%        and 'p' columns - assets).
% q    = an index scalar / vector.
% cor  = the method 'cor' can take one of the following values
%        - 'hom' is for homoskedastic time series (i.e. all random 
%           variables in the sequence have the same finite variance).
%        - 'het' is for heteroskedastic time series (sub-populations that
%           have different variabilities from others. More precisely, 
%           suppose there is a sequence of random variables {Yt}t=1n and a
%           sequence of vectors of random variables, {Xt}t=1n. In dealing 
%           with conditional expectations of Yt given Xt, the sequence 
%           {Yt}t=1n is said to be heteroscedastic if the conditional 
%           variance of Yt given Xt, changes with t.)
%           Correcting for heteroscedasticity simply means to normalise the
%           time series by its variance.
%
% -- Output --
% vrt  = the the value of the VRTest.
% zvrt = the z-score of the VRTest.
% Joel Guglietta - 2013
%__________________________________________________________________________
%
% -- Dimensions & Prelocate matrices
[nsteps,ncols] = size(x);
vrt = zeros(1,ncols);
zvrt = zeros(1,ncols);

% - -Run the VRT over the whole time series --
for j=1:ncols
    % Extract stock
    mystock = x(:,j);
    % .. Step 1: find the first cell to start the code ..
    start_date = zeros(1,1);
    for i=1:nsteps
        if ~isnan(mystock(i,1)), start_date(1,1)=i;
        break               
        end                                 
    end
    % Point estimate of VRT ans Zscore_VRT
    ext_mystock = mystock(start_date(1,1):end, 1);
    [ext_vrt,ext_zvrt]=VRTest(ext_mystock,q,cor);
    % Assign point estimate
    vrt(1,j) = ext_vrt;
    zvrt(1,j) = ext_zvrt;
end
        
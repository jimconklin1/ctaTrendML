function[y] = Add0VectorColumn(x,Position)
%
% _________________________________________________________________________
%
% This code adds one 0 vector column before a given column of which the
% index is given by "Position".
%
% This code is in particular needed for the Long-Short FX model where we
% mix endogenous and exogenous factors all given versus a benchmark
% currency, i.e. the USD.
%
% INPUT--------------------------------------------------------------------
%
%   x = a matrix of data...................................................
%
%   USDPosition............................................................
%   The column number in the matrix of factors where the USD data 
%   is located
%
% OUTPUT-------------------------------------------------------------------
%
% y = the column-vector augmented matrix.
%__________________________________________________________________________

% Define dimesions & Prelocate matrices
[nsteps,ncols]=size(x);      % Dimension

if Position==1
    y=[zeros(nsteps,1) x];
elseif Position==ncols
    y=[x, zeros(nsteps,1)];
else
    y=[x(nsteps,1:Position-1), zeros(nsteps,1), x(nsteps,Position:ncols)];
end
   
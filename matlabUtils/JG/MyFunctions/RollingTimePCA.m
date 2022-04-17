function z = RollingTimePCA(x, lookcbackPCA, lag, NbComp,  method)
%
%__________________________________________________________________________
% PURPOSE:
%     Construct a time-based rolling PCA and keep in memory coordinates on
%     the p-th axis
%
% INPUTS:
%     x is a matrix
%     lag is the number of lags(scalar)
% 
%     method: looks at the 'orientation' of the table
%       - 'obs_data': [rows    = observations (trials/days/time)] x ...
%                     [columns = data/dimensions/nb.OfMeasurementTypes]
%       - 'data_obs': [rows    = data/dimensions/nb.OfMeasurementTypes] x ...
%                     [columns = observations (trials/days/time)]
% 
% OUTPUTS:
%     a cube with the PCA results at each point of time for each of the
%     Eigenvalues selected
% 
% Author: Joel Guglietta
% Date: 06/04/2012
%z =RollingPCA(c, 100, 0, 10, 'obs_data');
%__________________________________________________________________________

% -- Dimmensions & Prelocate matrices --
[nsteps,ncols]=size(x);
z=zeros(nsteps,NbComp);

% Time-based rolling PCA
for i= lookcbackPCA + lag : nsteps
    % -- Extract asset --
    x_fetch = x(i-lookcbackPCA+1:i,:);
    y = smartlagmatrix1(x_fetch, x(:,1), i-lookcbackPCA+1, lag); % Create a lagged matrix
    [signalspca, pc, eval, veval]=PCAfunc([x_fetch,y], method);
    clear eval veval
    % check size signalspca
    [nrowssignals, ncolssignals] = size(signalspca);
    if nrowssignals == lookcbackPCA && ncolssignals >= NbComp
        z(i,1:NbComp) = signalspca(length(pc), 1:NbComp);
    else
        z(i,1:NbComp) = zeros(1, NbComp);
    end
end

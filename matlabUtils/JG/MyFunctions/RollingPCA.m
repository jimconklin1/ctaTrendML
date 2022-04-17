function z = RollingPCA(x, lookbackPCA, NbComp)
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
%e1=expmav(c,8);e2=expmav(c,13);e3=expmav(c,21);e4=expmav(c,32);
%__________________________________________________________________________

% -- Dimmensions & Prelocate matrices --

%x=ma;
%lookbackPCA=3; 
%NbComp=1;

[nsteps,ncols]=size(x);
z=zeros(nsteps,NbComp);

% Time-based rolling PCA
for i= lookbackPCA  : nsteps
    % -- Extract asset --
    x_fetch = x(i-lookbackPCA+1:i,:);
    %y_fetch = y(i-lookbackPCA+1:i,:);
    %[signalspca, pc, eval, veval]=PCAfunc([x_fetch,y_fetch], method);
    %[coefs,scores,variances,t2] = princomp([x_fetch,y_fetch]);
    [coefs,scores,variances,t2] = pca(x_fetch);%princomp(x_fetch);
    clear eval veval
    % check size signalspca
    %[nrowssignals, ncolssignals] = size(signalspca);
    [nrowssignals, ncolssignals] = size(scores);
    if nrowssignals == lookbackPCA && ncolssignals >= NbComp
        z(i,1:NbComp) = scores(size(scores,1), 1:NbComp);
    else
        z(i,1:NbComp) = zeros(1, NbComp);
    end
end

function x_vlookedup = IntersectData(tday_base, tday_x, x, method)

%__________________________________________________________________________
%
% This function replicates intersect two time series
%
% Input
% tday_base: the time-stamp (column vector nx1) on which the targeted time
%            series x is vlooked-up
% tday_x: the time-stamp (column vector px1) of time series x
% x: a matrix of data (pxm)
% method: when the function gives NaN (as the tday_base date does not exist
%         in tday_x), the user can replace NaN with non-NaN most recent
%         value.
%         This function makes use of the function "CarryForwardPastValue".
% Several options are possible:
% {'KeepNaN', 'keepNaN', 'WithNan', 'withNan'}: Keep the NaN
% {'NaNisMostRecent', 'cleanNaN', 'CleanNaN'}: replace NaN by most recent
%                                              previous real number
% {'NaN2Zero', 'NaN2zero', 'NaNToZero', 'NaNtoZero', 'NaNTo0', 'NaNto0'} 
% as aboce but sometime the first rwos are NaN. The code put 0
%
% Output
% x_vlookedup: the matrix x vlooked-up on tday_base where NaN
%                                                 joel guglietta. July 2014 
%__________________________________________________________________________

% -- Set dimension --
ncols = size(x,2);
x_vlookedup = NaN(length(tday_base), ncols);

% -- Find the row indices --
[junk idx_target idx] = intersect(tday_x, tday_base);

% -- Replicate Excel Vlookup formula --
for j=1:ncols
    snap_x = x(:,j);
    x_vlookedup(idx,j) = snap_x(idx_target);
end
    
switch method
    case {'KeepNaN', 'keepNaN', 'WithNan', 'withNan'}
        x_vlookedup = x_vlookedup;
    case {'NaNisMostRecent', 'cleanNaN', 'CleanNaN'}
        x_vlookedup = CarryForwardPastValue(x_vlookedup);
    case {'NaN2Zero', 'NaN2zero', 'NaNToZero', 'NaNtoZero', 'NaNTo0', 'NaNto0'}  
        x_vlookedup = CarryForwardPastValue(x_vlookedup);
        x_vlookedup(isnan(x_vlookedup))=0;
end

function x_vlookedup = VlookupExcelMatrix(tday_base, tday_x, x)

%__________________________________________________________________________
%
% This function replicates the vlookup formula of excel
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
nsteps = size(tday_base,1);
x_vlookedup = zeros(nsteps, ncols);

for j=1:ncols
    x_vlookedup(:,j) = VlookupExcel(tday_base, tday_x, x(:,j), 'NaNtoZero');
end


    


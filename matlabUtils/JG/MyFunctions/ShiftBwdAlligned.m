function y = ShiftBwdAlligned(x,lag, method)
%
%__________________________________________________________________________
%
% This function shifts the variable backward by for a given lag
% Two methods are available:
% 'NaN', 'nan', 'N', 'n':   fills the first empty data with 'NaN'
% 'zero', 'Zero', 'z', 'Z': fill the first empty data with 0
%
%__________________________________________________________________________
%
assert(lag>=0);
switch method
    case {'NaN', 'nan', 'N', 'n'}
        y=[NaN(lag,size(x,2), size(x, 3));x(1:end-lag,:, :)];        
    case {'zero', 'Zero', 'z', 'Z'}
        y=[zeros(lag,size(x,2), size(x, 3));x(1:end-lag,:, :)];
end
    

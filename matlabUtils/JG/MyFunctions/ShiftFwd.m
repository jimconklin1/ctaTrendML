function y = ShiftFwd(x,lag,method)
%
%__________________________________________________________________________
%
% This function shifts the variable forward by for a given lag
% Three methods are available
% 'NaN', 'nan', 'N', 'n':           fills the empty data with 'NaN'
% 'zero', 'Zero', 'z', 'Z':         fill the empty data with 0
% 'CarryOver', 'carryover', ...
% 'Carry over', 'Carry Over', ...
% 'CO', 'co':                       carry over the last data
%
%__________________________________________________________________________
%
assert(lag>=0);
[m,n,p]=size(x);
switch method
    case {'NaN', 'nan', 'N', 'n'}
        y=[x(lag+1:end,:, :); NaN*ones(lag,size(x,2), size(x, 3))];
    case {'zero', 'Zero', 'z', 'Z'}
        y=[x(lag+1:end,:, :); 0*ones(lag,size(x,2), size(x, 3))];
    case {'CarryOver', 'carryover', 'Carry over', 'Carry Over', 'CO', 'co'}       
        y=[x(lag+1:end,:, :); 0*ones(lag,size(x,2), size(x, 3))];   
        y(end-lag+1:end,:,:) = repmat(y(end-lag,:,:),[lag,1,1]);
end        
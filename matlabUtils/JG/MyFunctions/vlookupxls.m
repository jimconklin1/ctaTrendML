%VLOOKUP.M
function b=vlookupxls(MBaseVlookup, ColBaseVlookup, MToVlookup, Col2Retrieve)
% 
%__________________________________________________________________________
% Return matrix b which has equal size as m and the values are taken from
% from the n column of lookup table lut.
% This is matrix version of VLOOKUP similar to MS Excel function.
% 
% (c) 2014 by Joel Guglietta
%__________________________________________________________________________

% Note: The following code work fine and fast
% find value of m that equal to the value of first column 
% the lut table and replace it with the value of column n
% if cannot find, return NaN
b=interp1(MBaseVlookup(:,ColBaseVlookup), MToVlookup, MToVlookup(:,Col2Retrieve));

% replace NaN with zero
b(isnan(b))=0;        



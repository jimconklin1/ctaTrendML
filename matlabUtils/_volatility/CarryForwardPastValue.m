function y = CarryForwardPastValue(x)
%
%__________________________________________________________________________
%
% This function carries forwad past value
%
%__________________________________________________________________________

[n,c] = size(x);
y = x;
for i=2:n
    for j=1:c
        if isnan(y(i,j))
            y(i,j) = y(i-1,j);
        end
    end
end
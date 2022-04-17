function y = ExtractCleanFactor(i,x,p)
%
%__________________________________________________________________________
%
% This function extract the factor if and only if the price is different
% from 0 and is not NaN.
% If not, it returns NaN
%__________________________________________________________________________


% -- Prelocate -- 
ncols=size(x,2);
y=zeros(1,ncols); 
   
for j=1:ncols
    if ~isnan(p(i,j)) && ~isnan(p(i-1,j)) && p(i,j)~=0 && p(i-1,j)~=0
        y(1,j)=x(i,j);
    else
        y(1,j)=NaN;
    end
end

%switch method
%case {'p', 'percent', 'percentile', 'prank', 'percent rank'}
%    y=PercentileRank(y(1,:)','excel')';   
%case {'p', 'percent', 'percentile', 'prank', 'percent rank'}
%    y=NominalRank(y(1,:)','excel')';   
%end


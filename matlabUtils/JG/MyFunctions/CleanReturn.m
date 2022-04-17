function y = CleanReturn(i,j,s,w,p)
%
%__________________________________________________________________________
%
%
%__________________________________________________________________________

% -- Prelocate -- 
%[nsteps,ncols]=size(p);
%y=zeros(1,ncols); 
%   
%for j=1:ncols
%    for i=2:nsteps
%        if ~isnan(p(i,j)) && ~isnan(p(i-1,j)) && p(i,j)~=0 && p(i-1,j)~=0
%            y(1,j)=s(i-1,j) * w(i-1,j) * (p(i,j)/p(i-1,j)-1) ;
%        else
%            y(1,j)=0;
%        end
%    end
%end

if ~isnan(p(i,j)) && ~isnan(p(i-1,j)) && p(i,j)~=0 && p(i-1,j)~=0
    y=s(i-1,j) * w(i-1,j) * (p(i,j)/p(i-1,j)-1) ;
else
    y=0;
end


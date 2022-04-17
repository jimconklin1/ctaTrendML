
function y = Clean0Mean(x,xRef)

%__________________________________________________________________________
%
%
%__________________________________________________________________________
 
[nsteps,ncols]=size(x);
 start_date = zeros(1,ncols);
 y=zeros(nsteps,1);

 for j=1:ncols
    for i=1:nsteps
        if ~isnan(xRef(i,j)) && xRef(i,j) ~= 0
            start_date(1,j)=i;
        break               
        end                                 
    end
 end
 
 for i=1:nsteps
     mycount=0;
     for j=1:ncols
         if xRef(i,j)~=0 && x(i,j) ~= Inf && x(i,j) ~= -Inf && ~isnan(x(i,j))
             mycount=mycount+1;
         end
     end
     if mycount>0
         y(i)=sum(x(i,:))/mycount;
     end
 end
 
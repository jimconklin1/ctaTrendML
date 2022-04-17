function[Y] = ParkinsonFunction(h,l,nbd)
%__________________________________________________________________________
%The function frsi computes the rate of change
%__________________________________________________________________________

% Identify dimension-------------------------------------------------------
[nsteps,ncols] = size(h); 
hlr = zeros(size(h));
Y = zeros(size(h));
%
% Main Loop----------------------------------------------------------------
for j=1:ncols
    start_date=zeros(1,1);
    % Step 1: Find the first cell to start the code------------------------  
    for i=1:nsteps      
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ...
           h(i,j)~=0 && l(i,j)~=0
            start_date(1,1)=i;  
            break
        end
    end
    %High-Low return-------------------------------------------------------
    for i=start_date(1,1):nsteps
        hlr(i,j)=log(h(i,j)/l(i,j));
    end
% Parkinson----------------------------------------------------------------
    for i=start_date(1,1)+nbd:nsteps
        mysum=0;
        for k=i-nbd+1:i
            mysum=mysum+power(hlr(k,j),2)/(4*log(2));
        end
        Y(i,j)=power(mysum/nbd,0.5);
    end
end
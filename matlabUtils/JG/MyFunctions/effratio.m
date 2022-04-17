function[Y, Ym] = effratio(X,mylag, mysmooth)

Y=zeros(size(X));   [nsteps,ncols]=size(X);

for j=1:ncols
    % Find starting point
    for k=1:nsteps
        if ~isnan(X(k,j))
            start_date=k;
        break
        end
    end
    % Compute efifciency ratio
    for i=start_date+mylag+mysmooth:nsteps
        mydiff=abs(X(i,j)-X(i-mylag+1,j));
        mycount=0;
        for u=i-mylag+1:i
            mycount=mycount+abs(X(u,j)-X(u-1,j));
        end
        if ~isnan(mydiff) && ~isnan(mycount) && mycount~=0
            Y(i,j)=mydiff/mycount;
        end
    end
end
% Smotth efficiency ratio
Ym=expmav(Y,mysmooth);

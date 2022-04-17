function FT = fishert(c,h,l,nbd)
%
%--------------------------------------------------------------------------
% Compute the Fisher's trassform
%--------------------------------------------------------------------------
%
% -- Prelocate the matrix & Dimensions --
FT=zeros(size(c));  Yg=zeros(size(c));
[nbsteps,nbcols]=size(c);

% -- This Code Compute the Fisher Transformation --

for j=1:nbcols
    % find the first cell to start the code
    for i=1:nbsteps
        if ~isnan(c(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j)) && c(i,j)>0
            start_date=i;
        break
        end
    end
    % Compute the value used in the distribution
    for i=start_date+1+nbd:nbsteps
        if ~isnan(h(i,j)) && ~isnan(l(i,j)) && ~isnan(c(i-1,j)) && ...
            (max(h(i-nbd+1:i))-min(l(i-nbd+1:i)))>0
            Yg(i,j)=0.5*2*((c(i,j)-min(l(i-nbd+1:i,j)))/(max(h(i-nbd+1:i,j))-min(l(i-nbd+1:i,j)))-0.5)+0.5*Yg(i-1,j);
        end
    end
    % Compute the Fisher Transform
    for i=start_date+1+nbd:nbsteps
        if ~isnan(Yg(i,j)) && (1-Yg(i,j))~=0 && ((1+Yg(i,j))/(1-Yg(i,j)))>0
            FT(i,j)=0.5*log((1+Yg(i,j))/(1-Yg(i,j)));
        end
    end    
end
clear Yg

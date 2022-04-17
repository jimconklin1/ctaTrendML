function [z] =ZScoreFactor(x,Bounds)
%__________________________________________________________________________
%
% This function computes the Z-score in a cross section way and makes up
% for NaN
%__________________________________________________________________________
%
% -- Dimension & Prelocate Matrix --
[nsteps,ncols]=size(x);
z=zeros(size(x));

for i=1:nsteps
    % -- Extract factor --
    xi = x(i,:);
    % -- Retrieve the col index of the Non NaN values --
    colind_goodxi = find(~all(isnan(xi), 1));
    % -- Extract the matrix of Non NaN xi() --
    goodxi = xi(1,colind_goodxi);
    % -- Standard deviation --
    Stdx=std(goodxi(1,:));
    % -- Mean --
    Meanx=mean(goodxi(1,:));    
    % -- Compute & Troncate --
    ZRow=(goodxi-repmat(Meanx,1,size(goodxi,2))) / Stdx;
    ZRow( find(ZRow < Bounds(1,1))) = Bounds(1,1) ;
    ZRow( find(ZRow > Bounds(1,2))) = Bounds(1,2) ;
    % -- Assign --
    z(i,:) = ZRow(1,colind_goodxi);
end        
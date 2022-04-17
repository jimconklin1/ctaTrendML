function y = ExtractCorrCube(X,a1,a2)


[ncols,ncols,nsteps]=size(X);
y=zeros(nsteps,1);
for u=1:nsteps
    y(u,1)=X(a1,a2,u);
end
plot(y);
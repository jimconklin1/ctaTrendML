function C=Kronecker(A,B)

[m,n] = size(A);
[p,q]= size(B);

C=zeros(p*m,q*n);
for i=1:m
    for j= 1:n
        C((i-1)*p+1:i*p, (j-1)*q+1:j*q) = A(i,j)*B;
    end
end

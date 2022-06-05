function res = recursiveLeastSquares(X, y, b)

m = size(X,2);
n = size(y,1);
R = zeros(m,m);
p = zeros(m,1);
res = zeros(n,1);

for i= 1:n
    R = R*b + X(i,:)'*X(i,:);
    p = p*b + y(i)*X(i,:)';
    
    if i >= m
        beta = linsolve(R,p);
        res(i) = y(i)-X(i,:)*beta;
    end
end



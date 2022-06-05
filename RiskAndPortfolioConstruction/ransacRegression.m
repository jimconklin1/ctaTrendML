function weights = ransacRegression(y,X,outlierPercent)

[n,p] = size(X);
if not (max(X(:,1))== 1 && min(X(:,1))== 1)
    X =[ones(n,1) X];
end
W = eye(n);
W1 = zeros(n);
iter = 1;
while isequal(W,W1) == false && iter < 10
    beta = X'*W*X\X'*W*y;
    err = y-X*beta;
    err2 = err.*err;
    maxerr2 = prctile(err2,100-outlierPercent);
    W1 = W;
    for i=1:n
        if err2(i) < maxerr2
            W(i,i) = 1.0;
        else
            W(i,i)= 0.0;
        end
    end
    iter = iter + 1;
end
weights = diag(W);

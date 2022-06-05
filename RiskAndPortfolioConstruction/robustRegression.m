function weights = robustRegression(y,X,outlierThreshold)

[n,p] = size(X);
if not (max(X(:,1))== 1 && min(X(:,1))== 1)
    X =[ones(n,1) X];
end
W = eye(n);
W1 = zeros(n);
iter = 1;
while isequal(W,W1) == false && iter < 3
    beta = X'*W*X\X'*W*y;
    err = y-X*beta;
    merr = median(err);
    maderr = median(abs(err-merr));
    W1 = W;
    for i=1:n
        if abs((err(i)-merr)/maderr) < outlierThreshold 
            W(i,i) = 1.0;
        else
            W(i,i)= 0.0;
        end
    end
    iter = iter + 1;
end
weights = diag(W);

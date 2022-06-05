function w = GlobalMaximumVariance(covar,longOnly)

nAssets = size(covar,1);
objFun =@(w)(-1)*w'*covar*w;
lb=zeros(nAssets,1);
ub=ones(nAssets,1);
Aeq=ones(1,nAssets);
beq=ones(1,1);

if longOnly == false
    lb = [];
    ub =[];
end

w0 = ones(nAssets,1)/nAssets;
w=fmincon(objFun,w0,[],[],Aeq,beq,lb,ub);
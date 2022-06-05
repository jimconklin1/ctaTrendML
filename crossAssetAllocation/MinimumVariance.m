function w = MinimumVariance(mu,covar,periods,requiredReturn,longOnly)

if longOnly && (requiredReturn < min(mu)*periods || requiredReturn > max(mu)*periods)
    throw(MExcepton("Cannot find a solution meeting the return requirement"));
end
    
nAssets = size(covar,1);
objFun =@(w)(w'*covar*w)*periods;

lb=zeros(nAssets,1);
ub=ones(nAssets,1);
Aeq=ones(2,nAssets);
Aeq(2,:)=mu'*periods;
beq=ones(2,1);
beq(2,1)=requiredReturn;

if longOnly == false
    lb = [];
    ub =[];
end

w0 = ones(nAssets,1)/nAssets;
w=fmincon(objFun,w0,[],[],Aeq,beq,lb,ub);
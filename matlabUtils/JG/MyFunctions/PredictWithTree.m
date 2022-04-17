function Y = PredictWithTree(Xtrain, Ytrain, X, method)

%--------------------------------------------------------------------------
%
% Wrap the functions "RegressionTree.fit" & "predict" 
% transform the Ytrain in-1/0/+1 if needed
%
% Example: 5 FX cross (FX1,..,FX5),
%          and 2 explaining factors: RSI & MACD lagged 5 day,
%          Ytrain is 5-day return'.
%          We want to predict 5-day return (ret) in 5 days
% Xtrain = [RSI1(t-5), RSI2(t-5),  RSI3(t-5), RSI4(t-5), RSI5(t-5) ; ...
%           MACD1(t-5),MACD2(t-5),MACD3(t-5),MACD4(t-5),MACD5(t-5)]
% Ytrain = [ret1(t),ret1(t),ret3(t),ret4(t),ret5(t)]
% X      = [RSI1(t), RSI2(t), RSI3(t-5), RSI4(t), RSI5(t) ; ...
%          MACD1(t),MACD2(t),MACD3(t-5),MACD4(t),MACD5(t)]
%
% INPUT:
% Xtrain: Matrix of explaining variables used to train the tree
%        (assets in columns * factors in rows)
% Ytrain: Matrix of explained variables used to train the tree
%        (assets in columns * factor in rows)
% X:      Matrix of explaining variables to predict Y.
%        (assets in columns * factors in rows)
% method: transform Ytrain in a simple categorical variable (-1/0/+1) 
%
%--------------------------------------------------------------------------

% Clean Xtrain & Ytrain from NaN
    % Concatenate Xtrain & Ytrain only to clean
    Xtrain = Xtrain'; Ytrain = Ytrain';
    X_Y = [ Xtrain , Ytrain ];
    % Trick : sum to get NaN & Find NaN Indices
    sX_Y = sum(X_Y,2); 
    index_nonisnan = find(~isnan(sX_Y));
    % Extract nonisnan index column only
    cX_Y = X_Y(index_nonisnan,:);
    % Clean Xtrain & Ytrain ("assets * factors" vs. "assets * target")
    Xtrain = cX_Y(:,1:end-1);
    Ytrain = cX_Y(:,end);
    
% Transform Ytrain in category output
switch method
    case 'transform'
        mu = mean(Ytrain); sigma = std(Ytrain);
        supYtrain = mu + 0.5*sigma ; 
        infYtrain = mu - 0.5*sigma ;
        Ytraincat = zeros(size(Ytrain));
        Ytraincat(find(Ytrain <= infYtrain)) = -1;
        Ytraincat(find(Ytrain >= supYtrain)) = 1;
    case {'no transform', 'dun transform', 'simple'}
        Ytraincat = Ytrain;
end

% -- Create Regression Tree --
% note: in RegressionTree, factors (inputs) are given in Coloumns and 
% individuals in rows, , for e.g.: [Factor1, Factor2, ..., Factorn],
% with Factor(i) a column vector.
tree = RegressionTree.fit(Xtrain,Ytraincat);
             
% -- Clean Matrix of Inputs for Prediction --
    % Trick: sum to get NaN & Find NaN Indices
    X = X';
    sX = sum(X,2); 
    X_nonisnan_ind = find(~isnan(sX));
    % Extract nonisnan index column only
    cX = X(X_nonisnan_ind,:);    
    % -- Predict with Tree --
    Ypred = predict(tree, cX);
    % -- Assign to cYpred (clean Ypred) --
    cYpred = NaN(length(X),1); % create a vector of NaN
    for u=1:length(X_nonisnan_ind)
        index_stock = X_nonisnan_ind(u,1);
        cYpred(index_stock,1) = Ypred(u,1);
    end
    Y = cYpred;

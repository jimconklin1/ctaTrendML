
%http://www.ece.umn.edu/users/cherkass/ee4389/SVR.html

%Scale the data to [0,1]
[trn_data, tst_data, jn2] = scaleSVM(trn_data, tst_data, trn_data, 0, 1);

%Perform model selection
param.s = 3; 					% epsilon SVR
param.C = max(trn_data.y) - min(trn_data.y);	% FIX C based on Equation 9.61
param.t = 2; 					% RBF kernel
param.gset = 2.^[-7:7];				% range of the gamma parameter
param.eset = [0:5];				% range of the epsilon parameter
param.nfold = 5;				% 5-fold CV

Rval = zeros(length(param.gset), length(param.eset));

for i = 1:param.nfold
	% partition the training data into the learning/validation
	% in this example, the 5-fold data partitioning is done by the following strategy,
	% for partition 1: Use samples 1, 6, 11, ... as validation samples and
	%			the remaining as learning samples
	% for partition 2: Use samples 2, 7, 12, ... as validation samples and
	%			the remaining as learning samples
	%   :
	% for partition 5: Use samples 5, 10, 15, ... as validation samples and
	%			the remaining as learning samples

	data = [trn_data.y, trn_data.X];
	[learn, val] = k_FoldCV_SPLIT(data, param.nfold, i);
	lrndata.X = learn(:, 2:end);
	lrndata.y = learn(:, 1);
	valdata.X = val(:, 2:end);
	valdata.y = val(:, 1);

	for j = 1:length(param.gset)
		param.g = param.gset(j);

		for k = 1:length(param.eset)
			param.e = param.eset(k);
			param.libsvm = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
					' -c ', num2str(param.C), ' -g ', num2str(param.g), ...
					' -p ', num2str(param.e)];

			% build model on Learning data
			model = svmtrain(lrndata.y, lrndata.X, param.libsvm);

			% predict on the validation data
			[y_hat, Acc, projection] = svmpredict(valdata.y, valdata.X, model);

			Rval(j,k) = Rval(j,k) + mean((y_hat-valdata.y).^2);
		end
	end

end

Rval = Rval ./ (param.nfold);

%Select the parameters (with minimum validation error)
[v1, i1] = min(Rval);
[v2, i2] = min(v1);
optparam = param;
optparam.g = param.gset( i1(i2) );
optparam.e = param.eset(i2);

%Train the selected model using all training samples
optparam.libsvm = ['-s ', num2str(optparam.s), ' -t ', num2str(optparam.t), ...
		' -c', num2str(optparam.C), ' -g ', num2str(optparam.g), ...
		' -p ', num2str(optparam.e)];

model = svmtrain(trn_data.y, trn_data.X, optparam.libsvm);

%Mean square error
 
% MSE for test samples
[y_hat, Acc, projection] = svmpredict(tst_data.y, tst_data.X, model);
MSE_Test = mean((y_hat-tst_data.y).^2);
NRMS_Test = sqrt(MSE_Test) / std(tst_data.y);

% MSE for training samples
[y_hat, Acc, projection] = svmpredict(trn_data.y, trn_data.X, model);
MSE_Train = mean((y_hat-trn_data.y).^2);
NRMS_Train = sqrt(MSE_Train) / std(trn_data.y);

%Plot the model
 
X = 0:0.01:1;
X = X';
y = ones(length(X), 1);
y_est = svmpredict(y, X, model);

h = plot(trn_data.X, trn_data.y, 'ko', tst_data.X, tst_data.y, 'kx', X, y_est, 'r--');

legend('Training', 'Test', 'Model');
y1 = max([trn_data.y; tst_data.y]);
y2 = min([trn_data.y; tst_data.y]);
axis([0 1 y2 y1]);

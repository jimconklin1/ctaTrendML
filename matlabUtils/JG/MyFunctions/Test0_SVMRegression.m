% Initializations
%clear all;close all;clear classes;
% Build the OnlineSVR
SVR = OnlineSVR;
% Set Parameters
SVR = set(SVR, 'C', 10, ...
                'Epsilon', 0.1, ...
                'KernelType', 'GaussianRBF', ...
                'KernelParam', 30, ...
                'AutoErrorTollerance', true, ...
                'Verbosity', 0, ...
                'StabilizedLearning', true, ...
                'ShowPlots', true, ...
                'MakeVideo', false, ...
                'VideoTitle', '');
% Build Training set
data_train=data(1:200);
TrainingSetY = data_train;%sin(TrainingSetX*pi*2);
TrainingSetX = (1:1:length(data_train))';%rand(20,1);

% Training
SVR = Train(SVR, TrainingSetX,TrainingSetY);
% Show Info
ShowInfo (SVR);
% Predict some values
%TestSetX = (1:1:length(data)-200)'; %[0; 1];
%TestSetY = data(201:length(data));sin(TestSetX*pi*2);
%PredictedY = Predict(SVR, TestSetX);
%Errors = Margin(SVR, TestSetX,TestSetY);
%disp(' ');
%disp('Some results:');
%disp(['f(0)=' num2str(PredictedY(1)) ' y(0)=' num2str(TestSetY(1)) 'margin=' num2str(Errors(1))]);
%disp(['f(1)=' num2str(PredictedY(2)) ' y(1)=' num2str(TestSetY(2)) 'margin=' num2str(Errors(2))]);
%disp(' ');
% Forget first 4 samples
SVR = Forget(SVR, 1:4);
% Build plot
BuildPlot(SVR);
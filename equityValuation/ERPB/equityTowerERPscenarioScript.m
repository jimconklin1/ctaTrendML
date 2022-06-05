load 'M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\TAAscenarios\ERPscenarios_june2021.mat';
%load 'M:\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\TAAscenarios\ERPscenarios.mat';
% "Projected data", or projData:
% kk: forward period index, i.e., 0.25, 0.5, ... 1.75 ... etc. if quarterly
%     data, 1, 2, 3, ... if annual
% r:  forward-forward real risk free rates, annual units (i.e., from period k-1 to period k)
% pi: forward-forward expected inflation rate (i.e., from period k-1 to period k)
% g:  forward-forward real growth rate (i.e., from period k-1 to period k)

% base scenario
projData0 = projData;
K = size(projData,2);
cf0 = 46; % value requried to match ERP of 5 march 2021
[~,erp0,pxKthPer0] = calcERPscenarios(px0,cf0,projData0,[],'annual');
%test
[px00,~,pxKthPer00] = calcERPscenarios([],cf0,projData0,erp0,'annual');

% 20-yr real rate: 
addpath C:\GIT\utils_ml\_data; yy = calcCum(projData0(2,1:20)',1); yy=yy(end)^(1/20)-1; disp(yy) 
% 20-yr expected inflation: 
yy = calcCum(projData0(3,1:20)',1); yy=yy(end)^(1/20)-1; disp(yy) 
% 20-year avg expected pay-out growth:
yy = mean(projData0(3,1:20)+projData0(4,1:20)); disp(yy) 


% inflation rise scenario
temp = projData(3,:).*[1.1, 1.2, 1.35, 1.5, 1.65, 1.8, 2, 1.9, 1.8, 1.7, 1.6, 1.5, 1.45, 1.4, 1.35, 1.3, 1.25, 1.2, 1.15, 1.1*ones(1,K-19)];  
projData1 = [projData(1,:); projData(2,:); temp; projData(4,:)]; 
[px1,~,pxKthPer1] = calcERPscenarios([],cf0,projData1,erp0,'annual');
% plot([temp', projData(3,:)'])
% 20-yr real rate: 
yy = calcCum(projData1(2,1:20)',1); yy=yy(end)^(1/20)-1; disp(yy) 
% 20-yr expected inflation: 
yy = calcCum(projData1(3,1:20)',1); yy=yy(end)^(1/20)-1; disp(yy) 
% 20-year avg expected pay-out growth:
yy = mean(projData1(3,1:20)+projData1(4,1:20)); disp(yy) 



% real rate rise scenario
temp = projData(2,:)+[0, 0, 1.2, 1.5, 1.8, 1.9, 1.8, 1.7, 1.6, 1.5, 1.4, 1.3, 1.2, 1.1, 1.0, 0.9, 0.8, 0.7, 0.6*ones(1,K-18)]/100;
projData2 = [projData(1,:);  temp; projData(3,:); projData(4,:)]; 
[px2,~,pxKthPer2] = calcERPscenarios([],cf0,projData2,erp0,'annual');
% plot([temp', projData(2,:)'])
% 20-yr real rate: 
yy = calcCum(projData2(2,1:20)',1); yy=yy(end)^(1/20)-1; disp(yy) 
% 20-yr expected inflation: 
yy = calcCum(projData2(3,1:20)',1); yy=yy(end)^(1/20)-1; disp(yy) 
% 20-year avg expected pay-out growth:
yy = mean(projData2(3,1:20)+projData1(4,1:20)); disp(yy) 

% Japanification scenario
temp1 = projData(2,:).*+[0.3, 0.5, 0.8, 1.0, 1.2, 1.4, 1.5, 1.5, 1.5, 1.5, 1.4, 1.3, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2*ones(1,K-18)]/100; % real rates rise
temp2 = projData(3,:).*[0.9, 0.8, 0.7, 0.65, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6*ones(1,K-10)]; % inflation falls
temp3 = projData(4,:).*[0.9, 0.8, 0.7, 0.7, 0.7, 0.7, 0.75, 0.8, 0.8, 0.8, 0.8*ones(1,K-10)]; % growth falls
projData3 = [projData(1,:); temp1; temp2; temp3]; 
[px3,~,pxKthPer3] = calcERPscenarios([],cf0,projData3,erp0,'annual');
plot([temp1', projData(2,:)'])
plot([temp2', projData(3,:)'])
plot([temp3', projData(4,:)'])

% 20-yr real rate: 
yy = calcCum(projData3(2,1:20)',1); yy=yy(end)^(1/20)-1; disp(yy) 
% 20-yr expected inflation: 
yy = calcCum(projData3(3,1:20)',1); yy=yy(end)^(1/20)-1; disp(yy) 
% 20-year avg expected pay-out growth:
yy = mean(projData3(3,1:20)+projData1(4,1:20)); disp(yy) 

% Growth stocks vs. value stocks
cf4 = 41.5;
temp4 = 1.25*projData(4,:);
projData4 = [projData(1:3,:); temp4];
[px4,~,pxKthPer4] = calcERPscenarios([],cf4,projData4,erp0,'annual');

cf5 = 60;
temp5 = 0.8*projData(4,:);
projData5 = [projData(1:3,:); temp5];
[px5,~,pxKthPer5] = calcERPscenarios([],cf5,projData5,erp0,'annual');


disp()
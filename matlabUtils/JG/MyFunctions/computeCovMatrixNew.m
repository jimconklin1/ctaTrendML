function [covMat, stdevMat] = computeCovMatrixNew(sampleReturn, histWindow, halfLife)

[covExp, stdevExp] = computeExpCov(sampleReturn, histWindow , halfLife);
covMat = covExp;
stdevMat = stdevExp;        
covMat = covMat .* 12;
stdevMat = stdevMat .* (12^0.5);
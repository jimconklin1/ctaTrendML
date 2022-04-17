function [ signal ] = squashTstat(tstats, fParam)
%SQUASHTSTAT Summary of this function goes here
%   Detailed explanation goes here 
a  = fParam.squashLevelTstat(1);
b = fParam.squashLevelTstat(2);
s0 = fParam.squashLevelSignal;
signal = nan (size (tstats)); 
indexZero= (-a < tstats &  tstats < a );
indxPos = (a <= tstats &  tstats < b ); 
indxNeg = (-b < tstats &  tstats <= -a); 
signal (indxPos) = (((1-s0)/(b-a)) * (tstats (indxPos)-b))+1; 
signal (indexZero)= 0 ; 
signal ( tstats >=b ) =1 ; 
signal ( tstats<=-b ) = - 1; 
signal(indxNeg) = (((-1+s0)/(a-b)) * (tstats(indxNeg)+b))-1; 
end


function[macs,macsf,macss] = MACSFibo(x,method,PS1,PS2)
%
%__________________________________________________________________________
%
% This function computes the "Moving Average Confluence indicator" in 
% comparing several couple of exponential moving averages.
%
% INPUT....................................................................
% X                   = matirx of prices ('n' observations x 'p' assets)
% 'method'            = several combinations of Fibonacci MA are possible.
% PS1                 = fast period in order to smooth macs.
% PS2                 = slow period in order to smooth macs.
% OUTPUT...................................................................
% macs = moving average confluence.
% macsf & macss = smoothed moving average confluence.
% 
%__________________________________________________________________________
%
% -- Identify Dimensions --
[nsteps,ncols]=size(x); macs=zeros(size(x)); 
%Diff_ma_cube=zeros(nsteps,ncols,30);
%
% -- Compute increment for MACS --
Increment=1;%100/(MaxLookbackPeriod-MinLookbackPeriod+1);
%
% -- Different Sets of Fibonacci MA-couples are possible --
%
% .. note: the 1st column is the length for the fast MA, the 2nd, the
%          length for the slow MA.
%
% .. Set 2 - Fibo MA 2-steps away ..
FiboSet2=   [  3    ,  8;
               5    , 13;
               8    , 21;
              13    , 34;
              21    , 55;
              34    , 89;
              55    , 144;
              89    , 233;
             144    , 377];
% .. Set 20 -  Fibo MA 2-steps away, first 3 "fast" MA-couples stripped .. 
FiboSet20=  [ 13    , 34;
              21    , 55;
              34    , 89;
              55    , 144;
              89    , 233;
             144    , 377];
% .. Set 21 -  Fibo MA 2-steps away, first 4 "fast" MA-couples stripped ..         
FiboSet21=  [ 21    , 55;
              34    , 89;
              55    , 144;
              89    , 233;
             144    , 377];     
% .. Set 3 - Fibo MA 3-steps away ..         
FiboSet3=   [  3    , 13;
               5	, 21;
               8	, 34;
              13	, 55;
              21	, 89;
              34	, 144;
              55	, 233;
              89	, 377];  
% .. Set 30 - Fibo MA 3-steps away, first 3 "fast" MA-couples stripped ..         
FiboSet30=  [ 13	, 55;
              21	, 89;
              34	, 144;
              55	, 233;
              89	, 377];  
% .. Set 31 - Fibo MA 3-steps away, first 4 "fast" MA-couples stripped .. 
FiboSet31=  [ 21	, 89;
              34	, 144;
              55	, 233;
              89	, 377];   
% .. Set 4 - Fibo MA 4-steps away ..              
FiboSet4=   [  3	, 21;
               5	, 34;
               8	, 55;
              13	, 89;
              21	, 144;
              34	, 233;
              55	, 377]; 
% .. Set 40 - Fibo MA 4-steps away, first 3 "fast" MA-couples stripped ..      
FiboSet40=  [ 13	, 89;
              21	, 144;
              34	, 233;
              55	, 377]; 
% .. Set 41 - Fibo MA 4-steps away, first 4 "fast" MA-couples stripped ..             
FiboSet41=  [ 21	, 144;
              34	, 233;
              55	, 377];           
% .. Set 5 - Fibo MA 5-steps away ..           
FiboSet5=   [  3	, 34;
               5	, 55;
               8	, 89;
              13	, 144;
              21	, 233;
              34	, 377];  
% .. Set 50 - Fibo MA 5-steps away, first 3 "fast" MA-couples stripped ..            
FiboSet50=  [ 13	, 144;
              21	, 233;
              34	, 377];  
% .. Set 51 - Fibo MA 5-steps away, first 4 "fast" MA-couples stripped ..             
FiboSet51=  [ 21	, 233;
              34	, 377];   
% .. Set 5 - Fibo MA 5-steps away ..           
FiboSet6=   [  13	, 34;
               21	, 34;
               19	, 39;
              13	, 55;
              21	, 55;
              34	, 55
              21    , 89
              34    , 89
              25    , 100
              50    , 100
              25    , 125
              55    , 144
              21    , 233
              55    , 233];           
%        
% -- Option for Fibonnacci --    
% .. note: several combinations possible of the above sets
switch method
    case  {'1', 'model 1', 'Model 1', 'model1', 'Model1', 'option 1', 'Option 1', ...
            'combination 1', 'Combination 1', 'combination1', 'Combination1','comb 1', 'Comb 1', 'comb1', 'Comb1'}
        FiboSet=[FiboSet2 ; FiboSet3 ; FiboSet4 ; FiboSet5];
    case  {'2', 'model 2', 'Model 2', 'model2', 'Model2', 'option 2', 'Option 2', ...
            'combination 2', 'Combination 2', 'combination2', 'Combination2','comb 2', 'Comb 2', 'comb2', 'Comb2'}   
        FiboSet=[FiboSet2 ; FiboSet3 ; FiboSet4];
    % Combination 3: Prefered combination for stocks (so far..)
    case  {'3', 'model 3', 'Model 3', 'model3', 'Model3', 'option 3', 'Option 3', ...
            'combination 3', 'Combination 3', 'combination3', 'Combination3','comb 3', 'Comb 3', 'comb3', 'Comb3'}    
        FiboSet=[FiboSet21 ; FiboSet31 ; FiboSet41 ; FiboSet51];  
    case  {'4', 'model 4', 'Model 4', 'model4', 'Model4', 'option 4', 'Option 4', ...
            'combination 4', 'Combination 4', 'combination4', 'Combination4','comb 4', 'Comb 4', 'comb4', 'Comb4'}      
        FiboSet=[FiboSet20 ; FiboSet30 ; FiboSet40 ; FiboSet50 ];   
    %case  {'5', 'model 5', 'Model 5', 'model5', 'Model5', 'option 5', 'Option 5', ...
    %        'combination 5', 'Combination 5', 'combination5', 'Combination5','comb 5', 'Comb 5', 'comb5', 'Comb5'}   
    %    FiboSet=[FiboSet20 ; FiboSet30 ; FiboSet40 ; FiboSet50]; 
    case {'6'}
        FiboSet=FiboSet6;
end
LengthFiboSet=size(FiboSet,1); % Nb of MA couples in the set
%
% -- Pre-locate Cube (MA-couples) dimensions --
Diff_ma_cube=zeros(nsteps,ncols,LengthFiboSet);
%
% -- Compute Set of differences in a Cube --
for uu=1:LengthFiboSet
    % Difference between Fast MA and Slow MA
    ma_f=expmav(x,FiboSet(uu,1)); ma_s=expmav(x,FiboSet(uu,2));
    Diff_ma=ma_f-ma_s;
    clear ma_f ma_s
    % Identify difference (normalise @ 5 for percentage)
    Diff_ma(find(Diff_ma <= 0)) = -Increment;
    Diff_ma(find(Diff_ma >  0)) = +Increment;  
    % Assign to cube
    Diff_ma_cube(:,:,uu)=Diff_ma(:,:);
    % Clear
    clear Diff_ma
end
%
% -- Compute Moving Average Concluence Indicator from the Cube --
for j=1:ncols
    MyStock=Diff_ma_cube(:,j,:);
    macsStock=zeros(nsteps,1);
    for i=1:nsteps
        macsStock(i,1)= sum(MyStock(i,:));
    end
    macs(:,j)=100*macsStock(:,1)/LengthFiboSet;
end
%
% -- Smooth Moving Average Concluence Indicator --
macsf=expmav(macs,PS1);macss=expmav(macs,PS2);
%
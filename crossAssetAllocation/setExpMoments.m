function o = setExpMoments(riskType)
% inputs:
% riskType = 'intrinsic', 'accounting'

% Params used for L&R, April 2021:
F = [[ 0.0630 	 0.1671 ];
     [ 0.0132 	 0.0682 ];
     [ 0.0383 	 0.0668 ];
     [ 0.0328 	 0.0671 ]];

factorERset = F(:,1)'; % annual units here
factorVolSet =F(:,2)';

% %       Acctng   Intrnsc
% Ar = [[ 0.0676 	 0.0676 ]; % Pub Equities
%       [ 0.0874 	 0.0869 ]; % PE
%       [ 0.1061 	 0.1091 ]; % DE
%       [ 0.0893 	 0.0831 ]; % GRE
%       [ 0.0813 	 0.0745 ]; % F&T
%       [ 0.0761	 0.0761 ]; % AbsRtn
%       [ 0.0300	 0.0300 ]];% HFBeta
% 
% Av = [[ 0.1671 	 0.1671 ]; % Pub Equities
%       [ 0.1014 	 0.1737  ]; % PE
%       [ 0.1273 	 0.2037 ]; % DE
%       [ 0.0969 	 0.1185 ]; % GRE
%       [ 0.0570	 0.1018 ]; % F&T
%       [ 0.0624 	 0.0624 ]; % special HF addition case
%       [ 0.0689 	 0.0689 ]];

% Yield Curve Inversion case:
%       Acctng   Intrnsc
Ar = [[ 0.0094 	 0.0094 ]; % Pub Equities
      [ 0.1095 	 0.0567 ]; % PE
      [ 0.1214 	 0.0620 ]; % DE
      [ 0.0943 	 0.0524 ]; % GRE
      [ 0.0864 	 0.0728 ]; % F&T
      [ 0.0767	 0.0767 ]; % AbsRtn
      [ 0.0091	 0.0091 ]];% HFBeta

Av = [[ 0.1671 	 0.1671 ]; % Pub Equities
      [ 0.1014 	 0.1737  ]; % PE
      [ 0.1273 	 0.2037 ]; % DE
      [ 0.0969 	 0.1185 ]; % GRE
      [ 0.0570	 0.1018 ]; % F&T
      [ 0.0624 	 0.0624 ]; % special HF addition case
      [ 0.0689 	 0.0689 ]];
Av = 1.2*Av;  
  
switch riskType
    case 'Accounting'
        erSet = Ar(:,1)';
        volSet = Av(:,1)';
    case 'Intrinsic'
        erSet = Ar(:,2)';
        volSet = Av(:,2)';
end

o.factorERset = factorERset;
o.factorVolSet = factorVolSet;
o.erSet = erSet;
o.volSet = volSet;
end

%Extract a subset of asset data
    % from M:\PublicEquityQuant\AssetAllocation\SAA_analysis\VALIC_retirementCarveOut\VALICretirementCarveOut_v2.xlsx
    % E[rtn]            Accounting	Intrinsic
    % 'GlobalEquity'	0.0645      0.0645 
    % 'PvtEqBO'         0.0995      0.1005 
    % 'DirEqty'         0.1300      0.1300 
    % 'PvtEqRE'         0.0800      0.0800 
    % 'PvtEqFT'         0.0635      0.0595 
    % 'AbsRtn2'         0.065       0.065  

    % 'GlobalEquity'	0.1700      0.1700 
    % 'PvtEqBO'         0.1292      0.2066 
    % 'DirEqty'         0.1600      0.2250 
    % 'PvtEqRE'         0.0750      0.1530 
    % 'PvtEqFT'         0.1000      0.1400 
    % 'AbsRtn2'         0.0600      0.0600 

    % FACTORS:          E[rtn]      E[vol]
    % Equity            0.0645      0.1700 
    % Rates             0.0200      0.0722 
    % Credit            0.0197      0.0664 
    % Mtg               0.0176      0.0668 

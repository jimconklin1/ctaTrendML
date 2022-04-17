%
%__________________________________________________________________________
%
% Matfile format for global rates
%
%
%__________________________________________________________________________


clear all
clc
%format double
%
ConBbg = bloomberg;%(8194,'10.50.100.120') % too many connections, dun why, just need bloomberg and ok
StartDate = '1/1/1980'; % Start date
%
% -- Enter Today Date --
EndDate = '9/01/2014';
%
% Gold
com_gc1 = GetBbgHist(ConBbg, 'GC1 Comdty', StartDate, EndDate);
save com_gc1
com_gc2 = GetBbgHist(ConBbg, 'GC2 Comdty', StartDate, EndDate);
save com_gc2
cur_xau = GetBbgHist(ConBbg, 'XAU Curncy', StartDate, EndDate);
save cur_xau
% Silver
com_si1 = GetBbgHist(ConBbg, 'SI1 Comdty', StartDate, EndDate);
save com_si1
com_si2 = GetBbgHist(ConBbg, 'SI2 Comdty', StartDate, EndDate);
save com_si2
cur_xag = GetBbgHist(ConBbg, 'XAG Curncy', StartDate, EndDate);
save cur_xag
% Palladium
com_pa1 = GetBbgHist(ConBbg, 'PA1 Comdty', StartDate, EndDate);
save com_pa1
com_pa2 = GetBbgHist(ConBbg, 'PA2 Comdty', StartDate, EndDate);
save com_pa2
cur_xpa = GetBbgHist(ConBbg, 'XPA Curncy', StartDate, EndDate);
save cur_xpa
% Platinium
com_pl1 = GetBbgHist(ConBbg, 'PL1 Comdty', StartDate, EndDate);
save com_pl1
com_pl2 = GetBbgHist(ConBbg, 'PL2 Comdty', StartDate, EndDate);
save com_pl2
cur_xpt = GetBbgHist(ConBbg, 'XPT Comdty', StartDate, EndDate);
save cur_xpt
% Copper
com_hg1 = GetBbgHist(ConBbg, 'HG1 Comdty', StartDate, EndDate);
save com_hg1
com_hg2 = GetBbgHist(ConBbg, 'HG2 Comdty', StartDate, EndDate);
save com_hg2
% Aluminium
com_la1 = GetBbgHist(ConBbg, 'LA1 Comdty', StartDate, EndDate);
save com_la1
com_la2 = GetBbgHist(ConBbg, 'LA2 Comdty', StartDate, EndDate);
save com_la2
% Nickel
com_ln1 = GetBbgHist(ConBbg, 'LN1 Comdty', StartDate, EndDate);
save com_ln1
com_ln2 = GetBbgHist(ConBbg, 'LN2 Comdty', StartDate, EndDate);
save com_ln2
% Crude Oil
com_cl1 = GetBbgHist(ConBbg, 'CL1 Comdty', StartDate, EndDate);
save com_cl1
com_cl2 = GetBbgHist(ConBbg, 'CL2 Comdty', StartDate, EndDate);
save com_cl2
% Brent
com_co1 = GetBbgHist(ConBbg, 'CO1 Comdty', StartDate, EndDate);
save com_co1
com_co2 = GetBbgHist(ConBbg, 'CO2 Comdty', StartDate, EndDate);
save com_co2
% Heating Oil
com_ho1 = GetBbgHist(ConBbg, 'HO1 Comdty', StartDate, EndDate);
save com_ho1
com_ho2 = GetBbgHist(ConBbg, 'HO2 Comdty', StartDate, EndDate);
save com_ho2
% Gasoil
com_qs1 = GetBbgHist(ConBbg, 'QS1 Comdty', StartDate, EndDate);
save com_qs1
com_qs2 = GetBbgHist(ConBbg, 'QS2 Comdty', StartDate, EndDate);
save com_qs2
% RBOB Gasoline
com_xb1 = GetBbgHist(ConBbg, 'XB1 Comdty', StartDate, EndDate);
save com_xb1
com_xb2 = GetBbgHist(ConBbg, 'XB2 Comdty', StartDate, EndDate);
save com_xb2
% Natural gas
com_ng1 = GetBbgHist(ConBbg, 'NG1 Comdty', StartDate, EndDate);
save com_ng1
com_ng2 = GetBbgHist(ConBbg, 'NG2 Comdty', StartDate, EndDate);
save com_ng2
% Soybeans
com_s1 = GetBbgHist(ConBbg, 'S 1 Comdty', StartDate, EndDate);
save com_s1
com_s2 = GetBbgHist(ConBbg, 'S 2 Comdty', StartDate, EndDate);
save com_s2
% Corn
com_c1 = GetBbgHist(ConBbg, 'C 1 Comdty', StartDate, EndDate);
save com_c1
com_c2 = GetBbgHist(ConBbg, 'C 2 Comdty', StartDate, EndDate);
save com_c2
% Coffee
com_kc1 = GetBbgHist(ConBbg, 'KC1 Comdty', StartDate, EndDate);
save com_kc1
com_kc2 = GetBbgHist(ConBbg, 'KC2 Comdty', StartDate, EndDate);
save com_kc1
% Wheat
com_w1 = GetBbgHist(ConBbg, 'W 1 Comdty', StartDate, EndDate);
save com_w1
com_w2 = GetBbgHist(ConBbg, 'W 2 Comdty', StartDate, EndDate);
save com_w2

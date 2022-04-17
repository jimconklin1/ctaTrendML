%
%__________________________________________________________________________
%
% Matfile format for global rates
% note: this database is only used to built proff of the ocncept
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
EndDate = '9/10/2014';
%
% Dowload Bloomberg History

% United States
us_10y = GetBbgHistRates(ConBbg, 'USSW10 Curncy', StartDate, EndDate);           save us_10y
us_9y = GetBbgHistRates(ConBbg, 'USSW9 Curncy', StartDate, EndDate);             save us_9y
us_index = GetBbgHistRates(ConBbg, 'US0003M Index', StartDate, EndDate);         save us_index
us_2y = GetBbgHistRates(ConBbg, 'USSW2 Curncy', StartDate, EndDate);             save us_2y
us_1y = GetBbgHistRates(ConBbg, 'USSW1 Curncy', StartDate, EndDate);             save us_1y
us_5y = GetBbgHistRates(ConBbg, 'USSW5 Curncy', StartDate, EndDate);             save us_5y
us_4y = GetBbgHistRates(ConBbg, 'USSW2 Curncy', StartDate, EndDate);             save us_4y
us_1y1y = GetBbgHistRates(ConBbg, 'USSW1 Curncy', StartDate, EndDate);           save us_1y1y
% Canada
ca_10y = GetBbgHistRates(ConBbg, 'CDSW10 Curncy', StartDate, EndDate);           save ca_10y
ca_9y = GetBbgHistRates(ConBbg, 'CDSW9 Curncy', StartDate, EndDate);             save ca_9y
ca_index = GetBbgHistRates(ConBbg, 'CDOR03 Index', StartDate, EndDate);          save ca_index
ca_2y = GetBbgHistRates(ConBbg, 'CDSW2 Curncy', StartDate, EndDate);             save ca_2y
ca_1y = GetBbgHistRates(ConBbg, 'CDSW1 Curncy', StartDate, EndDate);             save ca_1y
ca_5y = GetBbgHistRates(ConBbg, 'CDSW5 Curncy', StartDate, EndDate);             save ca_5y
ca_4y = GetBbgHistRates(ConBbg, 'CDSW4 Curncy', StartDate, EndDate);             save ca_4y
ca_1y1y = GetBbgHistRates(ConBbg, 'CDSW1 Curncy', StartDate, EndDate);           save ca_1y1y
% Eurozone
eu_10y = GetBbgHistRates(ConBbg, 'EUSA10 Curncy', StartDate, EndDate);           save eu_10y
eu_9yf = GetBbgHistRates(ConBbg, 'EUSA9 Curncy', StartDate, EndDate);            save eu_9y
eu_index = GetBbgHistRates(ConBbg, 'EUR006M Index', StartDate, EndDate);         save eu_index
eu_2y = GetBbgHistRates(ConBbg, 'EUSA2 Curncy', StartDate, EndDate);             save eu_2y
eu_1y = GetBbgHistRates(ConBbg, 'EUSA1 Curncy', StartDate, EndDate);             save eu_1y
eu_5y = GetBbgHistRates(ConBbg, 'EUSA2 Curncy', StartDate, EndDate);             save eu_5y
eu_4y = GetBbgHistRates(ConBbg, 'EUSA1 Curncy', StartDate, EndDate);             save eu_4y
eu_1y1y = GetBbgHistRates(ConBbg, 'EUSA1 Curncy', StartDate, EndDate);           save eu_1y1y
% Great Britain
gb_10y = GetBbgHistRates(ConBbg, 'BPSW10 Curncy', StartDate, EndDate);           save gb_10y
gb_9y = GetBbgHistRates(ConBbg, 'BPSW9 Curncy', StartDate, EndDate);             save gb_9y
gb_index = GetBbgHistRates(ConBbg, 'BP0006M Index', StartDate, EndDate);         save gb_index
gb_2y = GetBbgHistRates(ConBbg, 'BPSW2 Curncy', StartDate, EndDate);             save gb_2y
gb_1y = GetBbgHistRates(ConBbg, 'BPSW1 Curncy', StartDate, EndDate);             save gb_1y
gb_5y = GetBbgHistRates(ConBbg, 'BPSW5 Curncy', StartDate, EndDate);             save gb_5y
gb_4y = GetBbgHistRates(ConBbg, 'BPSW4 Curncy', StartDate, EndDate);             save gb_4y
gb_1y1y = GetBbgHistRates(ConBbg, 'BPSW1 Curncy', StartDate, EndDate);           save gb_1y1y
% Switzerland
ch_10y = GetBbgHistRates(ConBbg, 'SFSW10 Curncy', StartDate, EndDate);           save ch_10y
ch_9y = GetBbgHistRates(ConBbg, 'SFSW9 Curncy', StartDate, EndDate);             save ch_9y
ch_index = GetBbgHistRates(ConBbg, 'SF0006M Index', StartDate, EndDate);         save ch_index
ch_1y1y = GetBbgHistRates(ConBbg, 'SFSW9 Curncy', StartDate, EndDate);           save ch_1y1y
% Sweden
sw_10y = GetBbgHistRates(ConBbg, 'SKSW10 Curncy', StartDate, EndDate);           save sw_10y
sw_9y= GetBbgHistRates(ConBbg, 'SKSW9 Curncy', StartDate, EndDate);              save sw_9y
sw_index = GetBbgHistRates(ConBbg, 'STIB3M Index', StartDate, EndDate);          save sw_index
sw_1y1y = GetBbgHistRates(ConBbg, 'SKSW9 Curncy', StartDate, EndDate);           save sw_1y1y
% Norway
nw_10y = GetBbgHistRates(ConBbg, 'NKSW10 Curncy', StartDate, EndDate);           save nw_10y
nw_9y = GetBbgHistRates(ConBbg, 'NKSW9 Curncy', StartDate, EndDate);             save nw_9y
nw_index = GetBbgHistRates(ConBbg, 'NIBOR6M Index', StartDate, EndDate);         save nw_index
% Australia
au_10y = GetBbgHistRates(ConBbg, 'ADSWAP10 CMPN Curncy', StartDate, EndDate);    save au_10y
au_9y = GetBbgHistRates(ConBbg, 'ADSWAP9 CMPN Curncy', StartDate, EndDate);      save au_9y
au_index = GetBbgHistRates(ConBbg, 'ADBB4M Index', StartDate, EndDate);          save au_index
au_2y = GetBbgHistRates(ConBbg, 'ADSWAP2 CMPN Curncy', StartDate, EndDate);      save au_2y
au_1y = GetBbgHistRates(ConBbg, 'ADSWAP1 CMPN Curncy', StartDate, EndDate);      save au_1y
au_5y = GetBbgHistRates(ConBbg, 'ADSWAP5 CMPN Curncy', StartDate, EndDate);      save au_5y
au_4y = GetBbgHistRates(ConBbg, 'ADSWAP4 CMPN Curncy', StartDate, EndDate);      save au_4y
au_1y1y = GetBbgHistRates(ConBbg, 'ADSWAP1 CMPN Curncy', StartDate, EndDate);    save au_1y1y
% New-Zealand
nz_10y = GetBbgHistRates(ConBbg, 'NDSWAP10 CMPN Curncy', StartDate, EndDate);    save nz_10y
nz_9y = GetBbgHistRates(ConBbg, 'NDSWAP9 CMPN Curncy', StartDate, EndDate);      save nz_9y
nz_index = GetBbgHistRates(ConBbg, 'NDBB3M Index', StartDate, EndDate);          save nz_index
nz_2y = GetBbgHistRates(ConBbg, 'NDSWAP2 CMPN Curncy', StartDate, EndDate);      save nz_2y
nz_1y = GetBbgHistRates(ConBbg, 'NDSWAP1 CMPN Curncy', StartDate, EndDate);      save nz_1y
nz_5y = GetBbgHistRates(ConBbg, 'NDSWAP5 CMPN Curncy', StartDate, EndDate);      save nz_4y
nz_4y = GetBbgHistRates(ConBbg, 'NDSWAP4 CMPN Curncy', StartDate, EndDate);      save nz_4y
nz_1y1y = GetBbgHistRates(ConBbg, 'NDSWAP1 CMPN Curncy', StartDate, EndDate);      save nz_1y1y
% Japan
jp_10y = GetBbgHistRates(ConBbg, 'JYSW10 Curncy', StartDate, EndDate);           save jp_10y
jp_9y = GetBbgHistRates(ConBbg, 'JYSW9 Curncy', StartDate, EndDate);             save jp_9y
jp_index = GetBbgHistRates(ConBbg, 'JY0006M Index', StartDate, EndDate);         save jp_index
jp_2y = GetBbgHistRates(ConBbg, 'JYSW2 Curncy', StartDate, EndDate);             save jp_2y
jp_1y = GetBbgHistRates(ConBbg, 'JYSW1 Curncy', StartDate, EndDate);             save jp_1y
jp_5y = GetBbgHistRates(ConBbg, 'JYSW5 Curncy', StartDate, EndDate);             save jp_5y
jp_4y = GetBbgHistRates(ConBbg, 'JYSW4 Curncy', StartDate, EndDate);             save jp_4y
jp_1y1y = GetBbgHistRates(ConBbg, 'JYSW1 Curncy', StartDate, EndDate);           save jp_1y1y
% Poland
po_5y = GetBbgHistRates(ConBbg, 'PZSW5 Curncy', StartDate, EndDate);             save po_5y
po_4y = GetBbgHistRates(ConBbg, 'PZSW4 Curncy', StartDate, EndDate);             save po_4y
po_index = GetBbgHistRates(ConBbg, 'WIBR6M Index', StartDate, EndDate);          save po_index
% Chezk Republic
cz_5y = GetBbgHistRates(ConBbg, 'CKSW5 Curncy', StartDate, EndDate);             save cz_5y
cz_4y = GetBbgHistRates(ConBbg, 'CKSW4 Curncy', StartDate, EndDate);             save cz_4y
cz_index = GetBbgHistRates(ConBbg, 'PRIB06M Index', StartDate, EndDate);         save cz_index
% Hungary
hu_5y = GetBbgHistRates(ConBbg, 'HFSW5 Curncy', StartDate, EndDate);             save hu_5y
hu_4y = GetBbgHistRates(ConBbg, 'HFSW4 Curncy', StartDate, EndDate);             save hu_4y
hu_index = GetBbgHistRates(ConBbg, 'BUBOR06M Index', StartDate, EndDate);        save hu_index
% Israel
is_5y = GetBbgHistRates(ConBbg, 'ISSW5 Curncy', StartDate, EndDate);             save is_5y
is_4y = GetBbgHistRates(ConBbg, 'ISSW4 Curncy', StartDate, EndDate);             save is_4y
is_index = GetBbgHistRates(ConBbg, 'TELBOR03 Index', StartDate, EndDate);        save is_index
% South Korea
ko_5y = GetBbgHistRates(ConBbg, 'KWSWO5 CMPN Curncy', StartDate, EndDate);       save ko_5y
ko_4y = GetBbgHistRates(ConBbg, 'KWSWO4 CMPN Curncy', StartDate, EndDate);       save ko_4y
ko_index = GetBbgHistRates(ConBbg, 'KWCDC Index', StartDate, EndDate);           save ko_index
ko_1y = GetBbgHistRates(ConBbg, 'KWSWO4 CMPN Curncy', StartDate, EndDate);       save ko_1y
ko_1y1y = GetBbgHistRates(ConBbg, 'KWSWO4 CMPN Curncy', StartDate, EndDate);       save ko_1y1y
% Mexico
mx_10y = GetBbgHistRates(ConBbg, 'MPSW10 Curncy', StartDate, EndDate);           save mx_10y
mx_9y = GetBbgHistRates(ConBbg, 'MPSW9 Curncy', StartDate, EndDate);             save mx_9y 
mx_5y = GetBbgHistRates(ConBbg, 'MPSW5 Curncy', StartDate, EndDate);             save mx_5y
mx_4y = GetBbgHistRates(ConBbg, 'MPSW4 Curncy', StartDate, EndDate);             save mx_4y 
mx_index = GetBbgHistRates(ConBbg, 'MXIBTIIE Index', StartDate, EndDate);        save mx_index
% India
in_5y = GetBbgHistRates(ConBbg, 'IRSWM5 CMPN Curncy', StartDate, EndDate);       save in_5y
in_4y = GetBbgHistRates(ConBbg, 'IRSWM4 CMPN Curncy', StartDate, EndDate);       save in_1yrbef
in_index = GetBbgHistRates(ConBbg, 'MIFORIM6 Index', StartDate, EndDate);        save in_index
% Malaysia
ma_5y = GetBbgHistRates(ConBbg, 'MRSWQO5 CMPN Curncy', StartDate, EndDate);      save ma_5y
ma_4y= GetBbgHistRates(ConBbg, 'MRSWQO4 CMPN Curncy', StartDate, EndDate);       save ma_4y
ma_index = GetBbgHistRates(ConBbg, 'KLIB3M Index', StartDate, EndDate);          save ma_index
% Singapore
sg_5y = GetBbgHistRates(ConBbg, 'SDSW5 CMPN Curncy', StartDate, EndDate);        save sg_5y
sg_4y = GetBbgHistRates(ConBbg, 'SDSW4 CMPN Curncy', StartDate, EndDate);        save sg4y
sg_index = GetBbgHistRates(ConBbg, 'SORF6M Index', StartDate, EndDate);          save sg_index
sg_1y1y = GetBbgHistRates(ConBbg, 'SDSW4 CMPN Curncy', StartDate, EndDate);      save sg1y1y
% Turkey
tu_5y = GetBbgHistRates(ConBbg, 'TYUSSW5 Curncy', StartDate, EndDate);           save tu_5y
tu_4y = GetBbgHistRates(ConBbg, 'TYUSSW4 Curncy', StartDate, EndDate);           save tu_4y 
tu_index = GetBbgHistRates(ConBbg, 'US0003M Index', StartDate, EndDate);         save tu_index
% South-Africa
saf_5y = GetBbgHistRates(ConBbg, 'SASW5 Curncy', StartDate, EndDate);            save saf_5y
saf_4y = GetBbgHistRates(ConBbg, 'SASW4 Curncy', StartDate, EndDate);            save saf_4y
isaf_index = GetBbgHistRates(ConBbg, 'JIBA3M Index', StartDate, EndDate);        save saf_index
saf_1y1y = GetBbgHistRates(ConBbg, 'SASW4 Curncy', StartDate, EndDate);          save saf_1y1y
% Brasil
br_5y = GetBbgHistRates(ConBbg, 'BCSWNPD Curncy', StartDate, EndDate);           save br_5y
br_4y = GetBbgHistRates(ConBbg, 'BCSWMPD Curncy', StartDate, EndDate);           save br_4y
br_index = GetBbgHistRates(ConBbg, 'BZDIOVRA Index', StartDate, EndDate);        save br_index
% Taiwan
tw_5y = GetBbgHistRates(ConBbg, 'NTSWO5 CMPN Curncy', StartDate, EndDate);       save tw_5y
tw_4y = GetBbgHistRates(ConBbg, 'NTSWO4 CMPN Curncy', StartDate, EndDate);       save tw_4y
tw_index = GetBbgHistRates(ConBbg, 'TDSF90D Index', StartDate, EndDate);         save tw_index
% Thailand
th_5y = GetBbgHistRates(ConBbg, 'TBSWO5 CMPN Curncy', StartDate, EndDate);       save th_5y
th_4y = GetBbgHistRates(ConBbg, 'TBSWO4 CMPN Curncy', StartDate, EndDate);       save th_4y
th_index = GetBbgHistRates(ConBbg, 'THFX6 Index', StartDate, EndDate);           save th_index






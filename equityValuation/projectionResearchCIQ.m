%data = readtable('\\pnamfsdg02.investments.aig.net\Group03\Manager of Managers\Public Equity\strategy_LongOnly\ERPB\SPX\DATA\Data.csv');
data = readtable('Data.csv');
data.PAYOUT = data.DVD_SH_12M - data.CF_DECR_CAP_STOCK - data.CF_INCR_CAP_STOCK;
data.IQ_PAYOUT = data.IQ_DIV_SHARE - data.CF_DECR_CAP_STOCK - data.CF_INCR_CAP_STOCK;
data.IQ_ROC = data.IQ_RETURN_CAPITAL;
data.IQ_ROC(end-8:end) = data.IQ_ROC(end-8:end) / (1 - 0.35 - 0.025) * (1 - 0.21 - 0.025);

mdl53 = fitlm(data.IQ_EBITDA, data.IQ_PAYOUT); % R-squared: 0.755, dw: 2.1936e-06, Intercept: -16.548
mdl74 = fitlm(data.IQ_OPER_INC, data.IQ_PAYOUT); % R-squared: R-squared: 0.732
mdl89 = fitlm(data.IQ_EARNING_CO, data.IQ_PAYOUT); % R-squared: 0.725
mdl90 = fitlm(data.IQ_NI, data.IQ_PAYOUT); % R-squared: 0.735
mdl91 = fitlm(data.IQ_EBIT, data.IQ_PAYOUT); % R-squared: 0.676
mdl92 = fitlm(data.IQ_TOTAL_DEBT_CAPITAL, data.IQ_PAYOUT); % R-squared: 0.436

mdl54 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1)], data.IQ_PAYOUT(2:end)); % R-squared: 0.764, dw: 1.0297
mdl202 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), zz], data.IQ_PAYOUT(2:end))
mdl55 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_EARNING_CO(2:end), data.IQ_EARNING_CO(1:end-1)], data.IQ_PAYOUT(2:end)); % R-squared: 0.854

mdl56 = fitlm([data.IQ_EBITDA, data.IQ_ROC, data.IQ_EARNING_CO], data.IQ_PAYOUT); % R-squared: 0.863, dw: 1.8143e-08

mdl57 = fitlm(data.IQ_EBITDA, data.IQ_PAYOUT, 'quadratic'); % y ~ 1 + x1 + x1^2, R-squared: 0.766
mdl58 = fitlm([data.IQ_EBITDA, data.IQ_CF_SHARE], data.IQ_PAYOUT); % R-squared: 0.752, dw: 1.1768

mdl59 = fitlm(data.IQ_EBITDA, data.IQ_PAYOUT, 'Intercept', false); % y ~ x1, R-Squared: 0.3278
mdl60 = fitlm([data.IQ_EBITDA, data.IQ_CF_SHARE], data.IQ_PAYOUT, 'Intercept', false); % y ~ x1 + x2, R-squared: 0.3446
mdl104 = fitlm([data.IQ_EBITDA, data.IQ_CF_SHARE, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.7608, dw: 0.0048
mdl107 = fitlm([data.IQ_EBITDA, data.IQ_CF_SHARE, data.IQ_ROC], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.7187, dw: 2.8611e-04
mdl108 = fitlm([data.IQ_NI, data.IQ_CF_SHARE, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.7647
mdl109 = fitlm([data.IQ_BASIC_EPS_EXCL, data.IQ_CF_SHARE, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.7667
mdl110 = fitlm([data.IQ_BASIC_EPS_EXCL, data.IQ_CASH_EQUIV, data.IQ_CF_SHARE, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.8218
mdl111 = fitlm([data.IQ_BASIC_EPS_EXCL, data.IQ_CASH_EQUIV, data.IQ_CF_SHARE, data.IQ_RETURN_ASSETS], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.8256
mdl112 = fitlm([data.IQ_BASIC_EPS_EXCL, data.IQ_CASH_EQUIV, data.IQ_CF_SHARE, data.IQ_RETURN_EQUITY], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.8250
mdl113 = fitlm([data.IQ_EBITDA, data.IQ_CASH_EQUIV, data.IQ_CF_SHARE, data.IQ_RETURN_ASSETS], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.7381
mdl114 = fitlm([data.IQ_EBIT, data.IQ_CASH_EQUIV, data.IQ_CF_SHARE, data.IQ_RETURN_ASSETS], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.7173
mdl115 = fitlm([data.IQ_NI, data.IQ_CASH_EQUIV, data.IQ_CF_SHARE, data.IQ_RETURN_ASSETS], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.8180
mdl116 = fitlm([data.IQ_BASIC_EPS_EXCL, data.IQ_TOTAL_DEBT, data.IQ_CAPEX, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.8837, dw: 1.5212

mdl105 = fitlm([data.IQ_EBITDA(1:end-1), data.IQ_CF_SHARE(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.6565, dw: 0.0012
mdl106 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_CF_SHARE(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.7993, dw: 0.0171
mdl117 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end), data.IQ_TOTAL_DEBT(1:end-1),...
    data.IQ_CAPEX(2:end), data.IQ_CAPEX(1:end-1), data.IQ_RETURN_CAPITAL(2:end), data.IQ_RETURN_CAPITAL(1:end-1)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8939, dw: 0.0952
mdl118 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end), data.IQ_TOTAL_DEBT(1:end-1),...
    data.IQ_CAPEX(2:end), data.IQ_CAPEX(1:end-1), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8929, dw: 0.1109
mdl119 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end), data.IQ_TOTAL_DEBT(1:end-1),...
    data.IQ_CAPEX(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8923, dw: 0.1311

mdl201 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_RETURN_EQUITY(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false)

mdl120 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end),...
    data.IQ_CAPEX(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8921, dw: 1.7547
mdl153 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end),...
    data.IQ_CAPEX(2:end), data.IQ_RETURN_EQUITY(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8281, dw: 7.5297e-04
mdl154 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end),...
    data.IQ_CAPEX(2:end), data.IQ_RETURN_ASSETS(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8823, dw: 0.0147
mdl155 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_BV_SHARE(2:end),...
    data.IQ_CASH_OPER(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.7891, dw: 0.0112
mdl147 = fitlm([data.IQ_DILUT_EPS_EXCL(2:end), data.IQ_DILUT_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end),...
    data.IQ_CAPEX(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8916, dw: 0.1625

mdl140 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_CL(2:end),...
    data.IQ_CAPEX(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8859, dw: 0.0128
mdl128 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end),...
    data.IQ_CAPEX(2:end), data.IQ_ROC(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8796, dw: 0.0600
mdl121 = fitlm([data.IQ_BASIC_EPS_EXCL(3:end), data.IQ_BASIC_EPS_EXCL(2:end-1), data.IQ_BASIC_EPS_EXCL(1:end-2), data.IQ_TOTAL_DEBT(3:end),...
    data.IQ_CAPEX(3:end), data.IQ_RETURN_CAPITAL(3:end)], data.IQ_PAYOUT(3:end), 'Intercept', false); % R-squared: 0.9008, dw: 0.1469
mdl129 = fitlm([data.IQ_BASIC_EPS_EXCL(4:end), data.IQ_BASIC_EPS_EXCL(3:end-1), data.IQ_BASIC_EPS_EXCL(2:end-2), data.IQ_BASIC_EPS_EXCL(1:end-3), data.IQ_TOTAL_DEBT(4:end),...
    data.IQ_CAPEX(4:end), data.IQ_RETURN_CAPITAL(4:end)], data.IQ_PAYOUT(4:end), 'Intercept', false); % R-squared: 0.8994, dw: 0.1606
mdl130 = fitlm([data.IQ_BASIC_EPS_EXCL(4:end), data.IQ_BASIC_EPS_EXCL(3:end-1), data.IQ_BASIC_EPS_EXCL(2:end-2), data.IQ_BASIC_EPS_EXCL(1:end-3), data.IQ_TOTAL_DEBT(4:end),...
    data.IQ_RETURN_CAPITAL(4:end)], data.IQ_PAYOUT(4:end), 'Intercept', false); % R-squared: 0.8990, dw: 0.1844
mdl131 = fitlm([data.IQ_BASIC_EPS_EXCL(5:end), data.IQ_BASIC_EPS_EXCL(4:end-1), data.IQ_BASIC_EPS_EXCL(3:end-2), data.IQ_BASIC_EPS_EXCL(2:end-3), data.IQ_BASIC_EPS_EXCL(1:end-4),...
    data.IQ_TOTAL_DEBT(5:end), data.IQ_RETURN_CAPITAL(5:end)], data.IQ_PAYOUT(5:end), 'Intercept', false); % R-squared: 0.9023, dw: 0.2037
mdl132 = fitlm([data.IQ_BASIC_EPS_EXCL(6:end), data.IQ_BASIC_EPS_EXCL(5:end-1), data.IQ_BASIC_EPS_EXCL(4:end-2), data.IQ_BASIC_EPS_EXCL(3:end-3), data.IQ_BASIC_EPS_EXCL(2:end-4),...
     data.IQ_BASIC_EPS_EXCL(1:end-5), data.IQ_TOTAL_DEBT(6:end), data.IQ_RETURN_CAPITAL(6:end)], data.IQ_PAYOUT(6:end), 'Intercept', false); % R-squared: 0.9019, dw: 0.1818
mdl133 = fitlm([data.IQ_BASIC_EPS_EXCL(5:end), data.IQ_BASIC_EPS_EXCL(4:end-1), data.IQ_BASIC_EPS_EXCL(3:end-2), data.IQ_BASIC_EPS_EXCL(2:end-3),...
    data.IQ_TOTAL_DEBT(5:end), data.IQ_RETURN_CAPITAL(5:end)], data.IQ_PAYOUT(5:end), 'Intercept', false); % R-squared: 0.8973, dw: 0.1725
mdl136 = fitlm([data.IQ_BASIC_EPS_EXCL(5:end), data.IQ_BASIC_EPS_EXCL(4:end-1), data.IQ_BASIC_EPS_EXCL(3:end-2), data.IQ_BASIC_EPS_EXCL(1:end-4),...
    data.IQ_TOTAL_DEBT(5:end), data.IQ_RETURN_CAPITAL(5:end)], data.IQ_PAYOUT(5:end), 'Intercept', false); % R-squared: 0.9022, dw: 0.1785

mdl134 = fitlm([data.IQ_BASIC_EPS_EXCL(6:end), data.IQ_BASIC_EPS_EXCL(5:end-1), data.IQ_BASIC_EPS_EXCL(4:end-2), data.IQ_BASIC_EPS_EXCL(3:end-3), data.IQ_BASIC_EPS_EXCL(1:end-5),...
    data.IQ_TOTAL_DEBT(6:end), data.IQ_RETURN_CAPITAL(6:end)], data.IQ_PAYOUT(6:end), 'Intercept', false); % R-squared: 0.8995, dw: 0.2095
mdl149 = fitlm([data.IQ_BASIC_EPS_EXCL(7:end), data.IQ_BASIC_EPS_EXCL(6:end-1), data.IQ_BASIC_EPS_EXCL(5:end-2), data.IQ_BASIC_EPS_EXCL(4:end-3), data.IQ_BASIC_EPS_EXCL(2:end-5), data.IQ_BASIC_EPS_EXCL(1:end-6),...
    data.IQ_TOTAL_DEBT(7:end), data.IQ_RETURN_CAPITAL(7:end)], data.IQ_PAYOUT(7:end), 'Intercept', false); % R-squared: 0.9028, dw: 0.3005
mdl159 = fitlm([data.IQ_BASIC_EPS_EXCL(7:end), data.IQ_BASIC_EPS_EXCL(6:end-1), data.IQ_BASIC_EPS_EXCL(5:end-2), data.IQ_BASIC_EPS_EXCL(4:end-3), data.IQ_BASIC_EPS_EXCL(2:end-5), data.IQ_BASIC_EPS_EXCL(1:end-6),...
    data.IQ_TOTAL_DEBT(7:end), data.IQ_RETURN_CAPITAL(7:end)], data.IQ_PAYOUT(7:end)); % R-squared: 0.903, dw: 0.3153
mdl156 = fitlm([data.IQ_BASIC_EPS_EXCL(7:end), data.IQ_BASIC_EPS_EXCL(6:end-1), data.IQ_BASIC_EPS_EXCL(5:end-2), data.IQ_BASIC_EPS_EXCL(4:end-3), data.IQ_BASIC_EPS_EXCL(2:end-5), data.IQ_BASIC_EPS_EXCL(1:end-6),...
    data.IQ_RETURN_CAPITAL(7:end)], data.IQ_PAYOUT(7:end), 'Intercept', false); % R-squared: 0.8775, dw: 0.0069
mdl157 = fitlm([data.IQ_BASIC_EPS_EXCL(7:end), data.IQ_BASIC_EPS_EXCL(6:end-1), data.IQ_BASIC_EPS_EXCL(5:end-2), data.IQ_BASIC_EPS_EXCL(4:end-3), data.IQ_BASIC_EPS_EXCL(2:end-5), data.IQ_BASIC_EPS_EXCL(1:end-6),...
    data.IQ_TOTAL_DEBT(6:end-1), data.IQ_RETURN_CAPITAL(7:end)], data.IQ_PAYOUT(7:end), 'Intercept', false); % R-squared: 0.9008, dw: 0.0530
mdl158 = fitlm([data.IQ_BASIC_EPS_EXCL(7:end), data.IQ_BASIC_EPS_EXCL(6:end-1), data.IQ_BASIC_EPS_EXCL(5:end-2), data.IQ_BASIC_EPS_EXCL(4:end-3), data.IQ_BASIC_EPS_EXCL(2:end-5), data.IQ_BASIC_EPS_EXCL(1:end-6),...
    data.IQ_TOTAL_DEBT(6:end-1), data.IQ_RETURN_CAPITAL(6:end-1)], data.IQ_PAYOUT(7:end), 'Intercept', false); % R-squared: 0.8946, dw: 0.0216
mdl150 = fitlm([data.IQ_BASIC_EPS_EXCL(7:end), data.IQ_BASIC_EPS_EXCL(6:end-1), data.IQ_BASIC_EPS_EXCL(5:end-2), data.IQ_BASIC_EPS_EXCL(4:end-3), data.IQ_BASIC_EPS_EXCL(3:end-4), data.IQ_BASIC_EPS_EXCL(2:end-5), data.IQ_BASIC_EPS_EXCL(1:end-6),...
    data.IQ_TOTAL_DEBT(7:end), data.IQ_RETURN_CAPITAL(7:end)], data.IQ_PAYOUT(7:end), 'Intercept', false); % R-squared: 0.9046, dw: 0.2891
mdl151 = fitlm([data.IQ_BASIC_EPS_EXCL(7:end), data.IQ_BASIC_EPS_EXCL(6:end-1), data.IQ_BASIC_EPS_EXCL(5:end-2), data.IQ_BASIC_EPS_EXCL(3:end-4), data.IQ_BASIC_EPS_EXCL(2:end-5), data.IQ_BASIC_EPS_EXCL(1:end-6),...
    data.IQ_TOTAL_DEBT(7:end), data.IQ_RETURN_CAPITAL(7:end)], data.IQ_PAYOUT(7:end), 'Intercept', false); % R-squared: 0.9045, dw: 0.2629
mdl152 = fitlm([data.IQ_BASIC_EPS_EXCL(7:end), data.IQ_BASIC_EPS_EXCL(6:end-1), data.IQ_BASIC_EPS_EXCL(5:end-2), data.IQ_BASIC_EPS_EXCL(2:end-5), data.IQ_BASIC_EPS_EXCL(1:end-6),...
    data.IQ_TOTAL_DEBT(7:end), data.IQ_RETURN_CAPITAL(7:end)], data.IQ_PAYOUT(7:end), 'Intercept', false); % R-squared: 0.9028, dw: 0.2921

mdl148 = fitlm([data.IQ_DILUT_EPS_EXCL(6:end), data.IQ_DILUT_EPS_EXCL(5:end-1), data.IQ_DILUT_EPS_EXCL(4:end-2), data.IQ_DILUT_EPS_EXCL(3:end-3), data.IQ_DILUT_EPS_EXCL(1:end-5),...
    data.IQ_TOTAL_DEBT(6:end), data.IQ_RETURN_CAPITAL(6:end)], data.IQ_PAYOUT(6:end), 'Intercept', false); % R-squared: 0.8990, dw: 0.1994
mdl135 = fitlm([data.IQ_BASIC_EPS_EXCL(6:end), data.IQ_BASIC_EPS_EXCL(5:end-1), data.IQ_BASIC_EPS_EXCL(4:end-2), data.IQ_BASIC_EPS_EXCL(2:end-4), data.IQ_BASIC_EPS_EXCL(1:end-5),...
    data.IQ_TOTAL_DEBT(6:end), data.IQ_RETURN_CAPITAL(6:end)], data.IQ_PAYOUT(6:end), 'Intercept', false); % R-squared: 0.9018, dw: 0.1600

mdl122 = fitlm([data.IQ_BASIC_EPS_EXCL(3:end), data.IQ_BASIC_EPS_EXCL(2:end-1), data.IQ_BASIC_EPS_EXCL(1:end-2), data.IQ_TOTAL_DEBT(3:end),...
    data.IQ_RETURN_CAPITAL(3:end)], data.IQ_PAYOUT(3:end), 'Intercept', false); % R-squared: 0.9002, dw: 0.1580
mdl123 = fitlm([data.IQ_BASIC_EPS_EXCL(3:end), data.IQ_BASIC_EPS_EXCL(1:end-2), data.IQ_TOTAL_DEBT(3:end),...
    data.IQ_CAPEX(3:end), data.IQ_RETURN_CAPITAL(3:end)], data.IQ_PAYOUT(3:end), 'Intercept', false); % R-squared: 0.8972, dw:  0.0961
mdl124 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_CASH_EQUIV(2:end),...
    data.IQ_CAPEX(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8572, dw: 1.9339e-04
mdl125 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end),...
    data.IQ_CF_SHARE(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8885, dw: 0.1461
mdl126 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end),...
    data.IQ_CASH_OPER(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8890, dw: 0.1348

mdl127 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_DEBT(2:end),...
    data.IQ_CAPEX(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8903, dw: 0.2418

mdl61 = fitlm(data.IQ_EBITDA, data.IQ_PAYOUT, 'RobustOpts', 'on'); % R-squared: 0.847, dw: 31.3678e-06, Intercerpt: -14.537
mdl62 = fitlm(data.IQ_EBITDA, data.IQ_PAYOUT, 'RobustOpts', 'on', 'Intercept', false); % R-squared:  0.4210
mdl63 = fitlm([data.IQ_EBITDA, data.IQ_CF_SHARE], data.IQ_PAYOUT, 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.4310

mdl93 = fitlm(data.IQ_EBITDA, buyback); % RR-squared: 0.556
mdl94 = fitlm(data.IQ_OPER_INC, buyback); % R-squared: 0.584
mdl95 = fitlm(data.IQ_EARNING_CO, buyback); % R-squared: 0.706
mdl96 = fitlm(data.IQ_ROC, buyback); % R-squared: 0.156
mdl97 = fitlm([data.IQ_EARNING_CO, data.IQ_ROC], buyback); % R-squared: 0.719, dw:  9.4162e-07
mdl98 = fitlm([data.IQ_EBITDA, data.IQ_ROC, data.IQ_EARNING_CO], buyback); % R-squared: 0.776
mdl99 = fitlm([data.IQ_EARNING_CO, data.IQ_ROC, data.IQ_OPER_INC], buyback); % R-squared: 0.725
mdl100 = fitlm([data.IQ_EARNING_CO, data.IQ_ROC, data.IQ_EBITDA], buyback); % R-squared: 0.776
mdl101 = fitlm([data.IQ_EARNING_CO(2:end), data.IQ_EARNING_CO(1:end-1), data.IQ_ROC(2:end), data.IQ_ROC(1:end-1)], buyback(2:end)); % R-squared: 0.751

mdl64 = fitlm(data.IQ_EBITDA, data.IQ_DIV_SHARE); % R-squared: 0.916
mdl75 = fitlm(data.IQ_OPER_INC, data.IQ_DIV_SHARE); % R-squared: 0.784
mdl80 = fitlm(data.IQ_EARNING_CO, data.IQ_DIV_SHARE); % R-squared: 0.511
mdl81 = fitlm(data.IQ_ROC, data.IQ_DIV_SHARE); % R-squared: 0.153
mdl65 = fitlm([data.IQ_EBITDA, data.IQ_ROC], data.IQ_DIV_SHARE); % R-squared: 0.944, dwtest: 1.4411e-16
mdl66 = fitlm([data.IQ_EBITDA, data.IQ_ROC, data.IQ_EARNING_CO], data.IQ_DIV_SHARE); % R-squared: 0.947, dwtest: 2.1124e-15
mdl76 = fitlm([data.IQ_EBITDA, data.IQ_ROC, data.IQ_OPER_INC], data.IQ_DIV_SHARE); % R-squared: 0.95
mdl77 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_OPER_INC(2:end), data.IQ_OPER_INC(1:end-1)], data.IQ_DIV_SHARE(2:end)); % R-squared: 0.951
mdl102 = fitlm([data.IQ_EBITDA(1:end-1), data.IQ_ROC(1:end-1)], data.IQ_DIV_SHARE(2:end)); % R-squared: 0.955, dw: 6.3674e-15
mdl103 = fitlm([data.IQ_EARNING_CO(1:end-1), data.IQ_ROC(1:end-1)], data.IQ_DIV_SHARE(2:end)); % R-squared: 0.626

mdl67 = fitlm(data.IQ_EBITDA, data.IQ_DIV_SHARE, 'Intercept', false); % R-squared: 0.6676
mdl68 = fitlm([data.IQ_EBITDA, data.IQ_ROC], data.IQ_DIV_SHARE, 'Intercept', false); % R-squared: 0.9423
mdl78 = fitlm([data.IQ_EBITDA, data.IQ_OPER_INC], data.IQ_DIV_SHARE, 'Intercept', false); % R-squared: 0.6652
mdl69 = fitlm([data.IQ_EBITDA, data.IQ_ROC, data.IQ_EARNING_CO], data.IQ_DIV_SHARE, 'Intercept', false); % R-squared: 0.9436
mdl79 = fitlm([data.IQ_EBITDA, data.IQ_ROC, data.IQ_OPER_INC], data.IQ_DIV_SHARE, 'Intercept', false); % R-squared: 0.9452
mdl70 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_EARNING_CO(2:end), data.IQ_EARNING_CO(1:end-1)], data.IQ_DIV_SHARE(2:end), 'Intercept', false); % R-squared: 0.7521
mdl71 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_ROC(2:end), data.IQ_ROC(1:end-1), data.IQ_EARNING_CO(2:end), data.IQ_EARNING_CO(1:end-1)], data.IQ_DIV_SHARE(2:end), 'Intercept', false); % R-squared: 0.9572, dw: 7.1696e-24
mdl72 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_ROC(2:end), data.IQ_ROC(1:end-1)], data.IQ_DIV_SHARE(2:end), 'Intercept', false); % R-squared: 0.9561
mdl73 = fitlm([data.IQ_EBITDA(3:end), data.IQ_EBITDA(2:end-1), data.IQ_EBITDA(1:end-2), data.IQ_ROC(3:end), data.IQ_ROC(2:end-1), data.IQ_ROC(1:end-2)], data.IQ_DIV_SHARE(3:end), 'Intercept', false); % R-squared: 0.9649, dw: 1.2261e-23

autocorr(data.IQ_PAYOUT);
autocorr(data.IQ_DIV_SHARE);

figure;
yyaxis left;
plot(data.DATE, data.IQ_DIV_SHARE, 'LineWidth', 1);
yyaxis right;
plot(data.DATE, data.IQ_ROC, 'LineWidth', 1);

mdl137 = fitlm([data.IQ_BASIC_EPS_EXCL, data.IQ_TOTAL_CL, data.IQ_CF_SHARE, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.8789, dw: 0.0013
mdl138 = fitlm([data.IQ_BASIC_EPS_EXCL, data.IQ_TOTAL_CL, data.IQ_CASH_OPER, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.8787, dw: 8.0049e-04
mdl139 = fitlm([data.IQ_BASIC_EPS_EXCL(2:end), data.IQ_BASIC_EPS_EXCL(1:end-1), data.IQ_TOTAL_CL(2:end),...
    data.IQ_CF_SHARE(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.8863, dw: 0.0283

mdl141 = fitlm([data.IQ_EBITDA, data.IQ_CASH_EQUIV, data.IQ_CASH_OPER, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.7792, dw: 0.0159
mdl142 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_CASH_EQUIV(2:end), data.IQ_CASH_OPER(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.7890, dw: 0.0101
mdl143 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_CASH_OPER(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.7890, dw: 0.0127
mdl144 = fitlm([data.IQ_EBITDA(5:end), data.IQ_EBITDA(4:end-1), data.IQ_EBITDA(3:end-2), data.IQ_EBITDA(2:end-3), data.IQ_EBITDA(1:end-4), ...
    data.IQ_CASH_OPER(5:end), data.IQ_RETURN_CAPITAL(5:end)], data.IQ_PAYOUT(5:end), 'Intercept', false); % R-squared: 0.7954, dw: 0.0200

mdl145 = fitlm([data.IQ_EBITDA, data.IQ_BV_SHARE, data.IQ_CASH_OPER, data.IQ_RETURN_CAPITAL], data.IQ_PAYOUT, 'Intercept', false); % R-squared: 0.7816, dw: 0.0192
mdl146 = fitlm([data.IQ_EBITDA(2:end), data.IQ_EBITDA(1:end-1), data.IQ_BV_SHARE(2:end), data.IQ_CASH_OPER(2:end), data.IQ_RETURN_CAPITAL(2:end)], data.IQ_PAYOUT(2:end), 'Intercept', false); % R-squared: 0.7891, dw: 0.0112
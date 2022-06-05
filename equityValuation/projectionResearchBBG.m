c = blp;
bbgData = history(c, {'SPX Index'}, {'PX_LAST', 'DVD_SH_12M', ...
    'CF_DECR_CAP_STOCK', 'CF_INCR_CAP_STOCK', ...
    'EBITDA', 'FREE_CASH_FLOW_PER_SH', 'RETURN_ON_CAP', 'CAPITAL_EXPEND', ...
    'CASH_FLOW_PER_SH', 'PE_RATIO', 'TRAIL_12M_EPS', 'FREE_CASH_FLOW_YIELD', ...
    'BS_CUR_LIAB', 'SHORT_AND_LONG_TERM_DEBT', 'BS_TOT_LIAB2'},...
    '01/01/1997', '03/31/2020', 'quarterly', 'USD', 'overridefields', {'FUND_PER', 'Q'});

dividend = bbgData(:, 3);
buyback = -1 * bbgData(:, 4) - bbgData(:, 5);
payout = dividend + buyback;
ebitda = bbgData(:, 6);
freeCF = bbgData(:, 7);
roc = bbgData(:, 8);
capex = bbgData(:, 9);
cashflow = bbgData(:, 10);
pe = bbgData(:, 11);
eps = bbgData(:, 12);
fcfy = bbgData(:, 13);
debt1 = bbgData(:, 14);
debt2 = bbgData(:, 15);
debt3 = bbgData(:, 16);

corr = corrcoef([dividend, buyback, payout, bbgData(:, 6:13)]);

bbgDataY = getBbgData('01/01/1991', '03/31/2020', 'yearly', 'Y'); % 30 years
dividendY = bbgDataY(:, 3);
buybackY = -1* bbgDataY(:, 4) - bbgDataY(:, 5);
payoutY = dividendY + buybackY;
ebitdaY = bbgDataY(:, 6);
freeCFY = bbgDataY(:, 7);
rocY = bbgDataY(:, 8);
capexY = bbgDataY(:, 9);

mdl1 = fitlm(ebitda, payout); % R-squared: 0.738, dw: 1.3851e-06, Intercept: -18.747
mdl88 = fitlm(eps, payout); % R-squared: 0.854

mdl14 = fitlm([ebitda(2:end), ebitda(1:end-1)], payout(2:end)); % R-squared: 0.751, dw: 4.2297e-06
mdl34 = fitlm([ebitda(2:end), ebitda(1:end-1)], payout(2:end) - 0.8 * payout(1:end-1)); % R-squared: 0.206
mdl35 = fitlm([ebitda(3:end), ebitda(2:end-1), ebitda(1:end-2)], payout(3:end)); % R-squared: 0.756, dw: 1.4012e-07
mdl36 = fitlm([ebitda(4:end), ebitda(3:end-1), ebitda(2:end-2), ebitda(1:end-3)], payout(4:end)); % R-squared: 0.757, dw: 2.0771e-07
mdl41 = fitlm([ebitda(4:end), ebitda(3:end-1), ebitda(2:end-2), ebitda(1:end-3), eps(4:end)], payout(4:end)); % R-squared: 0.865, dw: 4.2312e-05
mdl42 = fitlm([ebitda(4:end), ebitda(3:end-1), ebitda(2:end-2), ebitda(1:end-3), eps(4:end), eps(3:end-1)], payout(4:end)); % R-squared: 0.866, dwtst: 1.5080e-04
mdl44 = fitlm([ebitda(3:end), ebitda(2:end-1), ebitda(1:end-2), eps(3:end), eps(2:end-1)], payout(3:end)); % R-squared: 0.864
mdl46 = fitlm([ebitda(2:end), ebitda(1:end-1), eps(2:end), eps(1:end-1)], payout(2:end)); % R-squared: 0.859

mdl8 = fitlm([ebitda, freeCF], payout); % R-squared: 0.738, dw: 1.0701e-06
mdl27 = fitlm([ebitda, freeCF, roc], payout); % R-squared: 0.76, dw: 5.6290e-07
mdl28 = fitlm([ebitda, freeCF, roc, capex], payout); % R-squared: 0.774
mdl29 = fitlm([ebitda, roc, capex], payout); % R-squared: 0.773
mdl30 = fitlm([ebitda, capex], payout); % R-squared: 0.757
mdl31 = fitlm([ebitda, capex, cashflow], payout); % R-squared: 0.758
mdl32 = fitlm([ebitda, capex, cashflow, pe], payout); % R-squared: 0.76
mdl33 = fitlm([ebitda, capex, pe], payout); % R-squared: 0.759
mdl38 = fitlm([ebitda, capex, pe, eps], payout); % R-squared: 0.86
mdl39 = fitlm([ebitda, capex, eps], payout); % R-squared: 0.855
mdl40 = fitlm([ebitda, eps], payout); % R-squared: 0.854, dw: 5.8929e-05
mdl83 = fitlm([ebitda, roc, pe, fcfy], payout); % R-squared: 0.764
mdl84 = fitlm([ebitda, roc, fcfy], payout); % R-squared: 0.764
mdl85 = fitlm([ebitda, fcfy], payout); % R-squared: 0.743
mdl86 = fitlm([ebitda, roc], payout); % R-squared: 0.761
mdl87 = fitlm([ebitda, roc, eps], payout); % R-squared: 0.855

mdl51 = fitlm([ebitda, roc, eps], payout); % R-squared: 0.855, dw: 3.4153e-05
mdl2 = fitlm(ebitda, payout, 'linear'); % Same result
mdl4 = fitlm(ebitda, payout, 'interactions'); % Same result
mdl5 = fitlm(ebitda, payout, 'purequadratic'); % y ~ 1 + x1 + x1^2, R-squared: 0.739, dw: 2.0511e-07
mdl6 = fitlm(ebitda, payout, 'quadratic'); % y ~ 1 + x1 + x1^2, R-squared: 0.739, dw: 2.0511e-07
mdl10 = fitlm([ebitda, freeCF], payout, 'quadratic'); % R-squared: 0.744
mdl11 = fitlm([ebitda, freeCF], payout, 'quadratic', 'Intercept', false); % R-squared: 0.706

mdl7 = fitlm(ebitda, payout, 'Intercept', false); % y ~ x1, R-Squared: 0.269
mdl9 = fitlm([ebitda, freeCF], payout, 'Intercept', false); % y ~ x1 + x2, R-squared: 0.319
mdl43 = fitlm([ebitda(4:end), ebitda(3:end-1), ebitda(2:end-2), ebitda(1:end-3), eps(4:end), eps(3:end-1)], payout(4:end), 'Intercept', false); % R-squared: 0.8377
mdl48 = fitlm([ebitda(2:end), ebitda(1:end-1), eps(2:end), eps(1:end-1)], payout(2:end), 'Intercept', false); % R-squared: 0.8325, dw: 2.0905e-04
mdl188 = fitlm([eps(2:end), eps(1:end-1), debt1(2:end), capex(2:end), roc(2:end)], payout(2:end), 'Intercept', false); % R-squared: 0.8290, dw: 0.0015
mdl189 = fitlm([eps(2:end), eps(1:end-1), debt2(2:end), capex(2:end), roc(2:end)], payout(2:end), 'Intercept', false); % R-squared: 0.8325, dw: 0.0010
mdl190 = fitlm([eps(2:end), eps(1:end-1), debt3(2:end), capex(2:end), roc(2:end)], payout(2:end), 'Intercept', false); % R-squared: 0.8400, dw: 0.0032

mdl3 = fitlm(ebitda, payout, 'RobustOpts', 'on'); % R-squared: 0.834, dw: 3.3059e-07, Intercerpt: -16.839
mdl12 = fitlm(ebitda, payout, 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.305
mdl15 = fitlm([ebitda(2:end), ebitda(1:end-1)], payout(2:end),  'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.365
mdl13 = fitlm([ebitda, freeCF], payout, 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.426
mdl16 = fitlm([ebitda(2:end), ebitda(1:end-1), freeCF(2:end)], payout(2:end), 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.472
mdl17 = fitlm([ebitda(4:end), ebitda(3:end-1), ebitda(2:end-2), ebitda(1:end-3), freeCF(4:end)], payout(4:end), 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.465
mdl18 = fitlm([ebitda(3:end), ebitda(2:end-1), ebitda(1:end-2), freeCF(3:end)], payout(3:end), 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.4697
mdl19 = fitlm([ebitda(2:end), ebitda(1:end-1), freeCF(2:end), freeCF(1:end-1)], payout(2:end), 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.4758
mdl45 = fitlm([ebitda(3:end), ebitda(2:end-1), ebitda(1:end-2), eps(3:end), eps(2:end-1)], payout(3:end), 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.8661
mdl47 = fitlm([ebitda(2:end), ebitda(1:end-1), eps(2:end), eps(1:end-1)], payout(2:end), 'RobustOpts', 'on', 'Intercept', false); % R-squared: 0.8857

mdl20 = fitlm(ebitdaY, payoutY); % R-squared: 0.82, dw: 12.4876e-08, Intercept: -50.162
mdl22 = fitlm([ebitdaY, freeCFY], payoutY); % R-squared: 0.826, dw: 1.2596e-07
mdl21 = fitlm(ebitdaY, payoutY, 'Intercept', false); % R-Squared: 0.4119

mdl23 = fitlm(ebitda, dividend); % R-squared: 0.703
mdl25 = fitlm([ebitda, roc], dividend); % R-squared: 0.706
mdl26 = fitlm([ebitda, capex], dividend); % R-squared: 0.808
mdl52 = fitlm([ebitda, roc, eps], dividend); % R-squared: 0.823

mdl24 = fitlm(ebitda, dividend, 'Intercept', false); % R-squared: 0.4336
mdl37 = fitlm([ebitda, roc], dividend, 'Intercept', false); % R-squared: 0.4435
mdl50 = fitlm([ebitda, roc, eps], dividend, 'Intercept', false); % R-squared: 0.8248

mdl49 = fitlm([ebitda(2:end), ebitda(1:end-1), eps(2:end), eps(1:end-1)], buyback(2:end), 'Intercept', false); % R-squared: 0.6821

autocorr(payout);
autocorr(dividend);
autocorr(buyback);
autocorr(payoutY);
autocorr(dividendY);
autocorr(buybackY);

autocorr(payout(2 : end) - 0.8 * payout(1 : end-1));
autocorr(buybackY(3 : end) - 0.7 * buybackY(2 : end-1) - 0.4 * buybackY(1:end-2));
autocorr(payoutY(3 : end) - 0.8 * payoutY(2 : end-1) - 0.5 * payoutY(1:end-2));
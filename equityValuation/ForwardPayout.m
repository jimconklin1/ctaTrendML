function ForwardPayout()

% CIQ data
data = readtable('Data.csv');

% Stage One
divMdl1 = fitlm(data.IQ_DIV_SHARE(1:end-1), data.IQ_DIV_SHARE(2:end));
fprintf('DIV(t) vs DIV(t-1) R-squared: %.3f\n', divMdl1.Rsquared.Ordinary);
[~, DW1] = dwtest(divMdl1);
fprintf('DIV(t) vs DIV(t-1) D-W stat: %.3f\n', DW1);
plot(divMdl1);
plotResiduals(divMdl1);

% YY
yy = divMdl1.Coefficients.Estimate(1) + divMdl1.Residuals.Raw;

% Comparing regressors
divTestMdl1 = fitlm(data.IQ_EBITDA(2:end), yy);
fprintf('YY vs EBITDA R-squared: %.3f\n', divTestMdl1.Rsquared.Ordinary);
[~, DWTest1] = dwtest(divTestMdl1);
fprintf('YY vs EBITDA D-W stat: %.3f\n', DWTest1);

divTestMdl2 = fitlm(data.IQ_EBIT(2:end), yy);
fprintf('YY vs EBIT R-squared: %.3f\n', divTestMdl2.Rsquared.Ordinary);
[~, DWTest2] = dwtest(divTestMdl2);
fprintf('YY vs EBIT D-W stat: %.3f\n', DWTest2);

divTestMdl3 = fitlm(data.IQ_TOTAL_REV(2:end), yy);
fprintf('YY vs REVENUE R-squared: %.3f\n', divTestMdl3.Rsquared.Ordinary);
[~, DWTest3] = dwtest(divTestMdl3);
fprintf('YY vs REVENUE D-W stat: %.3f\n', DWTest3);

divTestMdl4 = fitlm(data.IQ_CF_SHARE(2:end), yy);
fprintf('YY vs CFPS R-squared: %.3f\n', divTestMdl4.Rsquared.Ordinary);
[~, DWTest4] = dwtest(divTestMdl4);
fprintf('YY vs CFPS D-W stat: %.3f\n', DWTest4);

divTestMdl5 = fitlm(data.IQ_DILUT_EPS_EXCL(2:end), yy);
fprintf('YY vs EPS R-squared: %.3f\n', divTestMdl5.Rsquared.Ordinary);
[~, DWTest5] = dwtest(divTestMdl5);
fprintf('YY vs EPS D-W stat: %.3f\n', DWTest5);

divTestMdl6 = fitlm(data.IQ_RETURN_EQUITY(2:end), yy);
fprintf('YY vs ROE R-squared: %.3f\n', divTestMdl6.Rsquared.Ordinary);
[~, DWTest6] = dwtest(divTestMdl6);
fprintf('YY vs ROE D-W stat: %.3f\n', DWTest6);

divTestMdl7 = fitlm(data.IQ_RETURN_CAPITAL(2:end), yy);
fprintf('YY vs ROC R-squared: %.3f\n', divTestMdl7.Rsquared.Ordinary);
[~, DWTest7] = dwtest(divTestMdl7);
fprintf('YY vs ROC D-W stat: %.3f\n', DWTest7);

% Combining regressors
divTestMdl8 = fitlm([data.IQ_DILUT_EPS_EXCL(2:end), data.IQ_RETURN_CAPITAL(2:end)], yy);
fprintf('YY vs EPS and ROC R-squared: %.3f\n', divTestMdl8.Rsquared.Ordinary);
[~, DWTest8] = dwtest(divTestMdl8);
fprintf('YY vs EPS and ROC D-W stat: %.3f\n', DWTest8);

divTestMdl9 = fitlm([data.IQ_DILUT_EPS_EXCL(2:end), data.IQ_RETURN_CAPITAL(1:end-1)], yy);
fprintf('YY(t) vs EPS(t) and ROC(t-1) R-squared: %.3f\n', divTestMdl9.Rsquared.Ordinary);
[~, DWTest9] = dwtest(divTestMdl9);
fprintf('YY(t) vs EPS(t) and ROC(t-1) D-W stat: %.3f\n', DWTest9);

divTestMdl10 = fitlm([data.IQ_DILUT_EPS_EXCL(2:end), data.IQ_RETURN_EQUITY(2:end)], yy);
fprintf('YY vs EPS and ROE R-squared: %.3f\n', divTestMdl10.Rsquared.Ordinary);
[~, DWTest10] = dwtest(divTestMdl10);
fprintf('YY vs EPS and ROE D-W stat: %.3f\n', DWTest10);

divTestMdl11 = fitlm([data.IQ_DILUT_EPS_EXCL(2:end), data.IQ_RETURN_EQUITY(1:end-1)], yy);
fprintf('YY(t) vs EPS(t) and ROE(t-1) R-squared: %.3f\n', divTestMdl11.Rsquared.Ordinary);
[~, DWTest11] = dwtest(divTestMdl11);
fprintf('YY(t) vs EPS(t) and ROE(t-1) D-W stat: %.3f\n', DWTest11);

% Estimating r
cfMdl1 = fitlm(data.IQ_EBITDA, data.IQ_CF_SHARE);
fprintf('Cash Flow beta on EBITDA for the whole sample is: %.2f \n', cfMdl1.Coefficients.Estimate(2));
fprintf('Cash Flow Linear Model 1 R-squared: %.2f\n', cfMdl1.Rsquared.Ordinary);
fprintf('Cash Flow Linear Model 1 tStat of EBITDA: %.2f\n', cfMdl1.Coefficients.tStat(2));

cfMdl2 = fitlm(data.IQ_EBITDA(1:40), data.IQ_CF_SHARE(1:40));
fprintf('Cash Flow beta on EBITDA for the first half is: %.2f \n', cfMdl2.Coefficients.Estimate(2));
fprintf('Cash Flow Linear Model 2 R-squared: %.2f\n', cfMdl2.Rsquared.Ordinary);
fprintf('Cash Flow Linear Model 2 tStat of EBITDA: %.2f\n', cfMdl2.Coefficients.tStat(2));

cfMdl3 = fitlm(data.IQ_EBITDA(41:80), data.IQ_CF_SHARE(41:80));
fprintf('Cash Flow beta on EBITDA for the second half is: %.2f \n', cfMdl3.Coefficients.Estimate(2));
fprintf('Cash Flow Linear Model 3 R-squared: %.2f\n', cfMdl3.Rsquared.Ordinary);
fprintf('Cash Flow Linear Model 3 tStat of EBITDA: %.2f\n', cfMdl3.Coefficients.tStat(2));

cfMdl4 = fitlm(data.IQ_DILUT_EPS_EXCL, data.IQ_CF_SHARE);
fprintf('CFPS beta on EPS for the whole sample is: %.2f \n', cfMdl4.Coefficients.Estimate(2));
fprintf('CFPS Linear Model 1 R-squared: %.2f\n', cfMdl4.Rsquared.Ordinary);
fprintf('CFPS Linear Model 1 tStat of EPS: %.2f\n', cfMdl4.Coefficients.tStat(2));

cfMdl5 = fitlm(data.IQ_DILUT_EPS_EXCL(1:40), data.IQ_CF_SHARE(1:40));
fprintf('CFPS beta on EPS for the first half is: %.2f \n', cfMdl5.Coefficients.Estimate(2));
fprintf('CFPS Linear Model 2 R-squared: %.2f\n', cfMdl5.Rsquared.Ordinary);
fprintf('CFPS Linear Model 2 tStat of EPS: %.2f\n', cfMdl5.Coefficients.tStat(2));

cfMdl6 = fitlm(data.IQ_DILUT_EPS_EXCL(41:80), data.IQ_CF_SHARE(41:80));
fprintf('CFPS beta on EPS for the second half is: %.2f \n', cfMdl6.Coefficients.Estimate(2));
fprintf('CFPS Linear Model 3 R-squared: %.2f\n', cfMdl6.Rsquared.Ordinary);
fprintf('CFPS Linear Model 3 tStat of EPS: %.2f\n', cfMdl6.Coefficients.tStat(2));

cfMdl7 = fitlm(data.IQ_EBIT, data.IQ_CF_SHARE);
fprintf('CFPS beta on EBIT for the whole sample is: %.2f \n', cfMdl7.Coefficients.Estimate(2));
fprintf('CFPS Linear Model 1 R-squared: %.2f\n', cfMdl7.Rsquared.Ordinary);
fprintf('CFPS Linear Model 1 tStat of EBIT: %.2f\n', cfMdl7.Coefficients.tStat(2));

cfMdl8 = fitlm(data.IQ_EBIT(1:40), data.IQ_CF_SHARE(1:40));
fprintf('CFPS beta on EBIT for the first half is: %.2f \n', cfMdl8.Coefficients.Estimate(2));
fprintf('CFPS Linear Model 2 R-squared: %.2f\n', cfMdl8.Rsquared.Ordinary);
fprintf('CFPS Linear Model 2 tStat of EBIT: %.2f\n', cfMdl8.Coefficients.tStat(2));

cfMdl9 = fitlm(data.IQ_EBIT(41:80), data.IQ_CF_SHARE(41:80));
fprintf('CFPS beta on EBIT for the second half is: %.2f \n', cfMdl9.Coefficients.Estimate(2));
fprintf('CFPS Linear Model 3 R-squared: %.2f\n', cfMdl9.Rsquared.Ordinary);
fprintf('CFPS Linear Model 3 tStat of EBIT: %.2f\n', cfMdl9.Coefficients.tStat(2));

roeMdl1 = fitlm(data.IQ_DILUT_EPS_EXCL, data.IQ_RETURN_EQUITY);
fprintf('ROE beta on EPS for the whole sample is: %.2f \n', roeMdl1.Coefficients.Estimate(2));
fprintf('ROE Linear Model 1 R-squared: %.2f\n', roeMdl1.Rsquared.Ordinary);
fprintf('ROE Linear Model 1 tStat of EPS: %.2f\n', roeMdl1.Coefficients.tStat(2));

roeMdl2 = fitlm(data.IQ_DILUT_EPS_EXCL(1:40), data.IQ_RETURN_EQUITY(1:40));
fprintf('ROE beta on EPS for the first half is: %.2f \n', roeMdl2.Coefficients.Estimate(2));
fprintf('ROE Linear Model 2 R-squared: %.2f\n', roeMdl2.Rsquared.Ordinary);
fprintf('ROE Linear Model 2 tStat of EPS: %.2f\n', roeMdl2.Coefficients.tStat(2));

roeMdl3 = fitlm(data.IQ_DILUT_EPS_EXCL(41:80), data.IQ_RETURN_EQUITY(41:80));
fprintf('ROE beta on EPS for the second half is: %.2f \n', roeMdl3.Coefficients.Estimate(2));
fprintf('ROE Linear Model 3 R-squared: %.2f\n', roeMdl3.Rsquared.Ordinary);
fprintf('ROE Linear Model 3 tStat of EPS: %.2f\n', roeMdl3.Coefficients.tStat(2));

roeMdl4 = fitlm(data.IQ_DILUT_EPS_EXCL(2:end), data.IQ_RETURN_EQUITY(1:end-1));
fprintf('ROE(t-1) beta on EPS for the whole sample is: %.2f \n', roeMdl4.Coefficients.Estimate(2));
fprintf('ROE(t-1) Linear Model 1 R-squared: %.2f\n', roeMdl4.Rsquared.Ordinary);
fprintf('ROE(t-1) Linear Model 1 tStat of EPS: %.2f\n', roeMdl4.Coefficients.tStat(2));

roeMdl5 = fitlm(data.IQ_DILUT_EPS_EXCL(2:40), data.IQ_RETURN_EQUITY(1:39));
fprintf('ROE(t-1) beta on EPS for the first half is: %.2f \n', roeMdl5.Coefficients.Estimate(2));
fprintf('RO(t-1)E Linear Model 2 R-squared: %.2f\n', roeMdl5.Rsquared.Ordinary);
fprintf('ROE(t-1) Linear Model 2 tStat of EPS: %.2f\n', roeMdl5.Coefficients.tStat(2));

roeMdl6 = fitlm(data.IQ_DILUT_EPS_EXCL(41:80), data.IQ_RETURN_EQUITY(40:79));
fprintf('ROE(t-1) beta on EPS for the second half is: %.2f \n', roeMdl6.Coefficients.Estimate(2));
fprintf('ROE(t-1) Linear Model 3 R-squared: %.2f\n', roeMdl6.Rsquared.Ordinary);
fprintf('ROE(t-1) Linear Model 3 tStat of EPS: %.2f\n', roeMdl6.Coefficients.tStat(2));

roeMdl7 = fitlm(data.IQ_DILUT_EPS_EXCL(2:end) - data.IQ_DILUT_EPS_EXCL(1:end-1), data.IQ_RETURN_EQUITY(2:end));
fprintf('ROE beta on EPS(t)-EPS(t-1) for the whole sample is: %.2f \n', roeMdl7.Coefficients.Estimate(2));
fprintf('ROE Linear Model 1 R-squared: %.2f\n', roeMdl7.Rsquared.Ordinary);
fprintf('ROE Linear Model 1 tStat of EPS(t)-EPS(t-1): %.2f\n', roeMdl7.Coefficients.tStat(2));

roeMdl8 = fitlm(data.IQ_DILUT_EPS_EXCL(2:40) - data.IQ_DILUT_EPS_EXCL(1:39), data.IQ_RETURN_EQUITY(2:40));
fprintf('ROE beta on EPS(t)-EPS(t-1) for the first half is: %.2f \n', roeMdl8.Coefficients.Estimate(2));
fprintf('ROE Linear Model 2 R-squared: %.2f\n', roeMdl8.Rsquared.Ordinary);
fprintf('ROE Linear Model 2 tStat of EPS(t)-EPS(t-1): %.2f\n', roeMdl8.Coefficients.tStat(2));

roeMdl9 = fitlm(data.IQ_DILUT_EPS_EXCL(41:80) - data.IQ_DILUT_EPS_EXCL(40:79), data.IQ_RETURN_EQUITY(41:80));
fprintf('ROE beta on EPS(t)-EPS(t-1) for the second half is: %.2f \n', roeMdl9.Coefficients.Estimate(2));
fprintf('ROE Linear Model 3 R-squared: %.2f\n', roeMdl9.Rsquared.Ordinary);
fprintf('ROE Linear Model 3 tStat of EPS(t)-EPS(t-1): %.2f\n', roeMdl9.Coefficients.tStat(2));

roeMdl10 = fitlm(data.IQ_EBIT(2:end) - data.IQ_EBIT(1:end-1), data.IQ_RETURN_EQUITY(2:end));
fprintf('ROE beta on EBIT(t)-EBIT(t-1) for the whole sample is: %.2f \n', roeMdl10.Coefficients.Estimate(2));
fprintf('ROE Linear Model 1 R-squared: %.2f\n', roeMdl10.Rsquared.Ordinary);
fprintf('ROE Linear Model 1 tStat of EBIT(t)-EBIT(t-1): %.2f\n', roeMdl10.Coefficients.tStat(2));

roeMdl11 = fitlm(data.IQ_EBIT(2:40) - data.IQ_EBIT(1:39), data.IQ_RETURN_EQUITY(2:40));
fprintf('ROE beta on EBIT(t)-EBIT(t-1) for the first half is: %.2f \n', roeMdl11.Coefficients.Estimate(2));
fprintf('ROE Linear Model 2 R-squared: %.2f\n', roeMdl11.Rsquared.Ordinary);
fprintf('ROE Linear Model 2 tStat of EBIT(t)-EBIT(t-1): %.2f\n', roeMdl11.Coefficients.tStat(2));

roeMdl12 = fitlm(data.IQ_EBIT(41:80) - data.IQ_EBIT(40:79), data.IQ_RETURN_EQUITY(41:80));
fprintf('ROE beta on EBIT(t)-EBIT(t-1) for the second half is: %.2f \n', roeMdl12.Coefficients.Estimate(2));
fprintf('ROE Linear Model 3 R-squared: %.2f\n', roeMdl12.Rsquared.Ordinary);
fprintf('ROE Linear Model 3 tStat of EBIT(t)-EBIT(t-1): %.2f\n', roeMdl12.Coefficients.tStat(2));

roeMdl13 = fitlm(data.IQ_DILUT_EPS_EXCL(2:end) - data.IQ_DILUT_EPS_EXCL(1:end-1), data.IQ_RETURN_EQUITY(1:end-1));
fprintf('ROE(t-1) beta on EPS(t)-EPS(t-1) for the whole sample is: %.2f \n', roeMdl13.Coefficients.Estimate(2));
fprintf('ROE(t-1) Linear Model 1 R-squared: %.2f\n', roeMdl13.Rsquared.Ordinary);
fprintf('ROE(t-1) Linear Model 1 tStat of EPS(t)-EPS(t-1): %.2f\n', roeMdl13.Coefficients.tStat(2));

roeMdl14 = fitlm(data.IQ_DILUT_EPS_EXCL(2:40) - data.IQ_DILUT_EPS_EXCL(1:39), data.IQ_RETURN_EQUITY(1:39));
fprintf('ROE(t-1) beta on EPS(t)-EPS(t-1) for the first half is: %.2f \n', roeMdl14.Coefficients.Estimate(2));
fprintf('ROE(t-1) Linear Model 2 R-squared: %.2f\n', roeMdl14.Rsquared.Ordinary);
fprintf('ROE(t-1) Linear Model 2 tStat of EPS(t)-EPS(t-1): %.2f\n', roeMdl14.Coefficients.tStat(2));

roeMdl15 = fitlm(data.IQ_DILUT_EPS_EXCL(41:80) - data.IQ_DILUT_EPS_EXCL(40:79), data.IQ_RETURN_EQUITY(40:79));
fprintf('ROE(t-1) beta on EPS(t)-EPS(t-1) for the second half is: %.2f \n', roeMdl15.Coefficients.Estimate(2));
fprintf('ROE(t-1) Linear Model 3 R-squared: %.2f\n', roeMdl15.Rsquared.Ordinary);
fprintf('ROE(t-1) Linear Model 3 tStat of EPS(t)-EPS(t-1): %.2f\n', roeMdl15.Coefficients.tStat(2));

roeMdl16 = fitlm(data.IQ_EBITDA, data.IQ_RETURN_EQUITY);
fprintf('ROE beta on EBITDA for the whole sample is: %.2f \n', roeMdl16.Coefficients.Estimate(2));
fprintf('ROE Linear Model 1 R-squared: %.2f\n', roeMdl16.Rsquared.Ordinary);
fprintf('ROE Linear Model 1 tStat of EBITDA: %.2f\n', roeMdl16.Coefficients.tStat(2));

roeMdl17 = fitlm(data.IQ_EBITDA(1:40), data.IQ_RETURN_EQUITY(1:40));
fprintf('ROE beta on EBITDA for the first half is: %.2f \n', roeMdl17.Coefficients.Estimate(2));
fprintf('ROE Linear Model 2 R-squared: %.2f\n', roeMdl17.Rsquared.Ordinary);
fprintf('ROE Linear Model 2 tStat of EBITDA: %.2f\n', roeMdl17.Coefficients.tStat(2));

roeMdl18 = fitlm(data.IQ_EBITDA(41:80), data.IQ_RETURN_EQUITY(41:80));
fprintf('ROE beta on EBITDA for the second half is: %.2f \n', roeMdl18.Coefficients.Estimate(2));
fprintf('ROE Linear Model 3 R-squared: %.2f\n', roeMdl18.Rsquared.Ordinary);
fprintf('ROE Linear Model 3 tStat of EBITDA): %.2f\n', roeMdl18.Coefficients.tStat(2));

roeMdl19 = fitlm(data.IQ_EBIT, data.IQ_RETURN_EQUITY);
fprintf('ROE beta on EBIT for the whole sample is: %.2f \n', roeMdl19.Coefficients.Estimate(2));
fprintf('ROE Linear Model 1 R-squared: %.2f\n', roeMdl19.Rsquared.Ordinary);
fprintf('ROE Linear Model 1 tStat of EBIT: %.2f\n', roeMdl19.Coefficients.tStat(2));

roeMdl20 = fitlm(data.IQ_EBIT(1:40), data.IQ_RETURN_EQUITY(1:40));
fprintf('ROE beta on EBIT for the first half is: %.2f \n', roeMdl20.Coefficients.Estimate(2));
fprintf('ROE Linear Model 2 R-squared: %.2f\n', roeMdl20.Rsquared.Ordinary);
fprintf('ROE Linear Model 2 tStat of EBIT: %.2f\n', roeMdl20.Coefficients.tStat(2));

roeMdl21 = fitlm(data.IQ_EBIT(41:80), data.IQ_RETURN_EQUITY(41:80));
fprintf('ROE beta on EBIT for the second half is: %.2f \n', roeMdl21.Coefficients.Estimate(2));
fprintf('ROE Linear Model 3 R-squared: %.2f\n', roeMdl21.Rsquared.Ordinary);
fprintf('ROE Linear Model 3 tStat of EBIT: %.2f\n', roeMdl21.Coefficients.tStat(2));

divMdl2 = fitlm([data.IQ_EBIT(2:end), data.IQ_RETURN_EQUITY(2:end) - 0.2 * data.IQ_EBIT(2:end)], yy);
fprintf('Dividend Linear Model 2 R-squared: %.3f\n', divMdl2.Rsquared.Ordinary);
[~, DW2] = dwtest(divMdl2);
fprintf('Dividend Linear Model 2 D-W stat: %.3f\n', DW2);

fprintf('2-Stage Dividend Linear Model R-squared: %.3f\n', 1 - divMdl2.SSE / divMdl1.SST);

corrcoef([data.IQ_EBITDA, data.IQ_EBIT, data.IQ_TOTAL_REV, data.IQ_CF_SHARE, data.IQ_DILUT_EPS_EXCL, data.IQ_RETURN_EQUITY, data.IQ_RETURN_CAPITAL]);
corrcoef([data.IQ_EBIT(2:end), data.IQ_RETURN_EQUITY(2:end) - 0.2 * data.IQ_EBIT(2:end)]);
end
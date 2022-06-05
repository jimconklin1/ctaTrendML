function [filteredDivs, fundData] = computeFilteredDividends(fundData,freq)
% this function takes a smoothed filter of dividends 

inflationAdj = cumprod(1 + flip(fundData.('Inflation_Rate'))); 
fundData.('Inflation_Adjusted_Earnings') = fundData.Earnings .* flip([1; inflationAdj(1:end-1)]); 
nomGDP = fundData.('nom_GDP'); 
nomGDPgr = [0.0125; (nomGDP(2:end,:)./nomGDP(1:end-1,:)-1)]; 
nomGDPadj = cumprod(1 + flip(nomGDPgr)); 
fundData.('NominalGDP_Adjusted_Earnings') = fundData.Earnings .* flip([1; nomGDPadj(1:end-1)]); 
temp1 = movmean(fundData.Dividends,[3 0],'omitnan'); 
temp2 = movmean(fundData.Earnings,[3 0],'omitnan'); 
temp = temp1./temp2; 
temp(isinf(temp)) = 1.0; 
fundData.('Dividend_Ratio') = temp; 
filteredDivs = array2table(fundData.Date,'VariableNames', {'Date'});

if strcmpi(freq,'quarterly')
    avgPayout12 = movmean(fundData.('Dividend_Yield'), [11 0],'omitnan');
    fundData.('Dividend_Yield_12Q_MA') = avgPayout12;
    avgPayout24 = movmean(fundData.('Dividend_Yield'), [23 0],'omitnan');
    fundData.('Dividend_Yield_24Q_MA') = avgPayout24;
    avgPayout36 = movmean(fundData.('Dividend_Yield'), [35 0],'omitnan');
    fundData.('Dividend_Yield_36Q_MA') = avgPayout36;
    avgAdjPayout32 = movmean(fundData.('Inflation_Adjusted_Earnings'), [31 0],'omitnan');
    avgAdjPayout32 = avgAdjPayout32 .* fundData.CPI / fundData.CPI(end);
    fundData.('Adjusted_Earnings_32Q_MA') = avgAdjPayout32;
    avgGDPadjPayout12 = movmean(fundData.('NominalGDP_Adjusted_Earnings'), [11 0],'omitnan');
    avgGDPadjPayout12 = avgGDPadjPayout12 .* fundData.nom_GDP / fundData.nom_GDP(end);
    fundData.('GDP_Adjusted_Earnings_12Q_MA') = avgGDPadjPayout12;
    avgGDPadjPayout24 = movmean(fundData.('NominalGDP_Adjusted_Earnings'), [23 0],'omitnan');
    avgGDPadjPayout24 = avgGDPadjPayout24 .* fundData.nom_GDP / fundData.nom_GDP(end);
    fundData.('GDP_Adjusted_Earnings_24Q_MA') = avgGDPadjPayout24;

    fundData.('Adj_Dividend_Ratio_20Q') = replaceOutliers(fundData.Dividend_Ratio,20,'rolling',8);
    avgPayoutRatio12 = movmean(fundData.('Adj_Dividend_Ratio_20Q'), [11 0],'omitnan');
    fundData.('Dividend_Ratio_12Q_MA') = avgPayoutRatio12;
    avgPayoutRatio24 = movmean(fundData.('Adj_Dividend_Ratio_20Q'), [23 0],'omitnan');
    fundData.('Dividend_Ratio_24Q_MA') = avgPayoutRatio24;
    avgPayoutRatio36 = movmean(fundData.('Adj_Dividend_Ratio_20Q'), [35 0],'omitnan');
    fundData.('Dividend_Ratio_36Q_MA') = avgPayoutRatio36;
    
    filteredDivs.('CURRVAL') = fundData.('Dividends');
    filteredDivs.('NA12') = fundData.('Market_Value').*fundData.('Dividend_Yield_12Q_MA');
    filteredDivs.('NA24') = fundData.('Market_Value').*fundData.('Dividend_Yield_24Q_MA');
    filteredDivs.('NA36') = fundData.('Market_Value').*fundData.('Dividend_Yield_36Q_MA');
%    filteredDivs.('NP12') = fundData.('Earnings').*fundData.('Dividend_Ratio_12Q_MA');
    filteredDivs.('NP12') = fundData.('GDP_Adjusted_Earnings_12Q_MA').*fundData.('Dividend_Ratio_12Q_MA');
%    filteredDivs.('NP24') = fundData.('Earnings').*fundData.('Dividend_Ratio_24Q_MA');
    filteredDivs.('NP24') = fundData.('GDP_Adjusted_Earnings_12Q_MA').*fundData.('Dividend_Ratio_24Q_MA');
    filteredDivs.('NP36') = fundData.('Earnings').*fundData.('Dividend_Ratio_36Q_MA');
    filteredDivs.('NNORM') = fundData.('Adjusted_Earnings_32Q_MA').*fundData.('Dividend_Ratio_36Q_MA');
    filteredDivs.('OPT_AVG') = 0.6*filteredDivs.NP12 + 0.4*filteredDivs.NNORM;
else
    avgPayout5 = movmean(fundData.('Dividend_Yield'), [4 0],'omitnan');
    fundData.('Dividend_Yield_5Y_MA') = avgPayout5;
    avgPayout10 = movmean(fundData.('Dividend_Yield'), [9 0],'omitnan');
    fundData.('Dividend_Yield_10Y_MA') = avgPayout10;

    avgAdjPayout10 = movmean(fundData.('Inflation_Adjusted_Earnings'), [9 0],'omitnan');
    avgAdjPayout10 = avgAdjPayout10 .* fundData.CPI / fundData.CPI(end);
    fundData.('Adjusted_Earnings_10Y_MA') = avgAdjPayout10;

    avgPayoutRatio5 = movmean(fundData.('Dividend_Ratio'), [4 0],'omitnan');
    fundData.('Dividend_Ratio_5Y_MA') = avgPayoutRatio5;
    avgPayoutRatio10 = movmean(fundData.('Dividend_Ratio'), [9 0],'omitnan');
    fundData.('Dividend_Ratio_10Y_MA') = avgPayoutRatio10;

    filteredDivs.('CURRVAL') = fundData.('Dividends');
    filteredDivs.('NA5') = fundData.('Market_Value').*fundData.('Dividend_Yield_5Y_MA');
    filteredDivs.('NA10') = fundData.('Market_Value').*fundData.('Dividend_Yield_10Y_MA');
    filteredDivs.('NP5') = fundData.('Earnings').*fundData.('Dividend_Ratio_5Y_MA');
    filteredDivs.('NP10') = fundData.('Earnings').*fundData.('Dividend_Ratio_10Y_MA');
    filteredDivs.('NNORM') = fundData.('Adjusted_Earnings_10Y_MA').*fundData.('Dividend_Ratio_10Y_MA');
    filteredDivs.('OPT_AVG') = 0.4*filteredDivs.NP5 + 0.6*filteredDivs.NNORM;
end

end 
% %                     Date Px Div NetCash DivYld
% cashFlows = fundData(:,[1,   2, 4,  8,      9]);  
% dates = cashFlows.Date; 
% T = size(dates,1);  
% y = cashFlows.Dividends; 

% X0 = [fundData.Dividend_Ratio_12Q_MA,fundData.Dividend_Ratio_24Q_MA,fundData.Dividend_Ratio_36Q_MA];
% figure(1); plot(dates,[X0]); datetick('x','yyyy'); grid 
% 
% X0 = [filteredDivs.NA12, filteredDivs.NA24,filteredDivs.NA36]; %[filteredDivs.NP5,filteredDivs.NP10] [filteredDivs.NA5, filteredDivs.NA10] filteredDivs.NNORM
% X0((X0==0))= NaN; 
% figure(2); plot(dates,[y, X0]); datetick('x','yyyy'); grid 
% 
% X0 = [fundData.Dividend_Ratio_12Q_MA,fundData.Dividend_Ratio_36Q_MA]; %[filteredDivs.NP5,filteredDivs.NP10] [filteredDivs.NA5, filteredDivs.NA10] filteredDivs.NNORM
% X0((X0==0))= NaN; 
% figure(3); plot(dates,[y, 10*X0]); datetick('x','yyyy'); grid 
% 
% X0 = [fundData.('Earnings'), fundData.('Dividend_Ratio_24Q_MA'), filteredDivs.NP24]; 
% X0 = [filteredDivs.NP12, filteredDivs.NP24]; 
% figure(4); plot(dates,[y,X0]); datetick('x','yyyy'); grid 
% 
% X0 = [0.2*fundData.('Adjusted_Earnings_32Q_MA'),5*fundData.('Dividend_Ratio_36Q_MA'),filteredDivs.NNORM];
% figure(5); plot(dates,[y,X0]); datetick('x','yyyy'); grid 
% 
% X0 = [filteredDivs.NP12,filteredDivs.NNORM,filteredDivs.OPT_AVG]; % [filteredDivs.NA16, filteredDivs.NP24, filteredDivs.NNORM];
% figure(5); plot(dates,[y,X0]); datetick('x','yyyy'); grid 
% 
% figure(6); plot(dates,[fundData.Earnings,10*fundData.Dividend_Ratio]); datetick('x','yyyy'); grid


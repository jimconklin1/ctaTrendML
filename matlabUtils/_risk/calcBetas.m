function betas = calcBetas(thesisData)

corrHeader = {'ES1 Index', 'DXY Curncy', 'TY1 Comdty', 'CL1 Comdty'};
startDate = datestr( busdate(today()-(2*365+1)),'yyyy-mm-dd');
endDate = datestr(today(),'yyyy-mm-dd');
temp1 = tsrp.fetch_bbg_daily_close(corrHeader, startDate, endDate);
[tempDates1,temp1] = cleanTSRPdates(temp1(:,1),temp1(:,2:end));
N = length(corrHeader);
M = length(thesisData.header);
temp2 = transformFlatData(corrHeader,tempDates1,temp1,ones(1,N));
[temp3, ~] = alignNewDatesJC(tempDates1, temp2, thesisData.dates);
temp3(isnan(temp3)) = 0;
betas = zeros(M, N);

for i = 1 : M
    for j = 1 : N
        t0 = findFirstGood(thesisData.close(:, i), 0);
        covMatrix = cov([thesisData.close(t0:end, i), temp3(t0:end, j)]);
        varVector = var([thesisData.close(t0:end, i), temp3(t0:end, j)]);
        betas(i, j) = covMatrix(1, 2) / varVector(2);
    end
end

end
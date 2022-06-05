function monthlyReturns = InterpolateQuarterlyReturns(dates, benchReturns, rfReturns, quarterlyReturns)

%sort returns
[dates,indexes] = sort(dates);
benchReturns = benchReturns(indexes);
quarterlyReturns =  quarterlyReturns(indexes);
rfReturns = rfReturns(indexes);

%Estimate beta using quarterly returns
quarterIndices = ~isnan(quarterlyReturns);
quarterlyRets = quarterlyReturns(quarterIndices);
quarterlyBenchRets = benchReturns;
quarterlyRfRets = rfReturns;
n = size(dates,1);
for i= 1:n
    if quarterIndices(i)
        quarterlyBenchRets(i) = (1+benchReturns(i-2))*(1+benchReturns(i-1))*(1+benchReturns(i))-1;
        quarterlyRfRets(i) = (1+rfReturns(i-2))*(1+rfReturns(i-1))*(1+rfReturns(i))-1;
    end
end
quarterlyBenchRets = quarterlyBenchRets(quarterIndices);
quarterlyRfRets = quarterlyRfRets(quarterIndices);


quarterlyRets = quarterlyRets - quarterlyRfRets;
quarterlyBenchRets = quarterlyBenchRets - quarterlyRfRets;
C=cov(quarterlyRets, quarterlyBenchRets);
beta = C(1,2)/C(2,2);

%interpolate monthly returns
monthlyReturns = (benchReturns-rfReturns)*beta+rfReturns;
nMonths = size(monthlyReturns,1);
cumReturn = 0.0;
for nMonth = 1:nMonths
    cumReturn = (1+cumReturn)*(1+monthlyReturns(nMonth))-1.0;
    if ~isnan(quarterlyReturns(nMonth))
        idyosyncratic = quarterlyReturns(nMonth)-cumReturn;
        monthlyReturns(nMonth-2) = monthlyReturns(nMonth-2) + idyosyncratic/3.0;
        monthlyReturns(nMonth-1) = monthlyReturns(nMonth-1) + idyosyncratic/3.0;
        monthlyReturns(nMonth) = monthlyReturns(nMonth) + idyosyncratic/3.0;
        cumReturn = 0.0;
    end
end





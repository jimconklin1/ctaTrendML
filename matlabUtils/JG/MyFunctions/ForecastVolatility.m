function[forecastvol]=ForecastVolatility(x,period)


garchk=zeros(length(x),1);
myend=length(x);
x2r =  RateofChange(x,'difference',1);
for i=period+1:myend
    [coeff] = garchfit(x2r(i-period+1:i));%[coeff,errors,LLF,innovations,sigmas
    [sigmaForecast]  = garchpred(coeff,x2r(i-period+1:i),1);%[sigmaForecast,meanForecast]
    if size(sigmaForecast,1)==1 && size(sigmaForecast,2)==1
        garchk(i)=sigmaForecast;
    else
        garchk(i)=garchk(i-1);
    end
end

forecastvol=garchk;
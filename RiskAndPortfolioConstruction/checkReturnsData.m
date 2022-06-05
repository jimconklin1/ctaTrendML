function checkReturnsData(cfg, outStruct)
for i = 1:size(outStruct.equFactorRtns.values, 2)
    plot(outStruct.equFactorRtns.dates, calcCum(outStruct.equFactorRtns.values(:,i), 1));
    grid; 
    datetick('x', 'mmyyyy');
    title(string(i) + ". " +string(outStruct.equFactorRtns.bbgTicker(:,i)) + " | " + string(outStruct.equFactorRtns.header(i)));
    % A dummy line below for putting a breakpoint
    tmp=i;
end % i    

end %function
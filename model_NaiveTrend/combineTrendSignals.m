function signal = combineTrendSignals(signal1,signal2,signal3,signal4,signal5,relWts)

signal = signal1;

if (~isempty(signal1) & ~isempty(signal2)) & (isempty(signal3) & isempty(signal4) & isempty(signal5)) %#ok<AND2>
    for k = 1:length(signal.subStratNames)
        signal.variableList(k) = {signal.variableList{k}(1:end-4)};
        dates0 = signal1.subStrat(k).dates;
        [temp2, ~] = alignRtns2NewDates(signal2.subStrat(k).dates, signal2.subStrat(k).values, dates0);
        signal.subStrat(k).values = relWts(1)*signal1.subStrat(k).values + ...
                                    relWts(2)*temp2;
    end % for
elseif (~isempty(signal1) & ~isempty(signal2) & ~isempty(signal3)) & (isempty(signal4) & isempty(signal5)) %#ok<AND2>
    for k = 1:length(signal.subStratNames)
        signal.variableList(k) = {signal.variableList{k}(1:end-4)};
        dates0 = signal1.subStrat(k).dates;
        [temp2, ~] = alignRtns2NewDates(signal2.subStrat(k).dates, signal2.subStrat(k).values, dates0);
        [temp3, ~] = alignRtns2NewDates(signal3.subStrat(k).dates, signal3.subStrat(k).values, dates0);
        signal.subStrat(k).values = relWts(1)*signal1.subStrat(k).values + ...
                                    relWts(2)*temp2 + relWts(3)*temp3;
    end % for
elseif (~isempty(signal1) & ~isempty(signal2) & ~isempty(signal3) & ~isempty(signal4)) & isempty(signal5) %#ok<AND2>
    for k = 1:length(signal.subStratNames)
        signal.variableList(k) = {signal.variableList{k}(1:end-4)};
        dates0 = signal1.subStrat(k).dates;
        [temp2, ~] = alignRtns2NewDates(signal2.subStrat(k).dates, signal2.subStrat(k).values, dates0);
        [temp3, ~] = alignRtns2NewDates(signal3.subStrat(k).dates, signal3.subStrat(k).values, dates0);
        [temp4, ~] = alignRtns2NewDates(signal4.subStrat(k).dates, signal4.subStrat(k).values, dates0);
        signal.subStrat(k).values = relWts(1)*signal1.subStrat(k).values + ...
                                    relWts(2)*temp2 + relWts(3)*temp3 + relWts(4)*temp4;
    end % for             
else
    for k = 1:length(signal.subStratNames)
        signal.variableList(k) = {signal.variableList{k}(1:end-4)};
        dates0 = signal1.subStrat(k).dates;
        [temp2, ~] = alignRtns2NewDates(signal2.subStrat(k).dates, signal2.subStrat(k).values, dates0);
        [temp3, ~] = alignRtns2NewDates(signal3.subStrat(k).dates, signal3.subStrat(k).values, dates0);
        [temp4, ~] = alignRtns2NewDates(signal4.subStrat(k).dates, signal4.subStrat(k).values, dates0);
        [temp5, ~] = alignRtns2NewDates(signal5.subStrat(k).dates, signal5.subStrat(k).values, dates0);
        signal.subStrat(k).values = relWts(1)*signal1.subStrat(k).values + ...
                                    relWts(2)*temp2 + relWts(3)*temp3 + relWts(4)*temp4 + relWts(5)*temp5;
    end % for             
end % if

end % fn
function dataOut = getPX(dateIn, dataIn, dateOut)
% getPX: for a date vector of lower temporal density than input data dates (dateOut),
%        the function finds the latest inpute time stamp on any given date
%        in dateOut, and fills the corresponding data value into dataOut
dataOut = nan(length(dateOut), size(dataIn,2));
t0=1 ;
for t=1:length(dateOut)
    while t0<=length(dateIn) && dateIn(t0)<= dateOut(t)
        indx= ~isnan(dataIn(t0,:));
        dataOut(t,indx)= dataIn(t0,indx);
        t0=t0+1;
    end % while
end % for

end % fn

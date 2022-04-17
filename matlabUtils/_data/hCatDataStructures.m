function outData = hCatDataStructures(data1,data2,data3,data4,data5,data6,data7,data8)
% data structures must have aligned and equivalent configuratations or
% routine will fail.
if nargin < 3
   outData.header = [data1.header,data2.header]; 
   if isfield(data1,'holidays')
      outData.holidays = [data1.holidays,data2.holidays]; 
   end 
   date0 = max([data1.dates(1),data2.dates(1)]); 
   dateT = max([data1.dates(end),data2.dates(end)]);
   outData.dates = makeStandardDates(date0,dateT);
   if isfield(data1,'values')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.values,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.values,round(outData.dates,0),NaN);
      outData.values = [temp1,temp2];
   end % if
   if isfield(data1,'close')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.close,round(round(outData.dates,0),0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.close,round(outData.dates,0),NaN);
      outData.close = [temp1,temp2];
   end % if
   if isfield(data1,'range')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.range,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.range,round(outData.dates,0),NaN);
      outData.range = [temp1,temp2];
   end % if
   if isfield(data1,'rtns')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.rtns,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.rtns,round(outData.dates,0),NaN);
      outData.rtns = [temp1,temp2];
   end % if 
elseif nargin < 4
   outData.header = [data1.header,data2.header,data3.header]; 
   if isfield(data1,'holidays')
      outData.holidays = [data1.holidays,data2.holidays,data3.holidays]; 
   end 
   date0 = max([data1.dates(1),data2.dates(1),data3.dates(1)]); 
   dateT = max([data1.dates(end),data2.dates(end),data3.dates(end)]);
   outData.dates = makeStandardDates(date0,dateT);
   if isfield(data1,'values')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.values,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.values,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.values,round(outData.dates,0),NaN);
      outData.values = [temp1,temp2,temp3];
   end % if
   if isfield(data1,'close')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.close,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.close,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.close,round(outData.dates,0),NaN);
      outData.close = [temp1,temp2,temp3];
   end % if
   if isfield(data1,'range')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.range,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.range,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.range,round(outData.dates,0),NaN);
      outData.range = [temp1,temp2,temp3];
   end % if
   if isfield(data1,'rtns')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.rtns,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.rtns,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.rtns,round(outData.dates,0),NaN);
      outData.rtns = [temp1,temp2,temp3];
   end % if
elseif nargin < 5
   outData.header = [data1.header,data2.header,data3.header,data4.header]; 
   if isfield(data1,'holidays')
      outData.holidays = [data1.holidays,data2.holidays,data3.holidays,data4.holidays]; 
   end 
   date0 = max([data1.dates(1),data2.dates(1),data3.dates(1),data4.dates(1)]); 
   dateT = max([data1.dates(end),data2.dates(end),data3.dates(end),data4.dates(end)]);
   outData.dates = makeStandardDates(date0,dateT);
   if isfield(data1,'values')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.values,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.values,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.values,round(outData.dates,0),NaN);
      [temp4,~] = alignNewDatesJC(round(data4.dates,0),data4.values,round(outData.dates,0),NaN);
      outData.values = [temp1,temp2,temp3,temp4];
   end % if
   if isfield(data1,'close')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.close,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.close,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.close,round(outData.dates,0),NaN);
      [temp4,~] = alignNewDatesJC(round(data4.dates,0),data4.close,round(outData.dates,0),NaN);
      outData.close = [temp1,temp2,temp3,temp4];
   end % if
   if isfield(data1,'range')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.range,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.range,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.range,round(outData.dates,0),NaN);
      [temp4,~] = alignNewDatesJC(round(data4.dates,0),data4.range,round(outData.dates,0),NaN);
      outData.range = [temp1,temp2,temp3,temp4];
   end % if
   if isfield(data1,'rtns')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.rtns,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.rtns,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.rtns,round(outData.dates,0),NaN);
      [temp4,~] = alignNewDatesJC(round(data4.dates,0),data4.rtns,round(outData.dates,0),NaN);
      outData.rtns = [temp1,temp2,temp3,temp4];
   end % if
elseif nargin < 6
   outData.header = [data1.header,data2.header,data3.header,data4.header,data5.header]; 
   if isfield(data1,'holidays')
      outData.holidays = [data1.holidays,data2.holidays,data3.holidays,data4.holidays,data5.holidays]; 
   end 
   date0 = max([data1.dates(1),data2.dates(1),data3.dates(1),data4.dates(1),data5.dates(1)]); 
   dateT = max([data1.dates(end),data2.dates(end),data3.dates(end),data4.dates(end),data5.dates(end)]);
   outData.dates = makeStandardDates(date0,dateT);
   if isfield(data1,'values')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.values,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.values,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.values,round(outData.dates,0),NaN);
      [temp4,~] = alignNewDatesJC(round(data4.dates,0),data4.values,round(outData.dates,0),NaN);
      [temp5,~] = alignNewDatesJC(round(data5.dates,0),data5.values,round(outData.dates,0),NaN);
      outData.values = [temp1,temp2,temp3,temp4,temp5];
   end % if
   if isfield(data1,'close')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.close,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.close,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.close,round(outData.dates,0),NaN);
      [temp4,~] = alignNewDatesJC(round(data4.dates,0),data4.close,round(outData.dates,0),NaN);
      [temp5,~] = alignNewDatesJC(round(data5.dates,0),data5.close,round(outData.dates,0),NaN);
      outData.close = [temp1,temp2,temp3,temp4,temp5];
   end % if
   if isfield(data1,'range')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.range,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.range,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.range,round(outData.dates,0),NaN);
      [temp4,~] = alignNewDatesJC(round(data4.dates,0),data4.range,round(outData.dates,0),NaN);
      [temp5,~] = alignNewDatesJC(round(data5.dates,0),data5.range,round(outData.dates,0),NaN);
      outData.range = [temp1,temp2,temp3,temp4,temp5];
   end % if
   if isfield(data1,'rtns')
      [temp1,~] = alignNewDatesJC(round(data1.dates,0),data1.rtns,round(outData.dates,0),NaN);
      [temp2,~] = alignNewDatesJC(round(data2.dates,0),data2.rtns,round(outData.dates,0),NaN);
      [temp3,~] = alignNewDatesJC(round(data3.dates,0),data3.rtns,round(outData.dates,0),NaN);
      [temp4,~] = alignNewDatesJC(round(data4.dates,0),data4.rtns,round(outData.dates,0),NaN);
      [temp5,~] = alignNewDatesJC(round(data5.dates,0),data5.rtns,round(outData.dates,0),NaN);
      outData.rtns = [temp1,temp2,temp3,temp4,temp5];
   end % if
elseif nargin < 7
   outData.header = [data1.header,data2.header,data3.header,data4.header,data5.header,data6.header]; 
   if isfield(data1,'holidays')
      outData.holidays = [data1.holidays,data2.holidays,data3.holidays,data4.holidays,data5.holidays,data6.holidays]; 
   end 
   date0 = max([data1.dates(1),data2.dates(1),data3.dates(1),data4.dates(1),data5.dates(1),data6.dates(1)]); 
   dateT = max([data1.dates(end),data2.dates(end),data3.dates(end),data4.dates(end),data5.dates(end),data6.dates(end)]);
   outData.dates = makeStandardDates(date0,dateT);
elseif nargin < 8
   outData.header = [data1.header,data2.header,data3.header,data4.header,data5.header,data6.header,data7.header]; 
   if isfield(data1,'holidays')
      outData.holidays = [data1.holidays,data2.holidays,data3.holidays,data4.holidays,data5.holidays,data6.holidays,data7.holidays]; 
   end 
   date0 = max([data1.dates(1),data2.dates(1),data3.dates(1),data4.dates(1),data5.dates(1),data6.dates(1), ...
                data7.dates(1)]); 
   dateT = max([data1.dates(end),data2.dates(end),data3.dates(end),data4.dates(end),data5.dates(end),data6.dates(end), ...
                data7.dates(end)]);
   outData.dates = makeStandardDates(date0,dateT);
else
   outData.header = [data1.header,data2.header,data3.header,data4.header,data5.header,data6.header,data7.header,data8.header]; 
   if isfield(data1,'holidays')
      outData.holidays = [data1.holidays,data2.holidays,data3.holidays,data4.holidays,data5.holidays,data6.holidays,data7.holidays,data8.holidays]; 
   end 
   date0 = max([data1.dates(1),data2.dates(1),data3.dates(1),data4.dates(1),data5.dates(1),data6.dates(1), ...
                data7.dates(1),data8.dates(1)]); 
   dateT = max([data1.dates(end),data2.dates(end),data3.dates(end),data4.dates(end),data5.dates(end),data6.dates(end), ...
                data7.dates(end),data8.dates(end)]);
   outData.dates = makeStandardDates(date0,dateT);
end % if
end % fn
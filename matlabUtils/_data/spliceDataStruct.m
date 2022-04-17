function dataStruct = spliceDataStruct(dataStruct0,dataStruct1,spliceDate,refField1,refField2,refField3,refField4,refField5,...
                                       field1,field2,field3,field4,field5,field6)
% required fields in dataStruct1 and 2: .dates
% required input arguments:
%    dataStruct0,dataStruct1,spliceDate,refField1,refField2,refField3, and field1
% optional input arguments:
%    field2 ... field6
if ~isempty(refField1)
   eval(['dataStruct.',refField1,' = dataStruct0.',refField1,';'])
end
if ~isempty(refField2)
   eval(['dataStruct.',refField2,' = dataStruct0.',refField2,';'])
end 
if ~isempty(refField3)
   eval(['dataStruct.',refField3,' = dataStruct0.',refField3,';'])
end 
if ~isempty(refField4)
   eval(['dataStruct.',refField4,' = dataStruct0.',refField4,';'])
end 
if ~isempty(refField5)
   eval(['dataStruct.',refField5,' = dataStruct0.',refField5,';'])
end 
tT = find(dataStruct0.dates <= spliceDate,1,'last');
t0 = find(dataStruct1.dates >= spliceDate,1,'first');
if dataStruct0.dates(tT) == dataStruct1.dates(t0); t0 = t0+1; end % if
t0 = t0+1;
tT = tT+1;
dataStruct.dates = [dataStruct0.dates(1:tT,:); dataStruct1.dates(t0:end,:)];

str = ['dataStruct.',field1,' = [dataStruct0.',field1,'(1:tT,:); dataStruct1.',field1,'(t0:end,:)];'];
eval(str);

if nargin > 9 && ~isempty(field2)
   str = ['dataStruct.',field2,' = [dataStruct0.',field2,'(1:tT,:); dataStruct1.',field2,'(t0:end,:)];'];
   eval(str);
end

if nargin > 10
   str = ['dataStruct.',field3,' = [dataStruct0.',field3,'(1:tT,:); dataStruct1.',field3,'(t0:end,:)];'];
   eval(str);
end

if nargin > 11
   str = ['dataStruct.',field4,' = [dataStruct0.',field4,'(1:tT,:); dataStruct1.',field4,'(t0:end,:)];'];
   eval(str);
end

if nargin > 12
   str = ['dataStruct.',field5,' = [dataStruct0.',field5,'(1:tT,:); dataStruct1.',field5,'(t0:end,:)];'];
   eval(str);
end

if nargin > 13
   str = ['dataStruct.',field6,' = [dataStruct0.',field6,'(1:tT,:); dataStruct1.',field6,'(t0:end,:)];'];
   eval(str);
end 

end % fn
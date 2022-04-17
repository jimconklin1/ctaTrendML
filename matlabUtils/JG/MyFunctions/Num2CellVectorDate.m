%
%__________________________________________________________________________
%
% Transform a date FROM NUM format TO a CELL vector 
%
%__________________________________________________________________________
function datecv = Num2CellVectorDate(mydate)

formatDate = 'yyyymmdd'; 
datecv(1) = cellstr(datestr(mydate(1), formatDate));
for i=2:size(mydate,1)
    datecv = [datecv, cellstr(datestr(mydate(i), formatDate))] ;
end
datecv=datecv';

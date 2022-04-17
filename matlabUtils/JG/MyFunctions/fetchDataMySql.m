%
%
function dmsqlTbl = fetchDataMySql(ctxDbConn, sqltableName, sqlFieldsName)
%
%
%__________________________________________________________________________
%
% Fetch data from MySql
% Input:
% dbConn is the database connection 
% sqlFieldsName is the list (cell) of fields in MySql
%    for e.g.: = {'stockNname', 'price', 'volume'};
% sqltableName is the name of the database in MySql
% A proper form for the query is: 
%         select stockNname, price, volume from p1_pos_renamed
% Output:
% a table contianing the data with the header
%__________________________________________________________________________
%
%
ncols = length(sqlFieldsName); % dimensions

% create string
if ncols == 1
    fn = cell2char(sqlFieldsName);
else
    fn = cell2char(sqlFieldsName(1));
    for j=2:ncols
        fn = [fn, ', ' , cell2char(sqlFieldsName(j))];
    end
end
sqlQuery = ['select ', fn, ' from ' , sqltableName];

curs = exec(ctxDbConn, sqlQuery);      % returns the cursor object curs
data = fetch(curs);                 % fetch the data from the Cursor  
%dmsql = cell2mat(data.Data);        % create array    

%construct the resulting table from the data and the column labels
dmsqlTbl = cell2table(data.Data, 'VariableNames', sqlFieldsName);



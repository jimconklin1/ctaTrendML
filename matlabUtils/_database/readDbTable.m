function tbl = readDbTable( dbConn, tableName )
    tbl = readDbQuery(dbConn, char(strcat('select * from', {' '}, tableName)));
end


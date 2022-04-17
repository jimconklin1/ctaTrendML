function tbl = readDbQuery( dbConn, query )
    %execute the query and get a Cursor
    cur = exec(dbConn, query);
        
    %get the resultset meta data, then extract the Column Labels into a
    %cell array of Matlab Strings
    meta = get(rsmd(cur));
    cols = cellfun(@(x) char(x(1,1)), meta.ColumnLabel, 'UniformOutput', false);

    %fetch the data from the Cursor
    data = fetch(cur);
    
    %construct the resulting table from the data and the column labels
    if (strcmp(data.Data, 'No Data'))
        tbl = cell2table(cell(0, length(cols)), 'VariableNames', cols);
    else
        tbl = cell2table(data.Data, 'VariableNames', cols);
    end
	close(cur);
end


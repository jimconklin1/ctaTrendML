function saveRapc3dMat(coreDb, runId, vals, varName)
    %outputId = runId;
    
    % this line has no effect.
    % coreDb.Conn.Constructor.getDatabaseConnection.setStatementCacheSize(1000);

    % https://docs.oracle.com/cd/E11882_01/java.112/e16548/oraperf.htm
    % https://docs.oracle.com/database/121/JAJDB/oracle/jdbc/OracleConnection.html
    % (I suspect batch size is 1, but can't find how to increase it.)
    
    % "Starting from Oracle Database 12c Release 1 (12.1), Oracle update 
    % batching is deprecated. Oracle recommends that you use standard 
    % JDBC batching instead of Oracle update batching."
    % Guessing this is Oracle batching (Matlab returns Oracle connection),
    % but how to change this to JDBC batching?
    % coreDb.Conn.Handle same as coreDb.Conn.Constructor.getDatabaseConnection
    % https://www.mathworks.com/matlabcentral/answers/102983-is-there-a-faster-alternative-to-insert-and-fastinsert-functions-in-the-database-toolbox-3-1-r14sp3
    ps = coreDb.Conn.Constructor.getDatabaseConnection.prepareCall( ...
      "{call rapc.rapc_run_pkg.out_dbl_3d(?,?,?,?,?)}");

    varId = coreDb.newRapcOut(runId, varName);
    sz = size(vals.values);
    for i = 1:sz(1)  % fund
        for j = 1:sz(2)  % measure
            for k = 1:sz(3)  % time horizon
                v = vals.values(i,j,k);
                if ~isinf(v) && ~isnan(v)
                    ps.setBigDecimal(1, varId);
                    ps.setDouble(2, vals.dim1(i));
                    ps.setDouble(3, vals.dim2(j));
                    ps.setDouble(4, vals.dim3(k));
                    ps.setDouble(5, v);
                    ps.addBatch();
                end % v
            end %k
        end %j
    end %i
    ps.clearParameters();
    ps.executeBatch();
end 
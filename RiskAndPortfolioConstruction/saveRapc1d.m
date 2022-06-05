function saveRapc1d(coreDb, runId, valMap, dimIds)
    %outputId = runId;

    ps = coreDb.Conn.Constructor.getDatabaseConnection.prepareCall( ...
      "{call rapc.rapc_run_pkg.out_dbl_1d(?,?,?)}");

    for varName = keys(valMap)
        varId = coreDb.newRapcOut(runId, varName);
        vals = valMap(string(varName));
        for i = 1:length(vals)
            d = dimIds(i);
            v = vals(i);
            if ~isinf(v) && ~isnan(v)
                ps.setBigDecimal(1, varId);
                ps.setDouble(2, d);
                ps.setDouble(3, v);
                ps.addBatch();
            end
        end
    end
    ps.clearParameters();
    ps.executeBatch();
end 
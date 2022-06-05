function saveRapc2d(coreDb, runId, valMap, dimIds)
    %outputId = runId;

    ps = coreDb.Conn.Constructor.getDatabaseConnection.prepareCall( ...
      "{call rapc.rapc_run_pkg.out_dbl_2d(?,?,?,?)}");

    for varName = keys(valMap)
        varId = coreDb.newRapcOut(runId, varName);
        vals = valMap(string(varName));
        sz = size(vals.data);
        for j = 1:sz(2)
            d2 = vals.header(j);
            for i = 1:sz(1)
                d1 = dimIds(i);
                v = vals.data(i,j);
                if ~isinf(v) && ~isnan(v)
                    ps.setBigDecimal(1, varId);
                    ps.setDouble(2, d1);
                    ps.setDouble(3, d2);
                    ps.setDouble(4, v);
                    ps.addBatch();
                end %if
            end
        end
    end
    ps.clearParameters();
    ps.executeBatch();
end 
function outData = postProcRapcOut(cfg, outStruct, outData)

if cfg.dataSrc == "EH"
    AUM = outStruct.ref.aum'; 
    outData.expPerformanceTable2 = addvars( ...
        outData.expPerformanceTable2,AUM, 'NewVariableNames', "AUM");
end % cfg.dataSrc == "EH"
    
end % function
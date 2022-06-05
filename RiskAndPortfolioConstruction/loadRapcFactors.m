function ret = loadRapcFactors(db, cfg)
    [startDt, endDt] = deal([]);
    if isfield(cfg, 'startDt')
      startDt = cfg.startDt;
    end
    if isfield(cfg, 'endDt')
      endDt = cfg.endDt;
    end

    fctQryStr =  ...
        "select * from arp.instrument_list_v i" + newline ...
      + " where i.set_cat = 'RAPC' and i.set_cd = 'FCTR_MS'" + newline ...
      + "order by i.seq_num";
    ret.equFactorRtns = db.getTsAsMatrix(fctQryStr, "INST_ID", "INST_NAME" ...
        , startDt, endDt, "R", "M");
    
    instIdStrList = join(string(ret.equFactorRtns.ids), ", ");
    bbQryStr =  ...
        "select inst_id, ext_inst_id from arp.inst_id_str_last_v ii" + newline ...
      + " where inst_id_type_cd = 'BB' " + newline ...
      + "   and inst_id in (" + instIdStrList + ")";

  [ds, ~] = select(db.Conn, bbQryStr);
  
  lkp = containers.Map(ds{:,'INST_ID'}, ds{:,'EXT_INST_ID'});
  
  ret.equFactorRtns.bbgTicker = strings(size(ret.equFactorRtns.ids));
  for i = 1:length(ret.equFactorRtns.ids)
      id = ret.equFactorRtns.ids(i);
      if lkp.isKey(id)
          ret.equFactorRtns.bbgTicker(i) = string(lkp(id));
      end % if 
  end % for i
  
end %function  

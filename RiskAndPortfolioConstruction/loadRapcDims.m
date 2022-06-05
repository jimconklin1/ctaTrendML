% Parameters:
%   * db - database connection, an object of type PubEqCoreDb
function ret = loadRapcDims(db, instIds)
  dbi = db.Db;
  
  % Load instrument dimension
  qry_id_map = ...
      "select i.inst_id, d.dim_id " + newline ...
    + "  from arp.instrument i " + newline ...
    + "  join rapc.rapc_out_dimension d on d.inst_id = i.inst_id " + newline ...
    + " where i.inst_type_cd in ('HF', 'FDG', 'IDX') " + newline ...
    + "   and d.dim_type_cd = 'I' ";
  [ds, ~] = select(dbi.Conn, qry_id_map);
  
  mappedInstIds = ds{:,'INST_ID'};
  unmapped = setdiff(instIds, mappedInstIds);
  
  % If any elements are missing, create them in the database.
  if ~isempty(unmapped)
    % create missing mappings
    db.mapRapcInstDims(unmapped);
    db.Conn.commit;
    
    % re-run the original query
    [ds, ~] = select(dbi.Conn, qry_id_map);
    mappedInstIds = ds{:,'INST_ID'};
    unmapped = setdiff(instIds, mappedInstIds);
    % If anything is still missing then something is wrong with our logic
    % (or perhaps a new instrument was added by another process).
    if ~isempty(unmapped)
        throw(MException('Assumption violation' ...
                , 'Failed to map all instruments to output dimensions'));
        
    end %if
  end % if
  
  ret.instruments = containers.Map(ds{:,'INST_ID'}, ds{:,'DIM_ID'});

  qry_fc = ...
      "select d.dim_id, d.dim_name " + newline ...
    + "  from rapc.rapc_out_dimension d " + newline ...
    + " where d.dim_type_cd = 'FC'";
  [ds, ~] = select(dbi.Conn, qry_fc);
  
  ret.factorClasses.map = containers.Map(ds{:,'DIM_NAME'}, ds{:,'DIM_ID'});
  
  ret.factorClasses.named.refinedAlpha = ret.factorClasses.map("Refined Alpha");
  ret.factorClasses.named.primaryAlpha = ret.factorClasses.map("Primary Alpha");
  ret.factorClasses.named.beta = ret.factorClasses.map("Beta");
  ret.factorClasses.named.arp = ret.factorClasses.map("ARP");
  ret.factorClasses.named.total = ret.factorClasses.map("Total");
  
  qry_months = ...
      "select d.dim_id, d.num " + newline ...
    + "  from rapc.rapc_out_dimension d " + newline ...
    + " where d.dim_type_cd = 'Mo' ";
  [ds, ~] = select(dbi.Conn, qry_months);
  ret.time.months = containers.Map(ds{:,'NUM'}, ds{:,'DIM_ID'});
  
  
end 
% loadRapcDb Load RAPC inputs from the database
% Parameters:
%   * db - database connection, an object of type PubEqCoreDb
%   * cfg - configuration object (settings)
%   * endYr, endMo - last month to load. If endYr=0, load everything
%   * startYr, startMo - first month to load. If startYr=0, load everything
% Right now the set of data comprises returns and market values (monthly)
function ret = loadRapcDb(db, cfg, insuranceCompany)

  endDt = [];
  if ~isfield(cfg, 'startDt') || isempty(cfg.startDt)
      cfg.startDt = '2012-07-01'; % not very clean but OK (copy on assignment)
  end
  startDt = cfg.startDt;
  if isfield(cfg, 'endDt')
     endDt = cfg.endDt;
  end
  src_tbl_name = "arp.rapc_inst_v";
  
  dbi = db.Db;

  if (isfield(cfg, 'useFactorLib') && cfg.useFactorLib)
    ret.equFactorRtns =  loadRapcFactorsFromLib(fullfile(cfg.rapcRootDir ...
        , 'factor'));
  else
    fctrs = loadRapcFactors(db, cfg);
    ret.equFactorRtns = fctrs.equFactorRtns;
  end % if
  hfQryStr = ...
      "select hf.inst_id, hf.inst_name " + newline ...
    + sprintf("  from %s hf ", src_tbl_name) + newline ...
    + " order by hf.inst_id ";

  ret.equHFrtns = db.getTsAsMatrix(hfQryStr, "INST_ID", "INST_NAME" ...
      , startDt, endDt, "R", "M");
  if ~isfield(cfg, 'opt') || ~isfield(cfg.opt, 'processMV') || cfg.opt.processMV
      ret.mktValue = db.getTsAsMatrix(hfQryStr, "INST_ID", "INST_NAME" ...
          , startDt, endDt, "MV", "M", insuranceCompany);
      % TODO: Keep NaNs and make the algorithm work with NaNs rather than 0s.
      %ret.equFactorRtns.values(isnan(ret.equFactorRtns.values)) = 0;
      %ret.equHFrtns.values(isnan(ret.equHFrtns.values)) = 0;
      ret.mktValue.values(isnan(ret.mktValue.values)) = 0;
  end % cfg.opt.processMV
  
  qry_style = ...
      "select s.style_name, hf.inst_name " ...
    + sprintf("  from %s hf ", src_tbl_name) ...
    + "  join arp.hdg_fund_style s on s.style_id = hf.style_id " ...
    + " order by hf.inst_id ";
  [ds, ~] = select(dbi.Conn, qry_style);
  
  lkp = containers.Map(ds{:,'INST_NAME'}, ds{:,'STYLE_NAME'});
  
  hdr_str = string(ret.equHFrtns.header);
  style = arrayfun(@(x) lkp(x), hdr_str, 'uniformoutput', false);

  ret.style.funds = style;
  ret.style.style = string(unique(ret.style.funds));
  ret.style.style = setdiff(ret.style.style, "hfIndex");
  ret.style.rptMap = containers.Map();
  ret.style.rptMap ("GlobMacroQuant") = ["GlobalMacro", "Quant"];
  ret.style.rptList = ret.style.style;
  
  for k = string(ret.style.rptMap.keys())
      ret.style.rptList = setdiff(ret.style.rptList, ret.style.rptMap(k));
  end % for k

  ret.style.rptList = [ret.style.rptList unique(string(ret.style.rptMap.keys()))];
  % temp. reordering for backward-compatibility and clean diff
  ret.style.rptList = ret.style.rptList([2,4,1,3]);
  
  % HFRXes are asset class "IDX", and *HFbkcst are "FDG"
  [ds, ~] = db.getInstrumentNames(["HF", "FDG", "IDX"]); 
  fundInstIds = ds{:,'INST_ID'};
  ret.ref.funds.idMap = containers.Map(ds{:,'INST_NAME'}, fundInstIds);

  [ds, ~] = db.getInstrumentNames(["IDX"]);
  factorInstIds = ds{:,'INST_ID'};
  ret.ref.factors.idMap = containers.Map(ds{:,'INST_NAME'}, factorInstIds);
  
  ret.ref.dim = loadRapcDims(db, union(fundInstIds, factorInstIds));
end 
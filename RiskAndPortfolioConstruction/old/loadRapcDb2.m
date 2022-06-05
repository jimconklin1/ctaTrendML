% loadRapcDb Load RAPC inputs from the database
% Parameters:
%   * dbi - database connection, an object of type DatabaseInterface
%   * endYr, endMo - last month to load. If endYr=0, load everything
%   * startYr, startMo - first month to load. If startYr=0, load everything
% Right now the set of data comprises returns and market values (monthly)
function ret = loadRapcDb2(dbi, endDt, startDt)

  if ~exist('startDt','var')
     startDt = '2012-07-01';
  end

  hfQryStr = ...
      "select hf.inst_id, hf.inst_name " + newline ...
    + "  from arp.hdg_fund_inst_v hf " + newline ...
    + " order by excel_seq_num ";

  ret.equHFrtns = dbi.getTsAsMatrix(hfQryStr, "INST_ID", "INST_NAME" ...
      , startDt, endDt, "R", "M");
  ret.mktValue = dbi.getTsAsMatrix(hfQryStr, "INST_ID", "INST_NAME" ...
      , startDt, endDt, "MV", "M");
  
  fctQryStr =  ...
      "select * from arp.instrument_list_v i" + newline ...
    + " where i.set_cat = 'RAPC' and i.set_cd = 'FCTR_MS'" + newline ...
    + "order by i.seq_num";
  ret.equFactorRtns = dbi.getTsAsMatrix(fctQryStr, "INST_ID", "INST_NAME" ...
      , startDt, endDt, "R", "M");

  % TODO: Keep NaNs and make the algorithm work with NaNs rather than 0s.
  ret.equFactorRtns.values(isnan(ret.equFactorRtns.values)) = 0;
  ret.equHFrtns.values(isnan(ret.equHFrtns.values)) = 0;
  ret.mktValue.values(isnan(ret.mktValue.values)) = 0;
  
  qry_style = ...
      "select s.style_name, hf.inst_name " ...
    + "  from arp.hdg_fund_inst_v hf " ...
    + "  join arp.hdg_fund_style s on s.style_id = hf.style_id " ...
    + " order by excel_seq_num ";
  [ds, ~] = select(dbi.Conn, qry_style);
  
  lkp = containers.Map(ds{:,'INST_NAME'}, ds{:,'STYLE_NAME'});
  
  hdr_str = string(ret.equHFrtns.header);
  style = arrayfun(@(x) lkp(x), hdr_str, 'uniformoutput', false);

  % style = ds{:,1};
  ret.mktValue.style = style;
end 
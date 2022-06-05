% loadRapcDb Load RAPC inputs from the database
% Parameters:
%   * dbi - database connection, an object of type DatabaseInterface
%   * endYr, endMo - last month to load. If endYr=0, load everything
%   * startYr, startMo - first month to load. If startYr=0, load everything
% Right now the set of data comprises returns and market values (monthly)
function ret = loadRapcDb(dbi, endYr, endMo, startYr, startMo)

  if ~exist('startYr','var')
     startYr = 2012;
  end
  
  if ~exist('startMo','var')
     startMo = 7;
  end
  %fileName = 'M:\Manager of Managers\Hedge\quantDev\DATA\RAPC\monthlyEquityARPandHFdata201901.mat';
  %rapcFileInput = load(fileName); % monthlyEquityARPandHFdata201812est.mat; varnames: equHFrtns equFactorRtns mktValue
  
  dateFilter = "";
  
  if endYr >0 
    dateFilter = sprintf("  and ((tm.yr < %s or (tm.yr = %s and tm.mo <= %s)) and (tm.yr > %s or (tm.yr = %s and tm.mo >= %s) ))" ...
        , num2str(endYr), num2str(endYr), num2str(endMo), num2str(startYr), num2str(startYr), num2str(startMo));
  else
    dateFilter = sprintf("  and (tm.yr > %s or (tm.yr = %s and tm.mo >= %s) )" ...
        , num2str(startYr), num2str(startYr), num2str(startMo));
  end % if
  
  qry_pattern = ...
      "select i.inst_name"...
    + "     , last_day(to_date( tm.yr ||'-'|| tm.mo ||'-01', 'yyyy-mm-dd')) as dt"...
    + "     , %s " ...
    + "  from arp.%s i " ...
    + "  join arp.ts_monthly tm on tm.inst_id = i.inst_id " ... 
    + " where %s " ...
    ... %+ "   and (tm.yr > 2012 or (tm.yr = 2012 and tm.mo >= 7))" ...
    + dateFilter ...
    + " order by %s, tm.yr, tm.mo";
  
  %qry_hf = sprintf(qry_pattern, "tm.rtn_frac" ...
  % Assumption: if we have returns, then we have market values as well.
  %qry_hf = sprintf(qry_pattern, "tm.rtn_frac, tm.market_value" ...
  qry_hf = sprintf(qry_pattern, "tm.rtn_frac, round(tm.market_value, 5) as market_value" ...
      , "hdg_fund_inst_v", "1=1", "i.excel_seq_num");
  dbHF = dbi.pivotTsQryAsStructMap(qry_hf, "DT", "INST_NAME");
  
  qry_fctr = sprintf(qry_pattern, "round(tm.rtn_frac, 5) as rtn_frac", "instrument_list_v" ...
      , "i.set_cat = 'RAPC' and i.set_cd = 'FCTR_MS'", "i.seq_num");
  
  ret.equFactorRtns = dbi.pivotTsQryAsStruct(qry_fctr, "DT", "INST_NAME");
  ret.equHFrtns = dbHF('RTN_FRAC');
  ret.mktValue = dbHF('MARKET_VALUE');

  % TODO: Keep NaNs and make the algorithm work with NaNs rather than 0s.
  ret.equFactorRtns.values(isnan(ret.equFactorRtns.values)) = 0;
  ret.equHFrtns.values(isnan(ret.equHFrtns.values)) = 0;
  ret.mktValue.values(isnan(ret.mktValue.values)) = 0;
  
  qry_style = ...
      "select s.style_name, hf.inst_name " ...
    + "  from arp.hdg_fund_inst_v hf " ...
    + "  join arp.hdg_fund_style s on s.style_id = hf.style_id " ...
    + " order by excel_seq_num ";
  [ds, metadata] = select(dbi.Conn, qry_style);
  
  lkp = containers.Map(ds{:,'INST_NAME'}, ds{:,'STYLE_NAME'});
  
  hdr_str = string(ret.equHFrtns.header);
  style = arrayfun(@(x) lkp(x), hdr_str, 'uniformoutput', false);

  % style = ds{:,1};
  ret.mktValue.style = style;
end 
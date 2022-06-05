function ret = loadRapcEH(db, cfg)
  cacheName = fullfile(cfg.EH.cacheTag,"Returns");
  
  cfg1 = cfg;
  nowDt = datenum(eomdate(datetime(cfg.endDt)));
  if (cfg.EH.monthsAhead >0)
      cfg1.fwdDt = dateToIsoStr(addtodate(nowDt,cfg.EH.monthsAhead, 'month'));
  end %if      

  % Only use cache is query parameters are the same as the one requested
  % todo: refactor into a separate group of parameters (will break RAPC).
  qryCfg.dbFundFilter = cfg.dbFundFilter;
  qryCfg.dbMinReturns = cfg.dbMinReturns;
  qryCfg.startDt = cfg.startDt;
  qryCfg.endDt = cfg.endDt;

  [loaded, cache] = loadCache(cacheName, cfg.dbMaxCacheAge);
  if (loaded && isfield(cache, 'qryCfg') && isequal(cache.qryCfg, qryCfg)) 
      ret = cache;
      return;
  end
  clear cache;
  %else
      %rtns = db.getEurekaHedgeTsAsMatrix("Return", cfg1);
      %[ret.equHFrtns, ret.futEquHFrtns] = splitTimeSeries(rtns, nowDt+1);
  ret.equHFrtns = db.getEurekaHedgeTsAsMatrix("Return", cfg1);
  %clear rtns;
  %end %if    
  if isfield(cfg.EH, 'loadAumTs') && cfg.EH.loadAumTs
      ret.aumTS = NaN(size(ret.equHFrtns.values));
      cfgAum = cfg1;
      cfgAum.EH.dbMinReturns = 0;
      aum = db.getEurekaHedgeTsAsMatrix("AUM", cfg1);
      aumIdMap = containers.Map(aum.header, 1:length(aum.header));
      for i = 1:length(ret.equHFrtns.header)
          if aumIdMap.isKey(ret.equHFrtns.header(i))
              aumIdx = aumIdMap(ret.equHFrtns.header(i));
              ret.aumTS(:, i) = aum.values(:, aumIdx);
          end % if
      end % for
  end % if
  

  [ref, ~] = db.getEurekaHedgeRef();
  % fund_id, fund_name, main_investment_strategy
  ret.ref.fund.idFwdMap = containers.Map(ref{:,'FUND_ID'}, ref{:,'FUND_NAME'});
  ret.ref.fund.idMap = containers.Map(ref{:,'FUND_NAME'}, ref{:,'FUND_ID'});
  styleMap = containers.Map(ref{:,'FUND_ID'}, ref{:,'MAIN_INVESTMENT_STRATEGY'});

  [aum, ~] = db.getEurekaHedgeTsSlice("AUM", cfg.endDt, cfg);
  sz = size(aum);
  if sz(1)==0 
      throw(MException('Data:Empty' ...
         , 'There are no funds that fit that criteria'));
  end 
  aumMap = containers.Map(aum{:,'FUND_ID'}, aum{:,'AMOUNT'}*0.001*0.001);
  ret.ref.aum = zeros(size(ret.equHFrtns.header));
  for i = 1:length(ret.equHFrtns.header)
      if aumMap.isKey(ret.equHFrtns.header(i)) 
          ret.ref.aum(i) = aumMap(ret.equHFrtns.header(i));
      end %if
  end %for
  
  hHeader = arrayfun(@(x) ret.ref.fund.idFwdMap(x), ret.equHFrtns.header, 'UniformOutput', false);
  ret.fundIdHeader = ret.equHFrtns.header;
  ret.equHFrtns.header = hHeader;
  
  ret.style.funds = string(arrayfun(@(x) styleMap(x), ret.fundIdHeader, 'UniformOutput', false));
  geoMap = containers.Map(ref{:,'FUND_ID'}, ref{:,'GEOGRAPHICAL_MANDATE'});
  ret.geoMandate.funds = string(arrayfun(@(x) geoMap(x), ret.fundIdHeader, 'UniformOutput', false));
  
  ret.style.style = string(unique(ret.style.funds));
  ret.dbFundFilter = cfg.dbFundFilter;
  
  cfg2 = cfg1;
  if isfield(cfg1, 'fwdDt')
      cfg2.endDt = cfg1.fwdDt;
  end % if
  fctrs = loadRapcFactors(db, cfg2);
  ret.equFactorRtns = fctrs.equFactorRtns;
  ret.qryCfg = qryCfg;
  saveCache(cacheName, ret);
  
end % func
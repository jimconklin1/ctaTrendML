% loadEurekaHedgeDb Load EH ref data and time series from the database
% Parameters:
%   * dbi - database connection, an object of type PubEqCoreDb
%   * filter - just that. Example: "dead = 'No' and geographical_mandate = 'Global'"
%   * dtFrom - any date in the starting month, optional, e.g. '2010-01-01'
%   * dtTo - any date in the ending month, optional, e.g. '2019-06-1'
function ret = loadEurekaHedgeDb(db, filter, dtFrom, dtTo)
    if ~exist('filter','var')
       filter = [];
    end
    if ~exist('dtFrom','var')
      dtFrom = [];
    end
    if ~exist('dtTo','var')
      dtTo = [];
    end
    
    ret.ref = db.getEurekaHedgeRef(filter);
    ret.mktValue = db.getEurekaHedgeTsAsMatrix("AUM", filter, dtFrom, dtTo);
    ret.returns = db.getEurekaHedgeTsAsMatrix("Return", filter, dtFrom, dtTo);
end 
%__________________________________________________________________________
%
% Time Series Uploading under a Chrone Structure Form
%__________________________________________________________________________
% x = uploaddatafield(ticker, firstdate, lastdate, varargin)
%--------------------------------------------------------------------------
% This function uploads a time series from a data base:
%
%               Bloomberg (default) - Haver - Comac
%
% The required argument arguments are:
%
%   - ticker   : name of the time series (compatible with the selected data
%                source)
%
%   - firsdate : first date of the time series (a string)
%   - lastdate : last date of the time series (a string)
%
%   - varargin is a set of optional parameters
%          . 'field'  : a particular field ('PX_LAST' default for Bloomberg)
%          . 'period' : data frequency ('daily' default)
%          . 'source' : the name of the data source: 'bloomberg' 'comac' or
%                     'haver'
%
%The result is a chrone structure x {.header, .dates, .data}
%
%--------------------------------------------------------------------------
% Examples:
%
% db = uploaddatafield('SPX Index', '01/31/1960', '03/25/2011', ...
%                 'data source', 'bloomberg')
% db = uploaddatafield('USDCAD FX', '01/31/1960', '03/25/2011', ...
%                 'data source', 'comac')
% db = uploaddatafield('ATNRG10@ALPMED', '01/31/1960', '03/25/2011', ...
%                 'data source', 'harver')
%__________________________________________________________________________
%
% © CQIS Project - S.Guglietta

function x = uploaddatafield(ticker, firstdate, lastdate, varargin)

%default
%--------------------------------------------------------------------------

%default parameters
        source     = 'bloomberg';
        field      = 'PX_LAST';
        frequency  = 'daily';

%optional parameters
i = 1;
while i <= length(varargin)
   arg = varargin{i};
   if ischar(arg)
      switch lower(arg)
          
          case {'field'}
              i = i + 1;
              field = varargin{i};
          case {'frequency'}
              i = i + 1;
              frequency = varargin{i}; frequency = lower(frequency);
          case {'data source','source','data base source'}
              i = i + 1;
              source = varargin{i}; source = lower(source);
      end
   end
   i = i + 1;
end


%retrieve data
%--------------------------------------------------------------------------
switch source
    
    case {'bloomberg','blp'}
        sourx  = eval('blp');
        db = history(sourx, ticker, field, firstdate, lastdate, frequency);
    
    case {'comac data base','comacdatabase','comac'}
        sourx = database('CTLONSQLDEV01', 'Matlab', 'Matlab');
        s = strcat('SELECT  DTS, MetricValue as PX_LAST  from QdwDev.dbo.vTimeSeries Where Metric = ''PX_LAST'' and ComacName=''', ...
                            ticker, ''' and DTS between ''', firstdate, ...
                                ''' and ''', lastdate, ''' order by DTS');
        sexec = exec(sourx,s);
        rdb  = fetch(sexec);
        close(rdb);
        rdb = rdb.Data;
    
    case {'haver','haver data base'}
        if iscell(ticker), ticker = char(cell2mat(ticker)); end
        hticker = strsplit(ticker, '@');
        haver_database = ...
        ['\\comac.local\london\AppData\Haver\dlx\data\' char(hticker(:,2)) '.dat'];%\\comac.local\london\Investment Team\1. Tools\Haver\DLX\Data\
        hdaily = haver(haver_database);
        db = fetch(hdaily, hticker(:,1), firstdate, lastdate);

end                                  

%build chrone structure
%--------------------------------------------------------------------------
switch source
    
    case {'bloomberg','blp'}
        db_t = db(:,1);
        if iscell(db_t(1)), db_t = cell2mat(db_t); end
        db_t = date2chronedate(db_t);
        close(sourx);
     
    case {'comac data base','comacdatabase','comac'}
        dbt = datestr(rdb(:,1),'yyyy-mm-dd');
        dbtstr = strcat(dbt(:,1:4),dbt(:,6:7),dbt(:,9:10));
        db_t = str2num(dbtstr);
        db(:,2) = cell2mat(rdb(:,2));
        close(sourx);
     
    case {'haver','haver data base'}
        db_t = db(:,1);
        db_t = date2chronedate(db_t);
    
end

%result
%--------------------------------------------------------------------------
x = chronebuilder(ticker, db_t, db(:,2));


classdef ModelContext < handle
    %Property Attributes: http://www.mathworks.com/help/matlab/matlab_oop/property-attributes.html
    
    %Constants
    properties (Constant, Access = private)
        TZSG = 'Asia/Singapore';
        TZTYO = 'Asia/Tokyo';
        TZLON = 'Europe/London';
        TZNYC = 'America/New_York';
        TZUTC= 'UTC';
    end
    
    %PUBLIC properties
    properties
        dtsg
        dtny
        dtutc
        conf
        dbConn
        bbgConn
    end
    
    %PRIVATE properties
    properties (SetAccess = private)
        positions = {}
        startTime = datestr(now, 'yyyy-mm-dd HH:MM:SS')
        normw = 0
    end
    
    %PUBLIC methods
    methods
        
        % **********************************************************
        % * Constructor
        % **********************************************************
        function obj = ModelContext(configFile, dtsg)
            if ~exist('dtsg','var')
                dtsg = 'today';
            end
            if ischar(dtsg)
                dtsg = strrep(dtsg, 'now', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
                dtsg = strrep(dtsg, 'today', datestr(today, 'yyyy-mm-dd'));
                dtsg = strrep(dtsg, 'yesterday', datestr(today-1, 'yyyy-mm-dd'));
                if size(dtsg,2) == 10
                    dtsg = sprintf('%s 00:00:00', dtsg);
                end
                
                obj.dtsg = datenum(datetime(dtsg,'InputFormat','yyyy-MM-dd HH:mm:ss'));
            else
                obj.dtsg = dtsg;
            end
            obj.dtny = tzConvert(obj.dtsg, ModelContext.TZSG, ModelContext.TZNYC);
            obj.dtutc= tzConvert(obj.dtsg, ModelContext.TZSG, ModelContext.TZUTC);

            if ~exist('configFile','var')
                configFile = 'prod.conf';
            end
            ctx = srSetup(configFile);
            obj.conf = ctx.conf;
            obj.dbConn = ctx.dbConn;
            obj.bbgConn = ctx.bbgConn;
        end

        % **********************************************************
        % * Add Positions
        % **********************************************************        
        function addPosition(obj, inst, weight, entrystartutc, entryendutc, tp, sl, modelid, tags, simpnl)
            if nargin < 5 || isempty('entryendutc'); entryendutc = entrystartutc; end
            if nargin < 6 || isempty('tp'); tp = []; end
            if nargin < 7 || isempty('sl'); sl = []; end
            if nargin < 8 || isempty('modelid'); modelid = obj.conf.id; end
            if nargin < 9 || isempty('tags'); tags = ''; end
            if nargin < 10 || isempty('simpnl'); simpnl = []; end
            obj.positions(end+1,:) = {inst, weight, entrystartutc, entryendutc, tp, sl, modelid, tags, simpnl};
        end

        % **********************************************************
        % * Set Raw / Positions vol (like 0.08 for 8%)
        % **********************************************************        
        function setNormalizeWeights(obj, normalize)
            obj.normw = normalize;
        end        
                
        % **********************************************************
        % * Get current allocation (trader, fund, capital, vol, live
        % **********************************************************        
        function alloc = getAllocation(obj, modelid)
            if nargin < 2 || isempty('modelid'); modelid = obj.conf.id; end
            tblalloc = dbQuery(obj.dbConn, sprintf('call get_model_allocation(''%s'',''%s'',''%s'',''%s'')', datestr(obj.dtsg, 'yyyy-mm-dd HH:MM:SS'), modelid, obj.conf.version, obj.conf.instance), {'hs_trader', 'hs_fund', 'capital', 'standardvol', 'targetvol', 'live'});
            if (~isempty(tblalloc))
                alloc = struct;
                alloc.hs_trader = tblalloc.hs_trader(1);
                alloc.hs_fund = tblalloc.hs_fund(1);
                alloc.capital = tblalloc.capital(1);
                alloc.standardvol = tblalloc.standardvol(1);
                alloc.targetvol = tblalloc.targetvol(1);
                alloc.live = tblalloc.live(1);
            else
                alloc = [];
            end
        end
        
        % **********************************************************
        % * Get current allocation (trader, fund, capital, vol, live
        % **********************************************************        
        function tbl = getLatestPositions(obj, dtsg)
            tbl = dbQuery(obj.dbConn, sprintf('call get_positions(''%s'',''%s'',''%s'',''%s'' - interval 1 second)', obj.conf.id, obj.conf.version, obj.conf.instance, datestr(dtsg, 'yyyy-mm-dd HH:MM:SS')), {'id', 'version', 'instance', 'dtsg', 'inst', 'weight', 'entrystartutc', 'entryendutc', 'tp', 'sl', 'tags', 'simpnl'});
        end
        
        % **********************************************************
        % * Generate SimTracker OUTPUT
        % **********************************************************        
        function output = getOutput(obj)
            sb = java.lang.StringBuilder;
            %START marker
            sb.append('---START OUTPUT---').append(char(10)).append('{').append(char(10));
            
            %Configuration and Metadata
            sb.append('"startsg":').append(toJsonValue(obj.startTime)).append(',').append(char(10));
            sb.append('"endsg":').append(toJsonDate(now)).append(',').append(char(10));
            sb.append('"version":').append(toJsonValue(obj.conf.version)).append(',').append(char(10));
            sb.append('"instance":').append(toJsonValue(obj.conf.instance)).append(',').append(char(10));
            sb.append('"mode":').append(toJsonValue(obj.conf.mode)).append(',').append(char(10));
            sb.append('"env":').append(toJsonValue(obj.conf.TSRP_env)).append(',').append(char(10));
            sb.append('"dtsg":').append(toJsonDate(obj.dtsg)).append(',').append(char(10));
            sb.append('"dtny":').append(toJsonDate(obj.dtny)).append(',').append(char(10));
            sb.append('"dtutc":').append(toJsonDate(obj.dtutc)).append(',').append(char(10));
            sb.append('"normw":').append(toJsonValue(obj.normw)).append(',').append(char(10));
            sb.append('"username":').append(toJsonValue(getenv('username'))).append(',').append(char(10));
            sb.append('"userdomain":').append(toJsonValue(getenv('userdomain'))).append(',').append(char(10));
            sb.append('"computername":').append(toJsonValue(getenv('computername'))).append(',').append(char(10));
            sb.append('"isdeployed":').append(toJsonValue(isdeployed)).append(',').append(char(10));
            
            %Positions
            sb.append('"positions": [');
            for r = 1:size(obj.positions,1)
                sb.append(char(10));
                sb.append('  {"inst":').append(toJsonValue(obj.positions{r,1}));
                sb.append(', "weight":').append(toJsonValue(obj.positions{r,2}));
                sb.append(', "entrystartutc":').append(toJsonDate(obj.positions{r,3}));
                sb.append(', "entryendutc":').append(toJsonDate(obj.positions{r,4}));
                sb.append(', "tp":').append(toJsonValue(obj.positions{r,5}));
                sb.append(', "sl":').append(toJsonValue(obj.positions{r,6}));
                sb.append(', "id":').append(toJsonValue(obj.positions{r,7}));
                sb.append(', "tags":').append(toJsonValue(obj.positions{r,8}));
                sb.append(', "simpnl":').append(toJsonValue(obj.positions{r,9}));
                sb.append('},');
            end
            if size(obj.positions,1) > 0
                sb.deleteCharAt(sb.length() - 1);
            end
            sb.append(']').append(char(10));
            
            %END marker
            sb.append('}').append(char(10)).append('---END OUTPUT---').append(char(10));
            output = sb.toString();
        end

        
        % **********************************************************
        % * Convenience timezone convesion functions
        % **********************************************************                
        function dtutc = getTyoUtc(~, dateonly, h, m, s)
            dtutc = tzConvert(datenum([year(dateonly) month(dateonly) day(dateonly) h m s]),  ModelContext.TZTYO,  ModelContext.TZUTC);
        end

        function dtutc = getLonUtc(~, dateonly, h, m, s)
            dtutc = tzConvert(datenum([year(dateonly) month(dateonly) day(dateonly) h m s]),  ModelContext.TZLON,  ModelContext.TZUTC);
        end

        function dtutc = getNycUtc(~, dateonly, h, m, s)
            dtutc = tzConvert(datenum([year(dateonly) month(dateonly) day(dateonly) h m s]),  ModelContext.TZNYC,  ModelContext.TZUTC);
        end
    end
    
end

% **********************************************************
% * Miscelaneous Helper Functions
% **********************************************************        
function dt = tzConvert(srcdt, srctz, dsttz)
    t1 = java.util.GregorianCalendar(java.util.TimeZone.getTimeZone(srctz));
    t1.set(year(srcdt), month(srcdt)-1, day(srcdt), hour(srcdt), minute(srcdt), second(srcdt))

    t2 = java.util.GregorianCalendar(java.util.TimeZone.getTimeZone(dsttz));
    t2.setTimeInMillis(t1.getTimeInMillis());

    javaSerialDate = t2.getTimeInMillis() + t2.get(t2.ZONE_OFFSET) + t2.get(t2.DST_OFFSET);
    dt = datenum([1970 1 1 0 0 javaSerialDate / 1000]);
end

function str = toJsonValue(x)
    if isnumeric(x)
        if isempty(x)
            str = 'null';
        else
            str = num2str(x,16);
        end
    elseif ischar(x)
        str = sprintf('"%s"', strrep(strrep(x, '\', '\\'), '"', '\"'));
    elseif islogical(x)
        if x
            str = '1';
        else
            str = '0';
        end
    else
        str = x;
    end 
end

function str = toJsonDate(x)
    str = sprintf('"%s"', datestr(x, 'yyyy-mm-dd HH:MM:SS'));
end

function tbl = dbQuery(dbConn, query, cols)
    data = fetch(dbConn, query);
    if isempty(data)
        tbl = [];
    else
        tbl = cell2table(data, 'VariableNames', cols);
    end
end

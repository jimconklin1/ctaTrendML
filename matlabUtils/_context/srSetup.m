function ctx = srSetup(configFile)
%SRSETUP Reads a config file and creates the signal runner CONTEXT
%The CONTEXT is the only communication with the outside world.
%   Context fields:
%   conf:       a struct with of simple key -> string value
%
%   dbConn:     a Database Connection (to a signal specific database)
%               if not configured, this field will not exist in ctx
%
%   bbgConn:    a Bloomberg Connection for BBG/SAPI calls
%               if not configured, this field will not exist in ctx

%create the return struct
ctx = struct;

%conf
ctx.conf = readconf(configFile);

%dbConn
if isfield(ctx.conf, 'DB_url')
    ctx.dbConn = database(ctx.conf.DB_database, ctx.conf.DB_username, ctx.conf.DB_password, ctx.conf.DB_driver, ctx.conf.DB_url);
end
%Program Files (x86)\CleverFiles\Disk Drill\
%bbgConn
if isfield(ctx.conf, 'blpIP')
    if strcmp(ctx.conf.blpIP,'127.0.0.1') || strcmp(ctx.conf.blpIP, 'localhost')
        ctx.bbgConn = blp;
    else
        ctx.bbgConn = blp(8194, ctx.conf.blpIP, 0); 
    end    
end

%initialize TSRP
if ~isfield(ctx.conf, 'TSRP_user')
    ctx.conf.TSRP_user = '';
    ctx.conf.TSRP_hash = '';
end
tsrp.init(ctx.conf.TSRP_env, ctx.conf.TSRP_user, ctx.conf.TSRP_hash);

end
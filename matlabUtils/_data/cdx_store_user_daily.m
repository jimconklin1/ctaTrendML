function cdx_store_user_daily(id, tbl, overwrite)
import tsrp.*
global TSRP_CONF
if isempty(TSRP_CONF); tsrp.init(); end

meta.src = 'matlab';
meta.username = getenv('username');
meta.userdomain = getenv('userdomain');
meta.computername = getenv('computername');
b64 = char(org.apache.commons.codec.binary.Base64.encodeBase64(unicode2native(tsrp.mat2json(meta))))';

csv = cdx_tstable2csv(tbl);
gabbro = sprintf('https://%s/dput/%s?overwrite=%s', get_host(), id, num2str(overwrite));
webwrite(gabbro, csv, weboptions('Username', TSRP_CONF.user, 'Password', TSRP_CONF.hash,'KeyName','tsrpmetajson','KeyValue',b64,'Timeout',60));
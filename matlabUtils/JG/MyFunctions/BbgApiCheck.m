
function ConBbg = BbgApiCheck(method)

% -- Check Bbg API connection --
APIcheck = javaclasspath('-dynamic');
if sum(strcmp(APIcheck,'C:\blp\DAPI\blpapi3.jar')) < 1
   javaaddpath('C:\blp\DAPI\blpapi3.jar')
end % if

switch method
    
    case {'computer', 'local'}
        ConBbg = blp;%(8194,'10.50.100.120')
        
    case {'server','serv'}
        ConBbg = blp(8194,'10.60.51.91',0);
        %c = blpsrv(14008361,'10.14.172.19',8194);
        
end
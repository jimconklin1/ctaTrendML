function [ conn ] = srPersistentBbgConn( blpIP )
%SRPERSISTENTBBGCONN Get a persistent Bbg connection
%   A "persistent" connection is created only the fisrt time this function
%   is called. Subsequent calls will return the same connection object
%   which was created on the first call, effectively reusing it.
%   This is particularly useful for Parallel Loops, since Bbg connections
%   are not serializable, thus need to be established at least once for
%   each worker.
persistent persistentConn

if isempty(persistentConn)
    if strcmp(blpIP,'127.0.0.1') || strcmp(blpIP, 'localhost')
        persistentConn = blp;
    else
        persistentConn = blp(8194, blpIP, 0); 
    end
end
    
conn = persistentConn;
end


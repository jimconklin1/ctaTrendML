%
%__________________________________________________________________________
%
% configuration file
%__________________________________________________________________________


function configData  = usSectRotConfiguration(dataSource)

if strcmp(dataSource, 'tsrp')
    % start date for update
    startDate = '1998-12-31';
    configData.startDate = startDate;
    configData.dataSource = 'tsrp';
elseif strcmp(dataSource, 'bbgLocal') ||  strcmp(dataSource, 'BbgLocal')    
    % start date for update
    startDate = '12/31/1998';
    configData.startDate = startDate;
    configData.dataSource = 'bbg';
    configData.bbgSource = 'local';
elseif strcmp(dataSource, 'bbgSapi') || strcmp(dataSource, 'bbgServer') || strcmp(dataSource, 'BbgSapi')  ||  strcmp(dataSource, 'BbgServer')   
    % start date for update
    startDate = '1/6/2004';
    configData.startDate = startDate;
    configData.dataSource = 'bbg';
    configData.bbgSource = 'server';    
end

% Transaction cost (in beep)
transCost = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20];
configData.transCost = transCost;

% AUM
aum = 10000000;
configData.aum = aum;

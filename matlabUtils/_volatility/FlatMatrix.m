
%
%__________________________________________________________________________
%
% Compute indicators
%
%__________________________________________________________________________
%

function dataTable = FlatMatrix(dateNumBase, x, varNames)
%

%dates = dateNumBase;  data  = x;  % variable for financial time series object
%datanames = TickerList;
%tsobj = fints(dates, data, datanames);          % create financial time series object
%tsmat = fts2mat(tsobj, 1);                      % convert it to matrix and add column for date (with ',1')
%datanames = ['date',TickerList];               % concatrnate date name & variabble names for table
%dataTable = array2table(tsmat,'VariableNames',datanames);
% varNames = ['date', TickerList];
% % get rid off illegal characters
% varNames = strrep(varNames,' PIT Comdty','');
% varNames = strrep(varNames,' PIT Index','');
% varNames = strrep(varNames,' Curncy','');
% varNames = strrep(varNames,' Index','');
% varNames = strrep(varNames,' ','');

varNames  = ['date', varNames'];
varValues = [dateNumBase, x];
dataTable = array2table(varValues , 'VariableNames', varNames);

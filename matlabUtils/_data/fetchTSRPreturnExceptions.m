function outStruct = fetchTSRPreturnExceptions(timeZone,config)

if strcmpi(timeZone,'TK')||strcmpi(timeZone,'tokyo')||strcmpi(timeZone,'asia')||strcmpi(timeZone,'japan')
   timeZone = 'Tokyo';
elseif strcmpi(timeZone,'NY')||strcmpi(timeZone,'NYC')||strcmpi(timeZone,'newyork')||strcmpi(timeZone,'americas')||strcmpi(timeZone,'us')
   timeZone = 'NY';
else
   timeZone = 'London'; 
end % if 

% 'fx.usdidr','fx.usdinr','fx.usdkrw','fx.usdmyr','fx.usdphp',
% 'fx.usdthb','fx.usdtwd','fx.eurczk','fx.eurhuf','fx.usdpln',
% 'fx.usdrub','fx.usdbrl','fx.usdclp','fx.usdcop',

switch timeZone
    case 'Tokyo'
        bbgIDs = {'IHN+1M BGNT Curncy','IRN+1M BGNT Curncy','KWN+1M BGNT Curncy','MRN+1M BGNT Curncy','PPN+1M BGNT Curncy',...
                  'NTN+1M BGNT Curncy'};
        temp1 = tsrp.fetch_bbg_daily_close(bbgIDs, config.startDate, config.endDate); 
        [tempDates1,temp1] = cleanTSRPdates(temp1(:,1),temp1(:,2:end)); 
        temp2 = transformFlatData(replAsstCnfg.assetHeader,tempDates1,temp1,replAsstCnfg.assetTransformCode); 

%         outStruct.tokyo.dates = {datenum({'31-Oct-2006 06:00:00';'01-Nov-2006 06:00:00';'03-Nov-2006 06:00:00';'04-Dec-2008 06:00:00';...
%                                           '26-Nov-2009 06:00:00';'29-Nov-2010 06:00:00';'29-Nov-2011 06:00:00';'28-Nov-2013 06:00:00'})';
%                                  []}; 
%         outStruct.tokyo.ids = {'fx.usdidr';
%                                ''}; 
%         outStruct.tokyo.values = {[-3.2931e-04,-4.3922e-04,0.0014,-0.0578,0.0027,0.0022,0.0044,0.0111];
%                                   {}}; 
    case 'London'
%         outStruct.london.dates = {datenum({'27-Oct-2008 16:00:00';'29-Oct-2008 16:00:00';'30-Oct-2008 16:00:00';'26-Nov-2009 16:00:00';...
%                                            '29-Nov-2011 16:00:00';'28-Nov-2013 16:00:00'; '29-Oct-2015 16:00:00'; '27-Nov-2015 16:00:00'})';
%                                   []};
%         outStruct.london.ids = {'fx.usdidr';
%                                 ''};
%         outStruct.london.values = {[9140/9105-1, 9195/9140-1, 9215/9195-1, -0.0014, 13619/13480-1, 13801/13742-1]; ...
%                                   {}}; 
    case 'NY'
%         outStruct.newyork.dates = {datenum({''; ''})'; ...
%                                    {}};
%         outStruct.newyork.ids = {''; 
%                                  ''}; 
%         outStruct.newyork.values = {[0,0]; ...
%                                     {}}; 
end
end % fn
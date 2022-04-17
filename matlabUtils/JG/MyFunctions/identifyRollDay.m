% Identify roll day
% JConklin                                                     Feb 2017
%__________________________________________________________________________
%{
Final Settlement Date:
The Final Settlement Date for a contract with the "VX" ticker symbol is 
on the Wednesday that is 30 days prior to the third Friday of the calendar month 
immediately following the month in which the contract expires. 
The Final Settlement Date for a futures contract with the "VX" 
ticker symbol followed by a number denoting the specific week of a calendar year 
is on the Wednesday of the week specifically denoted in the ticker symbol. 

If that Wednesday or the Friday that is 30 days following that Wednesday is a CBOE holiday, the Final Settlement Date for the contract shall be on the business day immediately preceding that Wednesday. 
%}

function rollDay = identifyRollDay(dateNum)
% pre-allocate
nsteps = size(dateNum,1);
rollDay = zeros(nsteps,1);

for i=1:nsteps
   tmpStart = dateshift(datetime(datestr(dateNum(i))),'start','month'); % get the 1st day of month
   tmpNextMonth = datemnth(datenum(tmpStart),1); % get the fisrt day of the following month
   tmpFri = dateshift(datetime(datestr(tmpNextMonth)),'dayofweek','friday',3);% get the 3rd Friday of the following month
   tmpImm = datenum(tmpFri)-30; % get the wednesday that is 30 days prior to the 3rd Friday of the following month
   if dateNum(i) == tmpImm
    rollDay(i) = 1;
   end
   
end
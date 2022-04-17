function  t = FormatTodayDate(PointDate)
%
%__________________________________________________________________________
%
% This function download Bloomberg data and clean the data in order to save
% it as a text file (dates are hell to deal with).
%__________________________________________________________________________
%

% Check if Month has been entered as duoble digit (04, and not 4 for
% instance)
t = PointDate;
if t(2) == '/'
    % Get month
    t_month = strcat('0', t(1));   
    % Get day
    if t(4) == '/'
        strcat('0', t(3)); % day
        t_year = t(5:8); % year
    elseif t(4) ~= '/'
        t_day = t(3:4); % day
        t_year = t(6:9); % year
    end        
elseif t(2) ~= '/' 
    % Get month
    t_month = t(1:2);
    % Get day
    if t(5) == '/'
        t_day = strcat('0', t(4));  % day
        t_year = t(6:9); % year
    elseif t(5) ~= '/' 
        t_day = t(4:5); % day
        t_year = t(7:10); % year
    end
end
t = strcat(t_year, t_month, t_day);
sest = str2double(t);
data = [sest, 0,0,0,0,0,0,0];
    


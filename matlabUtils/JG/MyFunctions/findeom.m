%__________________________________________________________________________
%
% this function assing a string value to the end of month
%__________________________________________________________________________
%

function eom = findeom(dateVector, method) 

nsteps=size(dateVector,1);

switch method
    case {'zeros','Zero', 'Zeros', 'z', 'Z'}
        eom=zeros(size(dateVector));
    case {'n','N', 'nan', 'Nan', 'NaN', 'NAN'}
        eom=NaN(size(dateVector));
end

%     formatDate = 'yyyymmdd'; tdayBase = datestr(data(:,1), formatDate); 
%     dateNumBase = data(:,1);

for i=1:nsteps-1
    if month(dateVector(i)) ~= month(dateVector(i+1))
        eom(i) = str2double(strcat(num2str(month(dateVector(i))), num2str(year(dateVector(i)))));
    end
end
        

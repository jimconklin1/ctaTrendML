function [datev, dateBbg, v1, v2, v3, v4, v5, v6, v7] = UploadBbgWrapper(path, method, Parameters)
%
%__________________________________________________________________________
%
% This macro upload a text file where Dates, Open, High, Low, Close, Volume
% Open Interest from a Bloomberg csv or text file have bee saved
% Input:
% path:   a string showing where the mat file.
% Method: either the code is used to retreieve a variable with a given name
%         or to loop through a list with Asset Key, Instrument Key or macro.
%         Essentially the same, but so far I have not founda way to code
%         this properly so i allow for three different fields name "asset,
%         "inst" or "macro" (for macro variable).
%
% "Parameters" is a structure:
%     - 1st col is ALWAYS Name of the Variable or Asset Key/ounter. i.e.the
%       position number of the instrument in the tickers' list
%     - 2nd col is ALWAYS "OptionRead": "1" for ".csv" file, "2" for ".text" file
%     - 3rd col is the FIELDS one wants to upload
%           . 1: retrieve 1 variable only (usually close)
%           . 2: retrieve 2 variables only (usually close & volume)
%           . 3: retrieve 2 variables only (usually close & volume & Open Interest)
%           . 4: retrieve 4 variables (usually Open, High, Low, Close)
%           . 5: retrieve 5 variables (usually Open, High, Low, Close, Volume)
%           . 6: retrieve 4 variables (usually Open, High, Low, Close, Volume, Open Interest)
%           . 7: retrieve 4 variables (usually Open, High, Low, Close, Volume, Open Interest and VWAP)
%     - 4th col is the name type. So far 5 names:
%           . 1: "asset"  
%           . 2: "inst"
%           . 3: "macro"
%           . 4: "swap"
%           . 5: "stock"
%
% Typical expression
% Retrieve Open, High, Low, Close, Volume and Open Interest for a Variable
% name from a .txt. file
% [dateM, dateNum, o, h, l, c, volu, opint] = UploadBbgCSVWrapper(path, 'varname', [{VarName},2,6]);  
% Retrieve Close and Volume and Open Interest loopinmg trhough a list from
% a .txt. file with name instrument.
% [dateM, dateNum, o, h, l, c, volu, opint] = UploadBbgCSVWrapper(path, 'list' ,[counter,2,2,2]);  
%__________________________________________________________________________

switch method
    
    case{'Variable Name', 'variable name', 'varname', 'VarName', 'varName', 'vn', 'VN', 'Name', 'name'}
              
        InstrumentName = char(Parameters(1,1)); % Name of Variable
        OptionRead = cell2mat(Parameters(1,2)); % Read ".csv" or ".txt" files
        Fields = cell2mat(Parameters(1,3)); % Nb of fields

        % -- Upload asset total history --
        if OptionRead == 1
            data = csvread(strcat(path,InstrumentName,'.txt'));
        elseif OptionRead == 2
            data = dlmread(strcat(path,InstrumentName,'.txt'));%, 'delimiter', ',',);
        end
        %
        % -- Extract Date string into double (str2num quicker than str2double) --
        nrows = length(data);
        datev = zeros(nrows,1);
        for i =1:nrows
            datep = num2str(data(i,1)); % double
            datev(i) = str2num(strcat(datep(1:4),datep(5:6), datep(7:8))); 
        end
        dateBbg = data(:,2);
        
        % -- Extract Fields --
        if Fields==1
            v1 = data(:,3);
        elseif Fields==2
            v1 = data(:,3);
            v2 = data(:,4);
        elseif Fields==3
            v1 = data(:,3);
            v2 = data(:,4);   
            v3 = data(:,5);
        elseif Fields==4
            v1 = data(:,3);
            v2 = data(:,4);  
            v3 = data(:,5);
            v4 = data(:,6);
        elseif Fields==5
            v1 = data(:,3);
            v2 = data(:,4);  
            v3 = data(:,5);
            v4 = data(:,6);    
            v5 = data(:,7); 
        elseif Fields==6
            v1 = data(:,3);
            v2 = data(:,4);  
            v3 = data(:,5);
            v4 = data(:,6);    
            v5 = data(:,7);   
            v6 = data(:,8);
        elseif Fields==7
            v1 = data(:,3);
            v2 = data(:,4);  
            v3 = data(:,5);
            v4 = data(:,6);    
            v5 = data(:,7);   
            v6 = data(:,8);    
            v7 = data(:,9);              
        end
        
        
    case{'list', 'counter', 'Counter', 'AssetNb', 'InstrumentNb', 'InstNb', 'InstKey'}    
        
        counter = Parameters(1,1); % Name of Variable
        OptionRead = Parameters(1,2); % Read ".csv" or ".txt" files
        Fields = Parameters(1,3); % Nb of fields  
        NameType = Parameters(1,4); % Type of Name
        
         % -- Upload asset total history --
        if NameType == 1        
            if OptionRead == 1
                data = csvread(strcat(path,sprintf('asset%d.mat', counter)));
            elseif OptionRead == 2
                data = dlmread(strcat(path,sprintf('asset%d.txt', counter)));%, 'delimiter', ',',);
            end
        elseif NameType == 2        
            if OptionRead == 1
                data = csvread(strcat(path,sprintf('inst%d.mat', counter)));
            elseif OptionRead == 2
                data = dlmread(strcat(path,sprintf('inst%d.txt', counter)));%, 'delimiter', ',',);
            end
        elseif NameType == 3        
            if OptionRead == 1
                data = csvread(strcat(path,sprintf('macro%d.mat', counter)));
            elseif OptionRead == 2
                data = dlmread(strcat(path,sprintf('macro%d.txt', counter)));%, 'delimiter', ',',);
            end      
        elseif NameType == 4        
            if OptionRead == 1
                data = csvread(strcat(path,sprintf('swap%d.mat', counter)));
            elseif OptionRead == 2
                data = dlmread(strcat(path,sprintf('swap%d.txt', counter)));%, 'delimiter', ',',);
            end       
        elseif NameType == 5        
            if OptionRead == 1
                data = csvread(strcat(path,sprintf('stock%d.mat', counter)));
            elseif OptionRead == 2
                data = dlmread(strcat(path,sprintf('stock%d.txt', counter)));%, 'delimiter', ',',);
            end             
        end
        %
        % -- Extract Date string into double (str2num quicker than str2double) --
        nrows = length(data);
        datev = zeros(nrows,1);
        for i =1:nrows
            datep = num2str(data(i,1)); % double
            datev(i) = str2num(strcat(datep(1:4),datep(5:6), datep(7:8))); 
        end
        dateBbg = data(:,2);
        %
        % -- Extract Fields --
        if Fields==1
            v1 = data(:,3);
        elseif Fields==2
            v1 = data(:,3);
            v2 = data(:,4);
        elseif Fields==3
            v1 = data(:,3);
            v2 = data(:,4);   
            v3 = data(:,5);
        elseif Fields==4
            v1 = data(:,3);
            v2 = data(:,4);  
            v3 = data(:,5);
            v4 = data(:,6);
        elseif Fields==5
            v1 = data(:,3);
            v2 = data(:,4);  
            v3 = data(:,5);
            v4 = data(:,6);    
            v5 = data(:,7); 
        elseif Fields==6
            v1 = data(:,3);
            v2 = data(:,4);  
            v3 = data(:,5);
            v4 = data(:,6);    
            v5 = data(:,7);   
            v6 = data(:,8);
        elseif Fields==7
            v1 = data(:,3);
            v2 = data(:,4);  
            v3 = data(:,5);
            v4 = data(:,6);    
            v5 = data(:,7);   
            v6 = data(:,8);    
            v7 = data(:,9);              
        end
   
end


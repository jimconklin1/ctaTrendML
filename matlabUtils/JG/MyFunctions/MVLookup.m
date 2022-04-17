function[Y,oexec] =  MVLookup(BenchmarkDate,x,method)
%
%__________________________________________________________________________
%
% This function computes the VLOOKUP and fills the blanks.
%
% INPUT
% BenchmarkDate  = Date on which the data has to be alligned
% x              = Data to allign. The first column is a date column
% method:        - 'normal' refers to a normal data
%                - 'ohlc' refers to a matrix of open, high, low and close
% if o, h or l is empty, it carries over the past close value.
% OUTPUT
% Y              = data alligned on BenchmarkDate
%__________________________________________________________________________
%
% Identify Dimensions------------------------------------------------------
Bnsteps=size(BenchmarkDate,1);
[nsteps,ncols]=size(x);
Y=zeros(Bnsteps,ncols);
%
% Convert Excel Date to Matlab Dates---------------------------------------
% Matlab Format
% B2M=x2mdate(BenchmarkDate);D2M=x2mdate(x(:,1));
% Convert to string
% B2Mstr=datestr(B2M);D2Mstr=datestr(D2M);
%
% VLOOKUP------------------------------------------------------------------
for i=1:Bnsteps
    TargetDate=BenchmarkDate(i);
    [row]=find(x==TargetDate);
    % Condition needed
    if size(row,1)>0
        Y(i,1)=x(row,1);
        Y(i,2:ncols)=x(row,2:ncols);
    end
end
% Re-input date
Y(:,1)=BenchmarkDate;

switch method
    case 'normal'
        nargout=1;
    case 'ohlc'
        nargout=2;
end

switch method
    case 'normal'
        for i=2:Bnsteps
            for j=2:ncols
                if Y(i,j)==0
                    Y(i,j)=Y(i-1,j);
                end
            end
        end
    case 'Normal'
        for i=2:Bnsteps
            for j=2:ncols
                if Y(i,j)==0
                    Y(i,j)=Y(i-1,j);
                end
            end
        end        
    case 'ohlc'
        for i=2:Bnsteps
            % Close
            if Y(i,5)==0
                Y(i,5)=Y(i-1,5);
            end
            % Create Open exec
            oexec=Y(:,2);
            %oexec(find(oexec==0))=isNaN;
            % Fill the blank Open, High, Low
            for j=2:4
                if Y(i,j)==0
                    Y(i,j)=Y(i-1,5);
                end
            end
        end     
    case 'OHLC'
        for i=2:Bnsteps
            % Close
            if Y(i,5)==0
                Y(i,5)=Y(i-1,5);
            end
            % Create Open exec
            ooexec=Y(:,2);
            % Fill the blank Open, High, Loww
            for j=2:4
                if Y(i,j)==0
                    Y(i,j)=Y(i-1,5);
                end
            end
        end           
end
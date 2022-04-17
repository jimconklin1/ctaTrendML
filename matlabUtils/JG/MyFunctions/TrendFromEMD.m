function [modes its] = TrendFromEMD(x,Nstd,NR,MaxIter,method,Lookback)
%
%__________________________________________________________________________
%
% test parameters to debug
% Nstd=0.1;NR=100;MaxIter=10;method='fixed';Lookback=40;
%
% Inputs
% - Nstd     = Number of stadnard deviations (if 0, then EMD, ususally,
%              0.1-0.5)
% - NR       = Number of realizations (from 30 to few hundreds)
% - MaxIter  = Max Iterations
% - Lookback = used only for 'rolling' method
% Outputs
%
%--------------------------------------------------------------------------
% Typical form: [modes its] = TrendFromEMD(x,0.1,100,10,'total',40);
%--------------------------------------------------------------------------
%
%__________________________________________________________________________
%
%
% Extract size
[nsteps,ncols]=size(x);
HistModes=zeros(nsteps,20);
HistIts=zeros(nsteps,20);
%
switch method
    case 'total'
        [modes , its]=ceemdan(x,Nstd,NR,MaxIter);
        modes=modes';
        its=its';
    case 'fixed'
        % find the first cell to start the code
        start_date=zeros(1,1);        
        for i=1:nsteps
            if ~isnan(x(i)) && x(i)~=0
                start_date(1,1)=i;
            break
            end
        end  
        MinNbPoints=30;
        for i=start_date(1,1)+MinNbPoints:nsteps
            % Run Model
            [modes , its]=ceemdan(x(start_date(1,1):i,1),Nstd,NR,MaxIter);
            % Assign
            modes=modes';
            [modes_rows,modes_col]=size(modes);
            if modes_col<=size(HistModes,2)
                HistModes(i,1:modes_col)=modes(modes_rows,1:modes_col);   
            else
                HistModes(i,1:20)=modes_rows(modes_rows,1:20); 
            end
            modes=HistModes;            
        end
    case 'rolling'
        % find the first cell to start the code
        start_date=zeros(1,1);        
        for i=1:nsteps
            if ~isnan(x(i)) && x(i)~=0
                start_date(1,1)=i;
            break
            end
        end  
        MinNbPoints=30;
        for i=start_date(1,1)+MinNbPoints+Lookback:nsteps
            % Run Model            
            [modes , its]=ceemdan(x(i-Lookback:i,1),Nstd,NR,MaxIter);
            % Assign
            modes=modes';
            [modes_rows,modes_col]=size(modes);
            if modes_col<=size(HistModes,2)
                HistModes(i,1:modes_col)=modes(modes_rows,1:modes_col);   
            else
                HistModes(i,1:20)=modes_rows(modes_rows,1:20); 
            end
            modes=HistModes;                     
        end
end

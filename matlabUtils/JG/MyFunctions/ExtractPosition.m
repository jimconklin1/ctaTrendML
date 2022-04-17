function[position] = ExtractPosition(X,method, p, RowIndex, NbColumns, SizeWing, AscendDescend)

%X=nfx;method='WingNbAssets';RowIndex=130;SizeWing=4; AscendDescend=1;p=p; NbColumns=ncols;
%__________________________________________________________________________
%
% This function extract the trading signals. 
% INPUT:
%           - The input 'X' is the output of any kind of Market Timing 
%             Reaction Function. X isa row vector and the ranking & signals
%             extraction is made on;y for a rw vector of this size
%           - p is the matrix of execution price, need to check if isnan
%           - RowIndex
%           - NbColumns: sometimes, one needs higher number of columns
%               for the ouput Position. This is the Column dimension of the
%               row vector "Position". We always have
%               NbColumns >= NbAssets=size(X,2)
%           - method
%               - 'TailCut': the higher, the further one picks an asset
%                   in thetail of the distribution
%               - 'WingNbAssets': The number of Assets oer wing
%           - SizeWing refers to the method
%               - 'TailCut' = SizeWing
%               - 'WingNbAssets' = SizeWing
%           - AscendDescend is the direction of the indicator
%               - AscendDescend = 1 ...> Buy the Highest ranks (Short the
%                 Lowest)
%               - AscendDescend = -1 ...> Short the Highest ranks (Buy the
%                 Lowest)
%__________________________________________________________________________

% PRELOCATE MATRIX & DIMESNIONS--------------------------------------------
NbAssets=size(X,2);
if NbColumns<NbAssets, NbColumns=NbAssets; end
position=zeros(1,NbColumns);
maxX=max(X); 
% IDENTIFY THE SIZE OF THE TAIL--------------------------------------------
switch method
    case 'TailCut'
    NbOfTrades=0;
    for j=1:NbAssets,
        if ~isnan(X(1,j)),
            NbOfTrades=NbOfTrades+1;
        end
    end
    %TailCut=4; 
    WingNbAssets=round(NbOfTrades/SizeWing);
    % EXTRACT------------------------------------------------------------------
    for j=1:NbAssets
        if  X(1,j)>maxX-WingNbAssets && ...
                ~isnan(p(RowIndex,j)) && ~isnan(X(1,j)) 
            position(1,j)=AscendDescend;
        elseif X(1,j)<=WingNbAssets && ...
                ~isnan(p(RowIndex,j)) && ~isnan(X(1,j)) 
            position(1,j)=-AscendDescend;
        else
            position(1,j)=0;
        end 
    end 
    case 'WingNbAssets'
    WingNbAssets=SizeWing;
    % EXTRACT------------------------------------------------------------------
    for j=1:NbAssets
        if  X(1,j)>maxX-WingNbAssets && ...
                ~isnan(p(RowIndex,j)) && ~isnan(X(1,j)) 
            position(1,j)=AscendDescend;
        elseif X(1,j)<=WingNbAssets && ...
                ~isnan(p(RowIndex,j)) && ~isnan(X(1,j)) 
            position(1,j)=-AscendDescend;
        else
            position(1,j)=0;
        end 
    end     
end
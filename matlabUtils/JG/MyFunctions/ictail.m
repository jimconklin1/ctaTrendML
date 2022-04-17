function[z] = ictail(method, x,y, lookback, tail)
%
%__________________________________________________________________________
%
% This function computes the IC for the tails of the distribution
%
% INPUT--------------------------------------------------------------------
% x         =   is a matrix of factors (n observations X m assets)
% y         =   asset price (n observations X m assets)
% lookback  =   lag between x and y (and therefore, lokkback is also the
%               period for the price returns
% tail      =   number for assets in each of the lower and upper tails
% method    =   Z-Scorise or do not Z-Scorise
%
% note: the problem is that sometimes data is missing and NaN prevent of
% computing correlation.  The code makes up for the NaN with the function 
% ''find(~all(isnan(XXX), 1))''
%
% note: the function makes use of the 'Delta', 'NominalRank' and
% 'ZScoreCrossSection' function
%
% OUTPUT-------------------------------------------------------------------
% z         =   IC.
%__________________________________________________________________________

% -- Identify Dimensions & Prelocate matrix --
[nsteps,ncols] = size(x); 
z = zeros(nsteps,1);
lowercolind_inuniverse = zeros(1,tail);
uppercolind_inuniverse = zeros(1,tail);
lowercolind_ingood = zeros(1,tail);
uppercolind_ingood = zeros(1,tail);

% -- Compute price returns --
rl = Delta(x,'roc',lookback);

% -- Run IC for tails -- 
for i=lookback+1:nsteps
    % -- Extract factor --
    fi = ExtractCleanFactor(i-lookback+1, y, x);
    % -- Retrieve the col index of the Non NaN values --
    colind_goodfi = find(~all(isnan(fi), 1));
    % -- Extract the matrix of Non NaN --
    goodfi = fi(1,colind_goodfi);
    % -- Z-Scorise or Do not Z-Scorise in the cross-section --
    switch method
        case {'zscore', 'z-score', 'zscorise', 'z-scorise'}
            zi = ZScoreCrossSection(goodfi,[-3,3]);
        case {'raw', 'gross', 'do not zscorise', 'no zscore', 'nozscore', 'no z-score', 'no-z-score', 'no zscorise', 'no-zscorise', 'no-z-scorise'}
            zi = goodfi;
    end
    if size(zi,2) > 3*tail
        % -- Nominal rank the factors --
        nzi = NominalRank(zi','excel')';
        % -- Extract Lower-Tail column Indices for each asset --
        index=0;
        for u=1:size(nzi,2)
            if nzi(1,u) <= tail
                index = index + 1;
                % Extract Column Index in Initial universe (non purged from NaN)
                lowercolind_inuniverse(1,index) = colind_goodfi(1,u);
                % Extract Column Index in good (purged from NaN)
                lowercolind_ingood(1,index) = u;
            end
        end
        % -- Extract Upper-Tail column indices for each asset --
        index=0;
        for u=1:size(nzi,2)
            if nzi(1,u) > size(nzi,2) - tail
                index = index+1;
                % Extract Column Index in Initial universe (non purged from NaN)
                uppercolind_inuniverse(1,index) = colind_goodfi(1,u);
                % Extract Column Index in good (purged from NaN)
                uppercolind_ingood(1,index) = u;            
            end
        end    
        % -- Concatenate column indices --
        colind_inuniverse = [lowercolind_inuniverse , uppercolind_inuniverse];
        colind_ingood = [lowercolind_ingood , uppercolind_ingood];
        % note: size(colind_ingood,2) = size(colind_inuniverse,2)
        colind = size(colind_ingood,2);
        enzi=zeros(1,colind);
        erl=zeros(1,colind);
        % -- Compute IC between lagged factor & today price returns --
        for vvv=1:colind
            % Lagged Factor (Use coloumn index in purged universe)
            enzi(1,vvv) = zi(1,colind_ingood(vvv)) ;
            % Return (use column index in Non-Purged Universe)
            erl(1,vvv) = rl(i,colind_inuniverse(vvv)) ;
        end
        z(i,1)=corr(enzi',erl');
    else
        z(i,1)=z(i-1,1);
    end
end


function rmodos = Rollingeemd(x, Nstd, NR, MaxIter)
%--------------------------------------------------------------------------
% This function uses the file emd.m developed by Rilling and Flandrin.  
% http://perso.ens-lyon.fr/patrick.flandrin/emd.html
% Parameters for eemd
%[modos its]=eemd(c,0,1,10);
% -------------------------------------------------------------------------


% -- Dimension & Prelocations Matrix --
[nsteps,ncols]= size(x);
rmodos = zeros(nsteps, ncols, MaxIter);

MinimumSpan = 200;

for i = MinimumSpan : nsteps
    for j=1:ncols
        % extract vector
        xv = x(1:i,j);
        % run Empirical Mode Decomposition
        [modos , nbits] = eemd(xv, Nstd, NR, MaxIter);
        modos = modos';
        [nbrows_modos, nbcols_modos] = size(modos);
        % assign
        for u = 1:nbcols_modos
            % dimension
            % emd s'arrete apres une fois uqe ca a converge
            % nobre de modes est donc instable
            % on prend le parti pris d aggreger les modes les plus lentes a
            % partir de la fin
            rmodos(i,j,MaxIter - u +1 ) = modos(nbrows_modos, nbcols_modos - u + 1);
        end
    end
end

%Extract matrix
ExtractMatrix = 0;
if ExtractMatrix == 1
    MaxIter=10;
    ColIndex = 1;
    mymat = zeros(nsteps,MaxIter);
    for u=1:MaxIter
        mymat(:,u) = rmodos(:,ColIndex,u);
    end
end


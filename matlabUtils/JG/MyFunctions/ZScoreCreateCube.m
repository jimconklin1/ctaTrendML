%
%__________________________________________________________________________
%
% Create a cube of z score for several parameters
% lookbacks: a 1xu row vector
% parameters: a 1x3 structure
% .....parameters(1,1) = lower bound
% .....parameters(1,2) = upper bound
% .....parameters(1,3) = direction (+1/-1)
%lookbacks = [10,20, 30, 40, 50, 60, 80, 100];
%y =  ZScoreCreateCube(x, 'za', [10,20, 30, 40, 50, 60, 80, 100], [-3,3,1])
%__________________________________________________________________________
%

function y =  ZScoreCreateCube(x, method, lookbacks, parameters)

% -- dimensions & prelocation of matrices --
[nsteps,ncols] = size(x);
nbLookbacks = size(lookbacks,2);
y = zeros(nsteps,ncols,nbLookbacks);

for u=1:nbLookbacks 
    y(:,:,u) =  ZScore(x,method,lookbacks(1,u),[parameters(1,1),parameters(1,2)],parameters(1,3));
end


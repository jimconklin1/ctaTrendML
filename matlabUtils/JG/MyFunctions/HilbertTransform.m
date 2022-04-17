%__________________________________________________________________________
% 
%                                   HILBERT TRANSFORM

% This function computes the Hilbert Transform which helps finding the
% cycle in a time series.
% The Hilbert transform is based on the separation of the cycle,
% represented by a Phasor, into two components:
%      - the Quadrature
%      - and the the InPhase
% Phasor: If a cycle is present, the observed variable makes a revolution around a circle. 
% The Phasor can be construed as an arrow (vector) pointing out from the center of the circle.
% The Phasor (this vector) is :
%      - straight up when the cycle peaks, 
%      - and straight down when the cycle valleys.
% The Quadrature is the Ordinate, and the InPhase the Abscisse of the Phasor (vector) projected on the axis of the circle.

% The Hilbert transform can be applied on the level of the detrended
% time series (detrended time series = time series - moving average). 
% The user has then the choice between 2 methods: 'level' or 'difference'.
% The 'parameters' is a structure, the second argument being the lookback period for the moving
% average if the 'difference' method is chosen.

% Inputs. the user needs to define the 'parameters' as a structure
% parameters(1) is the alpha. Usually 'alpha'=0.07.
% Lower (higher) value for 'alpha' produces less (more) peaks and valleys.
% As mentionned above, parameters(2) is the lookback period for the
% detrended time series if the 'difference' method is chosen.

% 4 output are available:
%      - The Quadrature
%      - The InPhase
%      - The Quadrature as a percentage of the variable
%      - The InPhase as a percentage of the variable

% The Code is the translated from the TradeStation code of P. Kaufman,
% "New Trading Systems and Methods", 4th edition, p. 473
%
% Joel Guglietta - 2010
%__________________________________________________________________________

function[quadrature,inphase,quap,inpp] = HilbertTransform(X,method,parameters)

%Prelocate the matrix & Dimensions
s=zeros(size(X));  
cycle=zeros(size(X));       smooth=zeros(size(X));
quadrature=zeros(size(X));  inphase=zeros(size(X));
deltaphase=zeros(size(X));  period=zeros(size(X));
quap=zeros(size(X));        inpp=zeros(size(X));
[nbsteps,nbcols]=size(X);


for j=1:nbcols
    % Step 1.: Find the 1st cell to start the code
    for i=1:nbsteps
        if ~isnan(X(i,j)) 
            start_date=i;
        break
        end
    end    
    % Step 2.: Detrend or not
    switch method
        case 'difference'
            alpha=parameters(1);            
            lookback_detrend=parameters(2);
            s(:,j)=X(:,j)- expmav(X(:,j),lookback_detrend);
            start_date=start_date+lookback_detrend+7;
        case 'level'
            s(:,j)=X(:,j);
            alpha=parameters(1);
            start_date=start_date+7;
    end    
    % Step 3.: Compute Smoothed component
    for i=start_date:nbsteps
        % Update Cycle & Smooth
        if i<start_date+7
            cycle(i,j)=s(i,j)-2*s(i-1)+s(i-1,j)/4;
        else
            smooth(i,j)=(s(i,j)+2*s(i-1,j)+2*s(i-2,j)+s(i-3,j))/6;
            cycle(i,j)=power((1-.5*alpha),2)*(smooth(i,j)-2*smooth(i-1,j)+smooth(i-2,j))+...
                       2*(1-alpha)*cycle(i-1,j)-...
                       power((1-.5*alpha),2)*cycle(i-2,j);
        end
        % Compute Quadrature & Inphase
        quadrature(i,j)=(0.0962*cycle(i,j)+0.5769*cycle(i-2,j)-.5769*cycle(i-4,j)+0.0962*cycle(i-6,j)) * ...
                        (.5+0.8*period(i-1,j));
        inphase(i,j)=cycle(i-3,j);
        % Update Deltaphase
        if quadrature(i,j)~=0 && quadrature(i-1,j)~=0 
            deltaphase(i,j)=(inphase(i,j)/quadrature(i,j)-inphase(i-1,j)/quadrature(i-1,j)) /...
                           (1+inphase(i,j)*inphase(i-1,j)/(quadrature(i,j)*quadrature(i-1,j)));
        end
        % Clean deltaphase
        if deltaphase(i,j)<0
            deltaphase(i,j)=deltaphase(i-1,j);
        end
        if deltaphase(i,j)>1.1
            deltaphase(i,j)=1.1;
        end   
        % Update period
        phasesum=0; 
        oldphasesum=0;
        dc=0;
        for count=1:40 % 40 is used to get a reasonable good iteration. Anything between 20 and 100 gives identical results
            phasesum = oldphasesum + deltaphase(i,j);
            if phasesum >= 6.28318 &&oldphasesum < 6.28318 
                dc=count+1;
                oldphasesum = phasesum;
            end
        end
        period(i,j)=0.5*dc+0.8*period(i-1,j);              
    end
    % Quadrature & Inphase as a % of price
    for i=start_date:nbsteps
        if ~isnan(s(i,j)) && ~isnan(quadrature(i,j)) && ~isnan(inphase(i,j)) && ...
                     s(i,j)~=0 && quadrature(i,j)~=0 && inphase(i,j)~=0
            quap(i,j)=quadrature(i,j)/s(i,j);
            inpp(i,j)=inphase(i,j)/s(i,j);
        else
            quap(i,j)=quap(i-1,j);
            inpp(i,j)=inpp(i-1,j);
        end
    end
end
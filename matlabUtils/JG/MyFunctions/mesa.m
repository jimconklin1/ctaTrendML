function [mama,fama] = mesa(h,l,c, FastLimit, SlowLimit)
%
%__________________________________________________________________________
%
% Mother of Adaptative Moving Averages
% John F. Ehlers
% Adapatation is based on the rate of change as measured by the Hilbert
% Trasnform Discriminator.
% Advantage of the methode is that it features a fast attack average and
% slow decay average so that composite average rpaidly ratchets behind
% prices and holds the average value until the next ratchet occurs.
% By default
% FastLimit=0.5;
% SlowLimit=0.05;
% fama is the signal of mama
%
%__________________________________________________________________________

% Det defualt parameters if not input
if nargin<5
    FastLimit=0.5;
    SlowLimit=0.05;
end

% replace isnan by 0
c(isnan(c))=0;h(isnan(h))=0;l(isnan(l))=0;

% Prelocate matrices
[nsteps,ncols]=size(c);
smooth=zeros(size(c));  detrender=zeros(size(c));
Q1=zeros(size(c));      I1=zeros(size(c));
Q2=zeros(size(c));      I2=zeros(size(c));
period=zeros(size(c));  smoothPeriod=zeros(size(c));
im=zeros(size(c));      re=zeros(size(c));
jI=zeros(size(c));      jQ=zeros(size(c));
phase=zeros(size(c));   deltaPhase=zeros(size(c));
alpha=zeros(size(c));
fama=zeros(size(c));    mama=zeros(size(c));

% average price
p=(h+l)/2;
% initialise alpha
alpha(1:7,:)=0.05*ones(7,ncols);

for j=1:ncols
    
    for i=8:nsteps
        
        smooth(i,j) = (4*p(i,j)+3*p(i-1,j)+2*p(i-2,j)+p(i-3,j))/10;
        detrender(i,j)=(0.0962*smooth(i,j)+0.5769*smooth(i-2,j)-0.5769*smooth(i-4,j)-0.0962*smooth(i-6,j))*...
            (0.075*period(i-1,j)+0.54);
        
        % Compute InPhase and Quadrature components)
        Q1(i,j)=(0.0962*detrender(i,j)+0.5769*detrender(i-2,j)-0.5769*detrender(i-4,j)-0.0962*detrender(i-6,j))*...
            (0.075*period(i-1,j)+0.054);
        I1(i,j)=detrender(i-3,j);
        
        % Advance the phase of I1 and Q1 by 90 degrees
        jI(i,j)=(0.0962*I1(i,j)+0.5769*I1(i-2,j)-0.5769*I1(i-4,j)-0.0962*I1(i-6,j))*(0.075*period(i-1,j)+0.54);
        jQ(i,j)=(0.0962*Q1(i,j)+0.5769*Q1(i-2,j)-0.5769*Q1(i-4,j)-0.0962*Q1(i-6,j))*(0.075*period(i-1,j)+0.54);
        
        % Phasor addition for 3 bar-averaging
        I2(i,j)=I1(i,j)-jQ(i,j);
        Q2(i,j)=Q1(i,j)-jI(i,j);
        
        % Smooth I & Q components before applpying the discriminator
        I2(i,j)=0.2*I2(i,j)+0.8*I2(i-1,j);
        Q2(i,j)=0.2*Q2(i,j)+0.8*Q2(i-1,j);
        
        % Homodyne discriminator with smoothing
        re(i,j)=I2(i,j)*I2(i-1,j)-Q2(i,j)*Q2(i-1,j);
        im(i,j)=I2(i,j)*Q2(i-1,j)-Q2(i,j)*I2(i-1,j);
        re(i,j)=2*re(i,j)+0.8*re(i-1,j);
        im(i,j)=2*im(i,j)+0.8*im(i-1,j);
        
        if im(i,j)~=0 && re(i,j)~=0,            period(i,j)=360*atan(im(i,j)/re(i,j));  end
        if period(i,j) > 1.5*period(i-1,j),     period(i,j)=1.5*period(i-1,j);          end        
        if period(i,j) < 0.67*period(i-1,j),    period(i,j)=0.67*period(i-1,j);         end
        if period(i,j) < 6,                     period(i,j)=6;                          end
        if period(i,j)>50,                      period(i,j)=50;                         end
        period(i,j)=0.2*period(i,j)+0.8*period(i-1,j); % smooth
        smoothPeriod(i,j)=0.33*period(i,j)+0.67*smoothPeriod(i-1,j);
        
        if I1(i,j) ~=0,                         phase(i,j)=atan(Q1(i,j)/I1(i,j));       end
        deltaPhase(i,j) = phase(i-1,j)-phase(i,j);
        
        if deltaPhase(i,j)<1, deltaPhase(i,j)=1; end  % Update deltaPhase
        alpha(i,j)=FastLimit / deltaPhase(i,j);       % update alpha        
        
        if alpha(i,j)<SlowLimit, alpha(i,j)=SlowLimit;   end
        mama(i,j)=alpha(i,j)*p(i,j)+(1-alpha(i,j))*mama(i-1,j);
        fama(i,j)=0.5*alpha(i,j)*mama(i,j)+(1-0.5*alpha(i,j))*fama(i-1,j);        
        
    end
    
end


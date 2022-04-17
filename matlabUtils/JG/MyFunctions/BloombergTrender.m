function[adm,admup, admdown] = BloombergTrender(o,h,l,c,TrenderParameters)
%__________________________________________________________________________

% note---------------------------------------------------------------------
% This indicator rests upon the Trender designed by Bloomberg
% The Bloomberg's white paper is not very clear. This our interpretation.
%                             Copyright - Octis Asset Asset Management 2010
%--------------------------------------------------------------------------
%
% Parameters:
%
% atr_parameters:   atr_parameters(1,1) = period for the exponential moving 
%                                         average for ATR.
%                   atr_parameters(1,2) = period for the exponential moving
%                                         of the Mid Point.
%                   atr_parameters(1,3) = period for standard deviation of
%                                         the exponential moving average of
%                                         the ATR.
%                   atr_parameters(1,4) = number of standard deviations
%                                         away (sensitivity).
%
%__________________________________________________________________________
%atr_parameters=[5,0.5];

% Dimensions
nsteps=length(c);

% Pre-locate matrix
    % True Range        
    TR=zeros(size(c));    
    % Standard Deviation or (Exponential) Average True Range 
    STDEMATR=zeros(size(c));  
    % Adjusted mid point
    adm=zeros(size(c)); 
    admup=zeros(size(c)); 
    admdown=zeros(size(c)); 
    
    % Find start date
    start_date=zeros(1,1);
    for i=1:nsteps
        if ~isnan(c(i)) && c(i)~=0 && h(i)~=0 && l(i)~=0
            start_date(1,1)=i;
            break  
        end                                  
    end
    
% Step 1.: Compute True Range & Average True Range
    % 1.1. - True Range
    for i=start_date(1,1)+1:nsteps
        TR(i)=max(max(h(i)-l(i),abs(h(i)-c(i-1))), abs(l(i)-c(i-1)));
    end
    % 1.2. - Average True Range    
    EMATR=expmav(TR,TrenderParameters(1,1));
    % 1.3. - Standard Deviation of 
    for i=start_date(1,1)+1+1*TrenderParameters(1,1)+TrenderParameters(1,3):nsteps 
        STDEMATR(i)=std(EMATR(i-TrenderParameters(1,3)+1:i));
    end
% Step 2.: Compute The Mid-Point & Average Mid Point
MidPoint=(h+l)/2;
EMAMidPoint=expmav(MidPoint,TrenderParameters(1,2));
% Step 3.: Compute Adjusted Mid Point (Trender)
    % Initialize
    start_time=start_date(1,1)+1+TrenderParameters(1,1)+TrenderParameters(1,3);
    min_adm = MidPoint(start_time) - 0.5 * EMATR(start_time);
    max_adm = MidPoint(start_time) + 0.5 * EMATR(start_time);   
    if c(start_time)>min_adm
        adm(start_time)=min_adm;
    elseif c(start_time)<max_adm
        adm(start_time)=max_adm;
    end
    % Compute
    MethodTrender=3;
    
    if MethodTrender==1
        for i=start_time+1:nsteps 
            % Stay Long Trender
            if c(i-1)>adm(i-1) && c(i)>adm(i-1)
                if c(i)>c(i-1)
                    adm(i) = adm(i-1) + TrenderParameters(1,4) * STDEMATR(i);
                else
                    adm(i)=adm(i-1);
                end
            % Switch from Long Trender To Short Trender
            elseif c(i-1)>adm(i-1) && c(i)<adm(i-1)
                adm(i)=EMAMidPoint(i) + 0.5 * EMATR(i);  
            % Stay Short Trender            
            elseif c(i-1)<adm(i-1) && c(i)<adm(i-1)     
                if c(i)<c(i-1)
                    adm(i) = adm(i-1) - TrenderParameters(1,4) * STDEMATR(i);
                else
                    adm(i)=adm(i-1);
                end
            % Switch from Short Trender To Long Trender
            elseif c(i-1)<adm(i-1) && c(i)>adm(i-1)
                adm(i)=EMAMidPoint(i) - 0.5 * EMATR(i);              
            end
        end
    % 2nd METHODOLOGY------------------------------------------------------
    elseif MethodTrender==2
        % Build Trender
        for i=start_time+1:nsteps 
            % Trender UP...................................................
            if c(i)>adm(i-1)
                % Gross trender
                adm(i) = adm(i-1) + TrenderParameters(1,4) * STDEMATR(i);
                if adm(i)<adm(i-1)
                    adm(i) = adm(i-1);
                end
            % Switch from Trender Up to Trender Down.......................
            elseif c(i-1)>adm(i-1) && c(i)<adm(i-1)
                adm(i)=EMAMidPoint(i) + 0.5 * EMATR(i);  
            % Trender Down.................................................          
            elseif c(i)<adm(i-1)    
                % Gross trender
                adm(i) = adm(i-1) - TrenderParameters(1,4) * STDEMATR(i);
                if adm(i)>adm(i-1)
                    adm(i) = adm(i-1);
                end
            % Switch from Trender Down to Trender Up.......................
            elseif c(i-1)<adm(i-1) && c(i)>adm(i-1)
                adm(i)=EMAMidPoint(i) - 0.5 * EMATR(i);              
            end
        end  
    % 3rd METHODOLOGY------------------------------------------------------
    elseif MethodTrender==3
        admup(i) = admup(i-1) + TrenderParameters(1,4) * STDEMATR(i);
        admup(i) = admdown(i-1) - TrenderParameters(1,4) * STDEMATR(i);
         % Build Trender
        for i=start_time+1:nsteps 
            % Trender UP...................................................
            if c(i-1)>adm(i-1)
                % Gross trender
                adm(i) =adm(i-1) + TrenderParameters(1,4) * STDEMATR(i);% max(adm(i-1) + TrenderParameters(1,4) * STDEMATR(i),adm(i-1));
                if c(i)<EMAMidPoint(i) || l(i)<adm(i) || adm(i)<adm(i-1)
                    adm(i)=adm(i-1);
                end
            end
            % Trender Down.................................................          
            if c(i-1)<adm(i-1)    
                % Gross trender
                adm(i) = adm(i-1) - TrenderParameters(1,4) * STDEMATR(i);%min(adm(i-1) - TrenderParameters(1,4) * STDEMATR(i), adm(i-1));
                if c(i)>EMAMidPoint(i) || h(i)>adm(i) || adm(i)>adm(i-1)
                    adm(i)=adm(i-1);
                end
            end            
            % Switch from Trender Up to Trender Down.......................
            if c(i-1)>adm(i-1) && c(i)<adm(i)
                adm(i)=EMAMidPoint(i) + 0.5 * EMATR(i);  
            end
            % Switch from Trender Down to Trender Up.......................
            if c(i-1)<adm(i-1) && c(i)>adm(i)
                adm(i)=EMAMidPoint(i) - 0.5 * EMATR(i);              
            end
        end     
    % 4th METHODOLOGY------------------------------------------------------
    elseif MethodTrender==3
        admup(i) = admup(i-1) + TrenderParameters(1,4) * STDEMATR(i);
        admup(i) = admdown(i-1) - TrenderParameters(1,4) * STDEMATR(i);
         % Build Trender
        for i=start_time+1:nsteps 
            % Trender UP...................................................
            if c(i-1)>adm(i-1)
                % Gross trender
                adm(i) =adm(i-1) + TrenderParameters(1,4) * STDEMATR(i);% max(adm(i-1) + TrenderParameters(1,4) * STDEMATR(i),adm(i-1));
                if c(i)<EMAMidPoint(i) || l(i)<adm(i) || adm(i)<adm(i-1)
                    adm(i)=adm(i-1);
                end
            end
            % Trender Down.................................................          
            if c(i-1)<adm(i-1)    
                % Gross trender
                adm(i) = adm(i-1) - TrenderParameters(1,4) * STDEMATR(i);%min(adm(i-1) - TrenderParameters(1,4) * STDEMATR(i), adm(i-1));
                if c(i)>EMAMidPoint(i) || h(i)>adm(i) || adm(i)>adm(i-1)
                    adm(i)=adm(i-1);
                end
            end            
            % Switch from Trender Up to Trender Down.......................
            if c(i-1)>adm(i-1) && c(i)<adm(i)
                adm(i)=EMAMidPoint(i) + 0.5 * EMATR(i);  
            end
            % Switch from Trender Down to Trender Up.......................
            if c(i-1)<adm(i-1) && c(i)>adm(i)
                adm(i)=EMAMidPoint(i) - 0.5 * EMATR(i);              
            end
        end          
    end
function  rtnsOut  = s2dRtns( sessionrRtn, datesIn , datesOut )

% This function uses sessionrRtn to calculates retruns on the given times.  

% Inputs: 
%   sessionrRtn =  T by N array containing retruns ; 
%   datesIn = timestamps for the sessionrRtn (T by 1)
%   datesOut = timestamps where rerun is required (X by 1)

% Output: 
%   rtnsOut = X by N array containing retruns at datesOut timestamps
    

    t0= find (datesIn>datesOut(1), 1); 
    rtnsOut = nan (length(datesOut)  ,size(sessionrRtn,2));
    

    for t = 2:length(datesOut)
        while t0<=length(datesIn) && datesIn(t0)<=datesOut(t) 
           temp = [rtnsOut(t,:);sessionrRtn(t0,:)]; 
           tempCum= calcCum (temp,1)-1; 
           rtnsOut(t,:)= tempCum(end,:);
           rtnsOut(t,all(isnan(temp)))=nan;
           t0=t0+1; 
        end 
    end 






end


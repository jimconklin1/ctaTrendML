function tsStart = StartFinder(x, method)
%
%__________________________________________________________________________
%
% The function finds the non-zero and ~NaN of a tiem series
%__________________________________________________________________________
   
nbsteps=size(x,1);
tsStart=zeros(1,1);

switch method
    
    case {'zero','Zero','Non-zero', 'Non-Zero', 'non-zero', 'z', 'nz'}

        for i=1:nbsteps
            if x(i) ~= 0
                tsStart(1,1)=i;
            break               
            end                                 
        end
        
    case{'nan','NaN','isNaN', 'isNotNaN', 'n'}
        
        for i=1:nbsteps
            if ~isnan(x(i))
                tsStart(1,1)=i;
            break               
            end                                 
        end
        
    case{'znan','zeroNaN', 'nanz', 'nanzero', 'NaNZero'}
        
        for i=1:nbsteps
            if ~isnan(x(i)) && x(i) ~= 0
                tsStart(1,1)=i;
            break               
            end                                 
        end        
        
end

%
%__________________________________________________________________________
%
% Function to Compute FX return based on TSRP returns.
% TSRP daily returns are based on the Forward market. They embedd the spot
% return and the carry (as per C.I.P.).
% Two methodoligies are available:
% - 'TSRpReturn' uses returns as given by TSRO, i.e.:
%    spot RETURN + (NDF implied) carry daily return based on
%    a specific close (Tokoy, London, New York, ...)
% -  'tsrpImpliedCarry' allows the users to "impose" execution at the open
%    for the spot return and then adds the NDF-implied carry from tsrp.
%__________________________________________________________________________
%

function [grossreturn_i , tcforec_i, spotReturn_i, carry_i] = ...
    computefxReturnTsrp(method, i, c, p, tsrpReturn, tsrpImpliedCarry, s, wgt, DirectionQuote, TC)

%% -- Dimensions & prelocation of matrices --
[nsteps,ncols]=size(c);
grossreturn_i = zeros(1,ncols); 
tcforec_i = zeros(1,ncols);  
spotReturn_i = zeros(1,ncols); 
carry_i = zeros(1,ncols); 

%% - Mainb loop --
if strcmp(method, 'tsrpReturn') || strcmp(method, 'TsrpReturn') || strcmp(method, 'TsrpRet') || strcmp(method, 'tsrpRet')

    for j=1:ncols   
        % step 1: update parameters for transaction cost
        Ftc1=0;% Ftc1 = Factor when Trade Out
        Ftc2=0;% Ftc2 = Factor when Trade In
        Ftc3=0;% Ftc3 = Factor when Nb of shares is different for same signals
        if s(i-1,j)==s(i-2,j);
            Ftc1=0; % Factor when Trade Out
            Ftc2=0; % Factor when Trade In
        elseif s(i-2,j)==0 && s(i-1,j)~=0
            Ftc1=0; % Factor when Trade Out
            Ftc2=1; % Factor when Trade In
        elseif s(i-2,j)~=0 && s(i-1,j)==0
            Ftc1=1; % Factor when Trade Out
            Ftc2=0; % Factor when Trade In
        elseif (s(i-2,j)==1 && s(i-1,j)==-1) || (s(i-2,j)==-1 && s(i-1,j)==1)
            Ftc1=1; % Factor when Trade Out
            Ftc2=1; % Factor when Trade In
        end   
        % -- Ftc3 for weights-based equity curve --
        if s(i,j) ~= s(i-1,j) || (s(i,j) == s(i-1,j) && wgt(i,j) == wgt(i-1,j)) 
            Ftc3 = 0;
        elseif (s(i,j) == s(i-1,j) && wgt(i,j) ~= wgt(i-1,j)) 
            Ftc3 = 1;
        else
            Ftc3 = 0;
        end                 
        % step 2: return & trasnaction cost
        if ~isnan(c(i,j)) && ~isnan(c(i-1,j)) && c(i,j)~=0 && c(i-1,j)~=0
            spotReturn_i(1,j) =  s(i-1,j) * wgt(i-1,j) * (p(i,j)/p(i-1,j) - 1);
            % legacy : DirectionQuote - -1 for XXX/USD /\ 1 for USD/XXX
            grossreturn_i(1,j) = s(i-1,j) * wgt(i-1,j) * tsrpReturn(i,j);    
            carry_i(1,j) = grossreturn_i(1,j) - spotReturn_i(1,j);
            tcforec_i = Ftc1*TC(1,j)*wgt(i-2,j) + Ftc2*TC(1,j)*wgt(i-1,j) + Ftc3*TC(1,j)*abs(wgt(i-1,j)-wgt(i-2,j)); % wgt or nb
        else
            grossreturn_i(1,j) = 0; 
            tcforec_i(1,j) = 0;
        end
    end            

elseif strcmp(method, 'tsrpImpliedCarry') || strcmp(method, 'TsrpImpliedCarry') || strcmp(method, 'TsrpImpliedCarryOnly') || strcmp(method, 'tsrpImpliedCarryOnly')    
    
    for j=1:ncols   
        % step 1: update parameters for transaction cost
        Ftc1=0;% Ftc1 = Factor when Trade Out
        Ftc2=0;% Ftc2 = Factor when Trade In
        Ftc3=0;% Ftc3 = Factor when Nb of shares is different for same signals
        if s(i-1,j)==s(i-2,j);
            Ftc1=0; % Factor when Trade Out
            Ftc2=0; % Factor when Trade In
        elseif s(i-2,j)==0 && s(i-1,j)~=0
            Ftc1=0; % Factor when Trade Out
            Ftc2=1; % Factor when Trade In
        elseif s(i-2,j)~=0 && s(i-1,j)==0
            Ftc1=1; % Factor when Trade Out
            Ftc2=0; % Factor when Trade In
        elseif (s(i-2,j)==1 && s(i-1,j)==-1) || (s(i-2,j)==-1 && s(i-1,j)==1)
            Ftc1=1; % Factor when Trade Out
            Ftc2=1; % Factor when Trade In
        end   
        % -- Ftc3 for weights-based equity curve --
        if s(i,j) ~= s(i-1,j) || (s(i,j) == s(i-1,j) && wgt(i,j) == wgt(i-1,j)) 
            Ftc3 = 0;
        elseif (s(i,j) == s(i-1,j) && wgt(i,j) ~= wgt(i-1,j)) 
            Ftc3 = 1;
        else
            Ftc3 = 0;
        end                 
        % step 2: return & trasnaction cost
        if ~isnan(c(i,j)) && ~isnan(c(i-1,j)) && c(i,j)~=0 && c(i-1,j)~=0
            spotReturn_i(1,j) =  s(i-1,j) * wgt(i-1,j) * (p(i,j)/p(i-1,j) - 1);
            % legacy : DirectionQuote - -1 for XXX/USD /\ 1 for USD/XXX
            grossreturn_i(1,j) = spotReturn_i(1,j) + s(i-1,j) * wgt(i-1,j) * tsrpImpliedCarry(i,j);    
            carry_i(1,j) = grossreturn_i(1,j) - spotReturn_i(1,j);
            tcforec_i = Ftc1*TC(1,j)*wgt(i-2,j) + Ftc2*TC(1,j)*wgt(i-1,j) + Ftc3*TC(1,j)*abs(wgt(i-1,j)-wgt(i-2,j)); % wgt or nb
        else
            grossreturn_i(1,j) = 0; 
            tcforec_i(1,j) = 0;
        end
    end     
    
end

end

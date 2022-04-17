%
%__________________________________________________________________________
%
% Rebuild daily forward with spot and interest rate
% Input
% - close price spot
% - 1 mth (or month) interest rate
% direction of the quote (+1 for direct quotation, -1, for indirect
% quotation)
%__________________________________________________________________________
%

function y = buildforward(directionQuote, method, lastPrice, intRate, benchIntRate, YrNbDays)

[nsteps,ncols] = size(lastPrice);   % dimension

% note: contatenate for ease
switch method
    case {'open', 'o'}
        intRateTemp = [intRate, benchIntRate]; 
        % one day lag so that we use open with previous rate
        tempJunk = zeros(size(intRateTemp));
        tempJunk(2:nsteps,:)=intRateTemp(1:nsteps-1,:);
        tempJunk(nsteps,:)=tempJunk(nsteps-1,:);
        intRateTemp = tempJunk;
        clear tempJunk
    case {'close','c'}
        intRateTemp = [intRate, benchIntRate]; 
end

mymethod=2;

if mymethod == 1 % BT

    log_intRateTemp = 12*log(ones(nsteps,ncols+1)+intRateTemp/12);                                              % (Bg rate/100 already) contiuously compounded rate
    log_benchRate = log_intRateTemp(:,ncols+1);                                                                 % transformed bechmark interest rate
    difRate = repmat(directionQuote,nsteps,1) .* (repmat(log_benchRate,1,ncols) - log_intRateTemp(:,1:ncols))/YrNbDays ; % diff rate
    y = lastPrice .* exp(difRate);                                                                              % build daily forward

elseif mymethod == 2 % Millenium
    
    log_intRateTemp = log(ones(nsteps,ncols+1)+intRateTemp/YrNbDays);                                           % (Bg rate/100 already) contiuously compounded rate
    log_benchRate = log_intRateTemp(:,ncols+1);                                                                 % transformed bechmark interest rate
    difRate = repmat(directionQuote,nsteps,1) .* (repmat(log_benchRate,1,ncols) - log_intRateTemp(:,1:ncols));  % diff rate
    y = lastPrice .* exp(difRate);                                                                              % build daily forward    
    
elseif mymethod == 3
    
    intRateTemp = ones(nsteps,ncols+1)+intRateTemp/YrNbDays;                                                    % (Bg rate/100 already) contiuously compounded rate
    benchRate = intRateTemp(:,ncols+1);                                                                         % transformed bechmark interest rate
    difRate =  (repmat(benchRate,1,ncols) ./ intRateTemp(:,1:ncols)) .^ repmat(directionQuote,nsteps,1);         % diff rate
    y = lastPrice .*  difRate;                                                                                  % build daily forward       

end


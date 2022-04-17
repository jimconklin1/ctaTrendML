function oadjusted = fwdAdjustedNextOpen(o,fwd)

%__________________________________________________________________________
%
% THis function is needed as I often assume I am executed at next bar open
% based on previous bar close.
% Here, in order to compute a proxy of forward (outrright0 at next bar
% open, I use the forward point of previous bar close.
%
%__________________________________________________________________________


% dimensions & prelocation
nsteps = size(o,1);
oadjusted = zeros(size(o));

% Adjust tomorrow open with the fwd close
% assumption: I execute at next open adjusted with forward given at
%             previous close
oadjusted(1:nsteps-1,:) = o(2:nsteps,:) + fwd(1:nsteps-1,:) ./ 10000;
oadjusted(nsteps,:) = oadjusted(nsteps-1,:);

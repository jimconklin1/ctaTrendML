%_________________________________________
%
% Compute ManKendall for a time Series
%
% -- INPUT --
% x:       matrix ("ns" assets per "p" columns
% method: 'fixed' or 'rolling' whether you use a fixed window since the
%          start of the time series or a rolling window
% period:  only used for rollig window 
%          (quick code, so always pout bydefualt)
% alpha:   alpha (usually 0.05) to compute p-vlaue
% -- OUTPUT --
% h:       a matrix (nul hypothesis): 1 
%          [h=1] Reject of Null Hypthesis at the alpha significance level
%          [h=0] indicates a failure to reject the null hypothesis
%          at the alpha significance level.
% pvalue:  p-vlaue of the test (If the p-value is greater than alpha,
%          there is insufficient evidence to reject the null hypothesis
% 
%_________________________________________

function[h,pvalue,sumvalue] = MannKendallTs_ShowSum(x,method,period,alpha)

% -- Prelocate matrices --
[nsteps,ncols] = size(x);
h = zeros(size(x));
pvalue = zeros(size(x));
sumvalue = zeros(size(x));

% -- Minimum period to have statistical significan result --
% note: it seems that 200 is a minimum nb or point required
min_period = 20;

switch method
    % -- Man-Kendall Tau since the beginning of the time series --
	case {'fixed', 'static'}
        for j=1:ncols
            % extract 
            myx = x(:,j);
            % identify start time
            start_time = zeros(1,1);
            for i=1:nsteps
                if ~isnan(myx(i,1))
                    start_time(1,1)=i;
                    break
                end
            end
            % compute
            if start_time(1,1)>=1 && nsteps - start_time(1,1) > min_period
                for i= start_time(1,1) + min_period : nsteps
                    myy = myx(start_time(1,1):i,1);
                    [H,p_value] = Mann_Kendall(myy,alpha);
                    h(i,j) = H;
                    pvalue(i,j) = p_value;
                end
            end
        end
    % -- Man-Kendall Tau tcomputed on a rolling basis --
	case {'rolling' , 'expanding'}
        for j=1:ncols
            % extract 
            myx = x(:,j);
            % identify start time
            start_time = zeros(1,1);
            for i=1:nsteps
                if ~isnan(myx(i,1))
                    start_time(1,1)=i;
                    break
                end
            end
            % compute
            if start_time(1,1)>=1 && nsteps - start_time(1,1) > min_period
                if period < min_period
                    start_time_analysis = min_period;
                else
                    start_time_analysis = period;
                end
                for i = start_time(1,1) + start_time_analysis : nsteps
                    myy = myx(i - period + 1:i,1);
                    [H,p_value, s] = Mann_Kendall_ShowSum(myy,alpha);
                    h(i,j) = H;
                    pvalue(i,j) = p_value;
                    sumvalue(i,j) = s;
                end
            end
        end        
end
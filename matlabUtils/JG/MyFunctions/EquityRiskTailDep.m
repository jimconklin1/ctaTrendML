function etd = EquityRiskTailDep(riskfactor, assetname, pathname)


%__________________________________________________________________________
%
% This macro compute the equity risk-tail dependence between a given asset and
% the reference risk factor
%
% joel guglietta - February 2014
%__________________________________________________________________________

%
% -- Load Equity Risk Reference Factor --
path = pathname;
[tday1, tdaynum1, ~,~,~,c_ref] = UploadFuture(path, riskfactor, 'data');
% -- Load Target asset --
[tday2, tdaynum2, ~,~,~,c_target] = UploadFuture(path, assetname, 'data');

% -- Intersect time series --
tday = union(tday1, tday2); % find all the days when either Ref Asset or target Asset has data.
[junk idx idx1] = intersect(tday, tday1);
c_merged = NaN(length(tday), 2); % combining the two price series
% Equity Risk Reference Factor
c_merged(idx, 1) = c_ref(idx1);
% Target Asset
[junk idx idx2] = intersect(tday, tday2);
c_merged(idx, 2) = c_target(idx2);
% Clean
baddata = find(any(~isfinite(c_merged), 2)); % days where any one price is missing
tday(baddata)=[];
c_merged(baddata, :)=[];
%
%
% -- Equity Risk Reference Factor --
[nrows, ncols] = size(c_merged);
c_merged_tailrisk = zeros(nrows , 1);
for i=6:nrows
    if c_merged(i,1) >= 1.10 * c_merged(i-1,1) || ...
        c_merged(i,1) >= 1.10 * c_merged(i-2,1) || ...        
        c_merged(i,1) >= 1.10 * c_merged(i-3,1) || ...
        c_merged(i,1) >= 1.10 * c_merged(i-4,1) || ...
        c_merged(i,1) >= 1.10 * c_merged(i-5 ,1)
        c_merged_tailrisk(i,1) = c_merged(i,1) / c_merged(i-5 ,1) - 1;
        c_merged_tailrisk(i,2) = c_merged(i,2) / c_merged(i-5 ,2) - 1;
    else
        c_merged_tailrisk(i,1)=NaN;c_merged_tailrisk(i,2)=NaN;
    end
end    
%c_merged_tailrisk = [c_merged_tailrisk , c_merged(:,2)];
cmtr = c_merged_tailrisk(~any(isnan(c_merged_tailrisk),2),:);
nrows=length(cmtr);
%[b, stats] = robustfit(cmtr(nrows-100:nrows,1),cmtr(nrows-100:nrows,2));
b = robustfit(cmtr(nrows-100:nrows,1),cmtr(nrows-100:nrows,2));
equity_risktail_dependence = b(2,1);
etd = equity_risktail_dependence ;
    

%
%__________________________________________________________________________
%
% Map monthly macro data
%__________________________________________________________________________
%

function y = MapMonthlyMacro(MacFact, fm)

if length(MacFact) == length(fm)
    fm = [fm, MacFact(1,:)];
elseif length(MacFact) > length(fm)
    DifLength=length(MacFact)-length(fm);
    fm = [fm, MacFact(DifLength+1:length(MacFact))];
elseif length(MacFact) < length(fm)
    DifLength=length(fm)-length(MacFact);
    fm = [fm, zeros(length(fm),1)];
    fmNbCol=size(fm,2);
    fm(DifLength+1:length(fm),fmNbCol)=MacFact(:,1);
end  
y=fm;
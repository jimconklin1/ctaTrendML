% /* ************************************************************************ */
% /* dat_mdly : given a daily series obtain a monthly series
%
% Inputs:
%   	dly_ser	: daily series of returns or explanatory variables
%		       column 1 :     dates - ccyymmdd
%		       column 2 to n: monthly returns or monthly sum or end of month explanatory variables
%     cumOpt:  [optional] if cumOpt == 'Sum', we calculate the sum instead of the
%                       cum return; if cumOpt == 'EoM', we simply take the end
%                       of the month observation. If this augument is not
%                       provided or equals to ' ', we use cumulative
%                       return;
%     endOfMonthOption: [optional] 
% Outputs:
%	  err_flg : 0 if no error, 1 if error
%	  mon_ser : monthly data series:
%		          Column 1 : date : ccyymmdd (last day of each month)
%		          Column 2 to n: compounded daily return or end of the month
%		          explanatory variables.
% if only one output argument is specified, we will report mon_ser, not the
% error flag.
%
%	Note:	The last month could be a partial month
%
function [err_flg,mon_ser] = daily2monthly(dly_ser, cumOpt,endOfMonthOption)

if (nargin < 2);
  cumOpt = ' ';
elseif (~(strcmp(cumOpt,'Sum') || strcmp(cumOpt,'EoM') || strcmp(cumOpt,' ')));
  % wrong option supplied
  err_flg = 1;
  mon_ser = [];
  return;
end

if (nargin < 3);
  endOfMonthOption = 'STD';
end
err_flg=0;
i=2;
j=1;
mon_ser=zeros(1,cols(dly_ser));
while i<=rows(dly_ser);
  if (floor((dly_ser(i,1)/100)) ~= floor((dly_ser(i-1,1)/100)));
    if (strcmp(endOfMonthOption,'QFS'));
      eom = datEOM(dly_ser(i-1,1)); 
    else
      eom = dly_ser(i-1,1);
    end
    % /* Compute the cumulative realised monthly return */
    if (strcmp(cumOpt,'EoM'));
      c_ret = dly_ser(i-1,2:cols(dly_ser));
    elseif (strcmp(cumOpt,'Sum'));
      c_ret = sum(dly_ser(j:i-1,2:cols(dly_ser)))';
    else
      c_ret=(prodc(1+dly_ser(j:i-1,2:cols(dly_ser)))-1)';
    end
    mon_ser=[mon_ser ; [eom c_ret]];
    
    j=i;
  end
  i=i+1;
end

if abs(dly_ser(i-1,1)-mon_ser(rows(mon_ser),1)) > 1e-6;
  if (strcmp(endOfMonthOption,'QFS'));
      eom = datEOM(dly_ser(i-1,1)); 
  else
      eom = dly_ser(i-1,1);
  end
  if (dly_ser(i-1,1) < eom-1e-4);
    eom = dly_ser(i-1,1);
  end
  if (strcmp(cumOpt,'EoM'));
    c_ret = dly_ser(i-1,2:cols(dly_ser));
  elseif (strcmp(cumOpt,'Sum'));
    c_ret = sum(dly_ser(j:i-1,2:cols(dly_ser)))';
  else
    c_ret=(prodc(1+dly_ser(j:i-1,2:cols(dly_ser)))-1)';  % the last month %
  end
  mon_ser=[mon_ser ; [eom c_ret]];
end

mon_ser=trimr(mon_ser,1,0);

if (nargout == 1);
  %only one output, report the monthly series, not the error code
  err_flg = mon_ser;
end
end


function outData = alignNewHeadersAndDates( inHeaders,inDates,  inData, outHeaders, outDates ,filltype, type)
% This function aligns the data (inDates by inHeaders) according to the
% given required dates and headers. NOTE: the default type for inData  is
% double. The function can also support cell array type.

% Inputs: 
%   inHeaders = columns headers of the inData. (e.g., asssetIds)
%   inDates   = row headers of the inData.  (e.g., dates)
%   inDates   = the input data aligned by inDates and inHeaders. It can be
%               double (default) or cell array. 
%   outHeaders = columns headers in which the inData must be aligned (e.g., asssetIds)
%   outDates   = row headers in which the inData must be aligned (e.g., dates)
%   type (OPTINAL) = 'cell' to specify the cell array type for inData.
%   default type is double. 
%   filltype (OPTINAL) = 'previous' or a value to be used for missing data.
%                        'previous' uses the value of the previous non Nan
%                        data (after alignment). It supported only for
%                        double type

% Output: 
%  outData = inData aligned based on outDates and outHeaders.

   
   nOutDates = length(outDates);
   nOutHeaders = length(outHeaders);
   if nargin == 7
       if strcmpi (type, 'cell')
           outData = cell([nOutDates, nOutHeaders]);
       end 
   else 
       outData = nan(nOutDates, nOutHeaders);
   end 
   [~,i_OutDate,i_InDate] = intersect(outDates,inDates,'stable'); 
   [~,i_OutHeader2,i_InHeader2] = intersect(outHeaders,inHeaders,'stable'); 
   cnt=1;
   for i =1 : length (outHeaders)
       ind= find(ismember (inHeaders, outHeaders{i} )); 
       if ~isempty(ind)
           i_InHeader(cnt)= ind(1);
           i_OutHeader (cnt) = i; 
           cnt = cnt +1 ; 
       end 
   end 
           
       
   outData (i_OutDate,i_OutHeader)= inData (i_InDate,i_InHeader); 
   
   
   %filling Nan data
   if nargin == 6
       if isnumeric (filltype)
            outData(isnan(outData)) = filltype; 
       elseif ischar(filltype) 
           if strcmpi (filltype , '0') || strcmpi (filltype , 'zeros')...
                   || strcmpi (filltype , 'zero') 
               outData(isnan(outData)) = 0; 
           elseif strcmpi (filltype , '1') || strcmpi (filltype , 'one')...
                   || strcmpi (filltype , 'ones')
               outData(isnan(outData)) = 1; 
           elseif strcmpi (filltype , 'previous') || strcmpi (filltype, 'pre')
               firstRawIndex = 1:size(outData,1):numel(outData);
               indexTofill= setdiff (find(isnan(outData)) , firstRawIndex) ;
               for i=1:numel(indexTofill)
                    outData(indexTofill(i))=outData(indexTofill(i)-1) ; 
               end

           end 
       end 
   end 

end


function matrix = reduceOffDiags(matrix,factor)
matrix = squeeze(matrix);
[M,N] = size(matrix);
if M~=N
   disp('This function only works on an N x N matrix; newDiag must be N long; the variable provided is ',num2str(M),' long so function fails.') 
   return
end
for m = 1:M
   for n = 1:N
      if m~=n
         matrix(m,n) = factor*matrix(m,n);
      end % if
   end % for n
end % for m
end % fn
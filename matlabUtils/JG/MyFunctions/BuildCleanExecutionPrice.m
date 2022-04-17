function [o,h,l,c,p] = BuildCleanExecutionPrice(o,h,l,c,o_exec)
%__________________________________________________________________________
%
% This function builds clena execuion prices.
% This is needed for Long-Short Models where data are alligned on one
% benchmark
%__________________________________________________________________________
%

% Initiailze
[nsteps,ncols]=size(c);
p=zeros(nsteps,ncols);   

option_first_line=0;
if option_first_line==1
    for j=1:ncols
        if o(1,j)==0 %&& isnan(d_open(2,j)), 
            o(1,j)=NaN;
        end
        if o_exec(1,j)==0 %&& isnan(d_open(2,j))
            o_exec(1,j)=NaN;
        end        
        if h(1,j)==0 %&& isnan(d_high(2,j))
            h(1,j)=NaN;
        end        
        if l(1,j)==0 %&& isnan(d_low(2,j))
            l(1,j)=NaN;
        end
        if c(1,j)==0 %&& isnan(d_close(2,j))
            c(1,j)=NaN;
        end          
    end
end
 
for i=2:nsteps
    for j=1:ncols
        if isnan(c(i,j)) && ~isnan(o(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j))
            c(i,j)=(o(i,j)+l(i,j)+h(i,j))/3;
        elseif isnan(c(i,j)) && isnan(o(i,j)) && ~isnan(h(i,j)) && ~isnan(l(i,j))
            c(i,j)=(l(i,j)+h(i,j))/2;
        end
    end
end  
for i=2:nsteps
    for j=1:ncols
        if isnan(c(i,j)) && ~isnan(c(i-1,j)),  c(i,j)=c(i-1,j);     end
    end
end    
for i=2:nsteps
    for j=1:ncols
        if isnan(o(i,j)) && ~isnan(c(i-1,j)) , o(i,j)=c(i-1,j);     end
    end
end        
for i=2:nsteps
    for j=1:ncols
        if isnan(h(i,j)) && ~isnan(c(i-1,j)),  h(i,j)=c(i-1,j);     end
    end
end      
for i=2:nsteps
    for j=1:ncols
        if isnan(l(i,j)) && ~isnan(c(i-1,j)), l(i,j)=c(i-1,j);      end
    end
end

% initialize counters
count_oexec=zeros(nsteps,1);
% Count counter
o2=[o;o(nsteps,:)];
for i=1:nsteps
    for j=1:ncols
        if ~isnan(o2(i,j)), count_oexec(i)=count_oexec(i)+1;  end 
    end
end
% Clean first line
for j=1:ncols
    if isnan(o(1,j)), o(1,j)=0;  end
end    
% Compute price for execution price
option_exec=1;
if option_exec==1
    p(1:nsteps-1,:)=o_exec(2:nsteps,:);
    %o_exec1=[o_exec;o_exec(nsteps,:)];p(1:nsteps-1,:)=o_exec1(3:nsteps+1,:);
    for j=1:ncols
        %for i=2:nsteps-1
        %    %if ~insnan(o_exec(i+1,j))
        %        p(i,j)=o_exec(i+1,j); 
        %    %end
        %end
        for i=1:nsteps-2
            if isnan(p(i,j)) && ~isnan(o_exec(i+2,j)), p(i,j)=o_exec(i+2,j);  end
        end  
        for i=1:nsteps-3 
            if isnan(p(i,j)) && ~isnan(o_exec(i+3,j)), p(i,j)=o_exec(i+3,j);  end
        end    
        for i=1:nsteps-4 
            if isnan(p(i,j)) && ~isnan(o_exec(i+4,j)), p(i,j)=o_exec(i+4,j); end
        end    
        for i=1:nsteps-5 
            if isnan(p(i,j)) && ~isnan(o_exec(i+5,j)), p(i,j)=o_exec(i+5,j);    end
        end     
        for i=2:nsteps 
            if isnan(p(i,j)) , p(i,j)=p(i-1,j); end
        end                 
    end
    %p(1:nsteps-1,:)=o_exec(2:nsteps,:);
elseif option_exec==2
    p(1:nsteps-1,:)=o(2:nsteps,:);    
elseif option_exec==3
    p(1:nsteps-1,:)=c(1:nsteps-1,:);     
end
p(nsteps,:)=p(nsteps-1,:);
function[o,h,l,c,o_exec,p,o_origine,h_origine,l_origine,c_origine] = ...
    CleanForwardDirectOrIndirectGlobal(method,d_open,d_high,d_low,d_close,d_open_exec, fwd_open, fwd_close, fxd_open_exec)

%__________________________________________________________________________
% This function performs three tasks:
%
%   1. Clean the Open, High, Low, Close, Open_exec
%
%   2. This function allows to set the database either in a direct quote
%      or indirect quote versus the USD.
%      - Indirect quote
%      Nb. of USD to buy 1 unit of domestic currency
%      note: Delta(E)/E <(>) 0 ....> Depreciation (Appreciation)
%      - Direct quote
%      Nb. of domestic currencies to buy 1 USD
%      note: Delta(E)/E <(>) 0 ....> Appreciation (Depreciation)
%      - 'method' is then : 'direct' or
%                           'indirect'
%
%      Conventional quotes are:
%      - Indirect quote for   EURUSD, GBPUSD & AUDUSD.
%      - Direct quote for USDCAD, USDJPY, USDCHF & USDDKK.
%      - If 'metod'='indirect', then the code:
%           # inverts : EURUSD, GBPUSD & AUDUSD.
%           # keeps the original FX cross in memory.
%      - If 'metod'='direct', then the code:
%           # inverts : USDCAD, USDJPY, USDCHF & USDDKK.
%           # keeps the original FX cross in memory.
%      note: 'direct' method is preferred to set the 'price' of all the FX
%      crosses in USD.
%
%   3. It computes the execution price defined as the next-day open.
%
%   Input is the original matrix of Open, High, Low, Close & Open_exec.
%
%   Typically, the function is written as follows:
%    [o,h,l,c,o_exec,p,o_origine,h_origine,l_origine,c_origine] = ...
%           CleanFXDirectOrIndirect('direct',d_open,d_high,d_low,d_close,d_open_exec)
%
%__________________________________________________________________________

%__________________________________________________________________________
% STEEP 1: ATTRIBUTE, CLEAR & SET DIMENSIONS
    % Attribute & Clean
    c=d_close;  o=d_open; o_exec=d_open_exec;
    l=d_low;    h=d_high; 
    clear d_close d_open d_high d_low d_open_exec
    % Define dimension
    [nsteps,ncols]=size(c);

%__________________________________________________________________________
% STEP 2: CLEAN DATABASE
option_first_line=0;
if option_first_line==1
    for j=1:ncols
        if o(1,j)==0 %&& isnan(d_open(2,j))
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
        if isnan(o(i,j)) && ~isnan(c(i-1,j)) 
            o(i,j)=c(i-1,j);
        end
    end
end    
for i=2:nsteps
    for j=1:ncols
        if isnan(c(i,j)) && ~isnan(c(i-1,j))
            c(i,j)=c(i-1,j);
        end
    end
end    
for i=2:nsteps
    for j=1:ncols
        if isnan(o(i,j)) && ~isnan(c(i-1,j)) 
            o(i,j)=c(i-1,j);
        end
    end
end        
for i=2:nsteps
    for j=1:ncols
        if isnan(h(i,j)) && ~isnan(h(i-1,j))
            h(i,j)=h(i-1,j);
        end
    end
end      
for i=2:nsteps
    for j=1:ncols
        if isnan(l(i,j)) && ~isnan(l(i-1,j))
            l(i,j)=l(i-1,j);
        end
    end
end      

%__________________________________________________________________________
% STEP 2: DIRECT OR INDIRECT DATABSE & MEMORY

switch method
    case 'direct'
        %----------------------------------------------------------------------
        % STEP 2.1.: Keep in memory EURUSD, GBPUSD & AUDUSD & NZDUSD
        o_origine=o(:,1:4);                 h_origine=h(:,1:4);
        l_origine=l(:,1:4);                 c_origine=c(:,1:4);
        %o_exec_origine=[o_exec(:,1:2) , o_exec(:,5)];
        % Put h in memo
        h_memo=h;    
        %----------------------------------------------------------------------
        % STEP 2.2: Invert EURUSD, GBPUSD & AUDUSD  & NZDUSD to Direct
        % From EURUSD & GBPUSD to USDEUR & USDGBP  & NZDUSD.................
        for qqq=1:4
            for i=1:nsteps
                fwd_open(i,qqq)=1/fwd_open(i,qqq); 
                %h(i,qqq)=1/l(i,qqq);
                %l(i,qqq)=1/h_memo(i,qqq);
                fwd_close(i,qqq)=1/fwd_close(i,qqq);            
                if ~isnan(fwd_open_exec(i,qqq))
                    fwd_open_exec(i,qqq)=1/fwd_open_exec(i,qqq);
                else
                    fwd_open_exec(i,qqq)=NaN;
                end
            end
        end  
        % Clear h_memo
        %clear h_memo    
    case 'indirect'
        %----------------------------------------------------------------------
        % STEP 2.1.: Keep in memory USDJPY, USDCAD, USDDK & USDCHF, ....
        o_origine=o(:,5:17);                 h_origine=h(:,5:17); 
        l_origine=l(:,5:17);                 c_origine=c(:,5:17); 
        %o_exec_origine=[o_exec(:,3:4) , o_exec(:,6:7)];   
        % Put h in memo
        h_memo=h;
        %----------------------------------------------------------------------
        % STEP 2.2: Invert USDJPY, USDCAD, USDDK & USDCHF to Indirect
        % From USDJPY, USDCAD to JPYUSD & CADUSD...............................
        for qqq=5:17
            for i=1:nsteps
                fwd_open(i,qqq)=1/fwd_open(i,qqq);
                %h(i,qqq)=1/l(i,qqq);
                %l(i,qqq)=1/h_memo(i,qqq);
                fed_close(i,qqq)=1/fwd_close(i,qqq);            
                if ~isnan(fwd_open_exec(i,qqq))
                    fwd_open_exec(i,qqq)=1/fwd_open_exec(i,qqq);
                else
                    fwd_open_exec(i,qqq)=NaN;
                end
            end
        end       
        % Clear h_memo
        clear h_memo
end
%__________________________________________________________________________
% STEP 3: COMPUTE & CLEAN EXECUTION PRICE

% Initialize
fwdp=zeros(nsteps,ncols);   
% initialize counters
count_oexec=zeros(nsteps,1);
% Count counter
o2=[o;o(nsteps,:)];
for i=1:nsteps
    for j=1:ncols
        if ~isnan(o2(i,j))
           count_oexec(i)=count_oexec(i)+1;
        end 
    end
end
% Clean first line
for j=1:ncols
    if isnan(fwd_open(1,j))
        fwd_open(1,j)=0;
    end
end    
% Compute price for execution price
option_exec=1;
if option_exec==1
    fwdp(1:nsteps-1,:)=fwd_open_exec(2:nsteps,:);
    %o_exec1=[o_exec;o_exec(nsteps,:)];p(1:nsteps-1,:)=o_exec1(3:nsteps+1,:);
    for j=1:ncols
        %for i=2:nsteps-1
        %    %if ~insnan(o_exec(i+1,j))
        %        p(i,j)=o_exec(i+1,j); 
        %    %end
        %end
        for i=1:nsteps-2
            if isnan(fwdp(i,j)) && ~isnan(fwd_open_exec(i+2,j))
                fwdp(i,j)=fwd_open_exec(i+2,j); 
            end
        end  
        for i=1:nsteps-3 
            if isnan(fwdp(i,j)) && ~isnan(fwd_open_exec(i+3,j))
                fwdp(i,j)=fwd_open_exec(i+3,j); 
            end
        end    
        for i=1:nsteps-4 
            if isnan(fwdp(i,j)) && ~isnan(fwd_open_exec(i+4,j))
                fwdp(i,j)=fwd_open_exec(i+4,j); 
            end
        end    
        for i=1:nsteps-5 
            if isnan(fwdp(i,j)) && ~isnan(fwd_open_exec(i+5,j))
                fwdp(i,j)=fwd_open_exec(i+5,j); 
            end
        end     
        for i=2:nsteps 
            if isnan(p(i,j)) 
                fwdp(i,j)=fwdp(i-1,j); 
            end
        end                 
    end
    %p(1:nsteps-1,:)=o_exec(2:nsteps,:);
elseif option_exec==2
    fwdp(1:nsteps-1,:)=fwd_open(2:nsteps,:);    
elseif option_exec==3
    fwdp(1:nsteps-1,:)=fwd_close(1:nsteps-1,:);     
end
fwdp(nsteps,:)=fwdp(nsteps-1,:);
    
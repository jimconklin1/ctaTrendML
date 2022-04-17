function[y] = RelativePrice(x,Index1,Index2,method)

%__________________________________________________________________________
%
% This function computes the relative price.
% 2 methods: - difference
%            - ratio
%            - log difference
% Output is the relative price
%__________________________________________________________________________

% Identify Dimensions------------------------------------------------------
[nsteps,ncols]=size(x);

% Normalisation Gross MACD-------------------------------------------------
switch method
    case 'difference'
        y=x(:,Index1)-x(:,Index2);
    case 'ratio'
        y=zeros(nsteps,1);
        for i=1:nsteps
            if ~isnan(x(i,Index1)) && ~isnan(x(i,Index2))
                if x(i,Index2) == 0
                    y(i) = 0;
                elseif x(i,Index2) ~= 0
                    y(i) = x(i,Index1) / x(i,Index2);
                end
            end
        end
    case 'log difference'
        logy1=zeros(nsteps,1); logy2=zeros(nsteps,1);
        y=zeros(nsteps,1);
        for i=1:nsteps
            if ~isnan(x(i,Index1)) && x(i,Index2) ~= 0
                logy1(i)=log(x(i,Index1));
            end
            if ~isnan(x(i,Index2)) && x(i,Index2) ~= 0
                logy1(i)=log(x(i,Index2));
            end
        end        
        y=logy1-logy2;
        clear logy1 logy2
end


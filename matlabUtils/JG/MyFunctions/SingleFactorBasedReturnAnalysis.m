function[plMinX,plMaxX,totpl] = SingleFactorBasedReturnAnalysis(x,c,o_nd,MinX,MaxX,MaxPeriod,method,Direction)
%
%__________________________________________________________________________
%
% -- Inputs:
% c = Close price
% o_nd = open next day
% MinX & MaxX maximum for signal
%
% -- methods:
% 'close-to-close'                      = Enter @ Close, Exit @ Close
% 'open next day - to - close'          = Enter @ Open Next day - 
%                                         Exit @ Close
% 'open next day - to - open next day'  = Enter @ Open Next day - 
%                                         Exit @ Open Next day
%__________________________________________________________________________
%
%
[nsteps,ncols]=size(c);
plMinX_matrix=zeros(1,MaxPeriod,ncols);
plMaxX_matrix=zeros(1,MaxPeriod,ncols);
%
switch method
    case 'Close2Close-SingleAsset'
        % -- Prelocate --
        plMinX=zeros(1,MaxPeriod);        plMaxX=zeros(1,MaxPeriod);
        for i=1:nsteps-MaxPeriod
            % -- plMinX_matrix --
            if x(i)<=MinX 
                plMinX_matrix_inc=zeros(1,MaxPeriod);
                for u=1:MaxPeriod
                    plMinX_matrix_inc(1,u)=Direction * (c(i+u)-c(i));
                    plMinX_matrix=[plMinX_matrix;plMinX_matrix_inc];
                end
            end
            %--  plMaxX_matrix --
            if x(i)>=MaxX
                plMaxX_matrix_inc=zeros(1,MaxPeriod);
                for u=1:MaxPeriod
                    plMaxX_matrix_inc(1,u)=-Direction * (c(i+u)-c(i));
                    plMaxX_matrix=[plMaxX_matrix;plMaxX_matrix_inc];
                end
            end   
        end
        % -- Clean --
        plMinX_matrix(1,:)=[];
        plMaxX_matrix(1,:)=[];
        %
        % -- Average --
        for u=1:MaxPeriod
            plMinX(1,u)=mean(plMinX_matrix(:,u));
            plMaxX(1,u)=mean(plMaxX_matrix(:,u));
        end
        % -- Total P&L --        
    case 'OpenNextDay2Close-SingleAsset'
        % -- Prelocate --
        plMinX=zeros(1,MaxPeriod);        plMaxX=zeros(1,MaxPeriod);        
        for i=1:nsteps-MaxPeriod
            % plMinX_matrix --
            if x(i)<=MinX 
                plMinX_matrix_inc=zeros(1,MaxPeriod);
                for u=1:MaxPeriod
                    plMinX_matrix_inc(1,u)=Direction * (c(i+u)-o_nd(i));
                    plMinX_matrix=[plMinX_matrix;plMinX_matrix_inc];
                end
            end
            % plMaxX_matrix --
            if x(i)>=MaxX
                plMaxX_matrix_inc=zeros(1,MaxPeriod);
                for u=1:MaxPeriod
                    plMaxX_matrix_inc(1,u)=-Direction * (c(i+u)-o_nd(i));
                    plMaxX_matrix=[plMaxX_matrix;plMaxX_matrix_inc];
                end
            end    
        end    
        % -- Clean --
        plMinX_matrix(1,:)=[];
        plMaxX_matrix(1,:)=[];
        %
        % -- Average --
        for u=1:MaxPeriod
            plMinX(1,u)=mean(plMinX_matrix(:,u));
            plMaxX(1,u)=mean(plMaxX_matrix(:,u));
        end
        % -- Total P&L --        
    case 'OpenNextDay2OpenNextDay-SingleAsset'
        % -- Prelocate --
        plMinX=zeros(1,MaxPeriod);        plMaxX=zeros(1,MaxPeriod);        
        for i=1:nsteps-MaxPeriod
            % plMinX_matrix --
            if x(i)<=MinX 
                plMinX_matrix_inc=zeros(1,MaxPeriod);
                for u=1:MaxPeriod
                    plMinX_matrix_inc(1,u)=Direction * (o_nd(i+u)-o_nd(i));
                    plMinX_matrix=[plMinX_matrix;plMinX_matrix_inc];
                end
            end
            % plMaxX_matrix --
            if x(i)>=MaxX
                plMaxX_matrix_inc=zeros(1,MaxPeriod);
                for u=1:MaxPeriod
                    plMaxX_matrix_inc(1,u)=-Direction * (o_nd(i+u)-o_nd(i));
                    plMaxX_matrix=[plMaxX_matrix;plMaxX_matrix_inc];
                end
            end    
        end     
        % -- Clean --
        plMinX_matrix(1,:)=[];
        plMaxX_matrix(1,:)=[];
        %
        % -- Average --
        for u=1:MaxPeriod
            plMinX(1,u)=mean(plMinX_matrix(:,u));
            plMaxX(1,u)=mean(plMaxX_matrix(:,u));
        end
        % -- Total P&L --
        totpl=plMinX + plMaxX;        
    case 'OpenNextDay2OpenNextDay-Basket'
        % -- Prelocate --
        plMinX=zeros(MaxPeriod,ncols);     
        plMaxX=zeros(MaxPeriod,ncols);        
        plMinX_matrix_asset=zeros(1,MaxPeriod);
        plMaxX_matrix_asset=zeros(1,MaxPeriod);
        for j=1:ncols
            for i=1:nsteps-MaxPeriod
                % -- plMinX_matrix --
                if x(i,j)<=MinX 
                    plMinX_matrix_inc=zeros(1,MaxPeriod);
                    for u=1:MaxPeriod
                        plMinX_matrix_inc(1,u)=Direction * (o_nd(i+u,j)/o_nd(i,j)-1);
                        plMinX_matrix_asset=[plMinX_matrix_asset;plMinX_matrix_inc];
                    end
                end
                % -- plMaxX_matrix --
                if x(i,j)>=MaxX
                    plMaxX_matrix_inc=zeros(1,MaxPeriod);
                    for u=1:MaxPeriod
                        plMaxX_matrix_inc(1,u)=-Direction * (o_nd(i+u,j)/o_nd(i,j)-1);
                        plMaxX_matrix_asset=[plMaxX_matrix_asset;plMaxX_matrix_inc];
                    end
                end    
            end 
            % -- Clean & Assign for j --
            plMinX_matrix_asset(1,:)=[];
            plMaxX_matrix_asset(1,:)=[];            
            plMinX_matrix(1,:,j)=plMinX_matrix_asset(1,:);
            plMaxX_matrix(1,:,j)=plMaxX_matrix_asset(1,:);
            % -- Average --
            for u=1:MaxPeriod
                plMinX(u,j)=mean(plMinX_matrix_asset(:,u));
                plMaxX(u,j)=mean(plMaxX_matrix_asset(:,u));
            end            
        end
        % -- Total P&L --
        totpl=plMinX + plMaxX;   
end
%

% Plot
%myx=1:1:MaxPeriod;
%plot(plMinX);plot(plMaxX);plot(totpl);
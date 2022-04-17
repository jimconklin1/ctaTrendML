function[oa,ha,la,ca] = FetchAsset(method)
%__________________________________________________________________________
% This function fetch a given asset in the global dta base
%__________________________________________________________________________

switch method
    case 'SP1'
        clear        
    case 'ND1'
        clear        
    case 'Z 1'   
        clear        
    case 'VG1'
        clear        
    case 'GX1'
        clear        
    case 'NK1'   
        clear        
    case 'XP1'
        clear        
    case 'HI1'
        clear        
    case 'HC1'  
        clear        
    case 'TW1'
        clear        
    case 'KM1'
        clear        
    case 'QZ1'
        clear        
    case 'IH1'
        clear        
    case 'TY1'
        clear        
    case 'CN1'
        clear        
    case 'G 1'
        clear        
    case 'RX1'
        clear        
    case 'JB1'
        clear        
    case 'XM1'
        clear        
    case 'CL1'
        clear        
    case 'GC1'
        clear        
    case 'W 1' 
        clear        
    case 'EURUSD'
        clear
        load OCTIS_GLOBAL_FX_DATABASE.mat
        PostionCol=1;
        oa=oInd(:,PostionCol); ha=hInd(:,PostionCol); la=lInd(:,PostionCol); ca=cInd(:,PostionCol);
    case 'GBPUSD'
        clear
        load OCTIS_GLOBAL_FX_DATABASE.mat
        PostionCol=2;
        oa=oInd(:,PostionCol); ha=hInd(:,PostionCol); la=lInd(:,PostionCol); ca=cInd(:,PostionCol);      
    case 'AUDUSD'
        clear
        load OCTIS_GLOBAL_FX_DATABASE.mat
        PostionCol=3;
        oa=oInd(:,PostionCol); ha=hInd(:,PostionCol); la=lInd(:,PostionCol); ca=cInd(:,PostionCol);    
    case 'NZDUSD' 
        clear
        load OCTIS_GLOBAL_FX_DATABASE.mat
        PostionCol=4;
        oa=oInd(:,PostionCol); ha=hInd(:,PostionCol); la=lInd(:,PostionCol); ca=cInd(:,PostionCol);            
    case 'USDCAD' 
        clear        
    case 'USDCHF'   
        clear        
    case 'USDDKK'  
        clear        
    case 'USDSEK'    
        clear        
    case 'USDNOK'
        clear        
    case 'USDJPY'   
    case 'USDSGD'
        clear        
    case 'USDHKD'
        clear        
    case 'USDKRW'
        clear        
    case 'USDTWD'
        clear        
    case 'USDINR'
        clear        
    case 'USDZAR'
        clear        
    case 'USDBRL'
        clear        
    case 'USDMXN'
        clear                
end
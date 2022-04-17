% -- Upload data --
Myupload = 0;
if Myupload == 1;
    path = 'S:\08 Trading\088 Quantitative Global Macro\0881 Global_Macro\08812 CrossAssets\equity\';
    % -- Instrument 1 is based instrument --
    [tday, tdaynum, o,h,l,c] = UploadFuture(path, 'equ1', 'data');
    % Create structure for Instrument 1
    inst1 = struct('tday',tday,'tdaynum', tdaynum, 'o',o,'h',h,'l',l,'c',c);
    % -- Instrument 2 is instrument which is vlooked-up --
    [tday, tdaynum, o,h,l,c] = UploadFuture(path, 'equ50', 'data');
    % Create structure for Instrument 2
    inst2 = struct('tday',tday,'tdaynum', tdaynum, 'o',o,'h',h,'l',l,'c',c);
end

MyLogic = 0;
if MyLogic == 1
    % -- Merge time data to find intersection --
    %tday = union(inst1.tday, inst2.tday);
    tday = inst1.tday;
    % -- Pre-locate matrices for intersection --
    intersect_x = NaN(length(tday), 2);
    % Intersect - Open
    % instrument 1
    [junk idx1 idx] = intersect(inst1.tday, tday);
    intersect_x(idx, 1) = inst1.o(idx1); 
    % instrument 2
    [junk idx2 idx] = intersect(inst2.tday, tday);
    intersect_x(idx, 2) = inst2.o(idx2);
    intersect_x = CarryForwardPastValue(intersect_x);
end

Usefunction = 1;
if Usefunction == 1
    %tday_base = inst1.tday;
    %tday_x = inst2.tday;
    tday_base = inst2.tday;
    tday_x = inst1.tday;    
    %x = [inst2.o, inst2.h, inst2.l, inst2.c];
    x = [inst1.o, inst1.h, inst1.l, inst1.c];
    x_vlookedup = VlookupExcel(tday_base, tday_x, x, 'NaNtoZero');
    % case for USD
    tday_base = tday;
    [tday_usdlibor, tdaynum_usdlibor, ~, ~, ~, usd_rate] = UploadFuture(path, 'crncy4', 'data'); 
    usd_rate_vlookedup = VlookupExcel(tday_base, tday_usdlibor, usd_rate, 'NaNtoZero');
    usd_rate = usd_rate_vlookedup;
end
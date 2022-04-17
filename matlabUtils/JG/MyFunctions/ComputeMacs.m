function[macs] = ComputeMacs(c,ema2,ema3,ema4,ema5,ema6,ema7,ema8,ema9,ema10,ema11,ema12,ema13,ema14,ema15,ema16,ema17,ema18,ema19,ema20,...
                                         ema24,ema28,ema32,ema36,ema40,ema44,ema48, ema52,ema56,ema60,ema64,ema68,ema72,ema76,ema80)
                                     

macs=zeros(size(c));
[nsteps,ncols]=size(c);


Model=2;

if Model==1 
    
    for i=1:nsteps
        for j=1:ncols
            if c(i,j)>ema4(i,j)
                macs(i,j)=macs(i,j)+5;
            end
            if ema2(i,j)>ema8(i,j)
                macs(i,j)=macs(i,j)+5;
            end  
            if ema3(i,j)>ema12(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema4(i,j)>ema16(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema5(i,j)>ema20(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema6(i,j)>ema24(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema7(i,j)>ema28(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema8(i,j)>ema32(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema9(i,j)>ema36(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema10(i,j)>ema40(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema11(i,j)>ema44(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema12(i,j)>ema48(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema13(i,j)>ema52(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema14(i,j)>ema56(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema15(i,j)>ema60(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema16(i,j)>ema64(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema17(i,j)>ema68(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema18(i,j)>ema72(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema19(i,j)>ema76(i,j)
                macs(i,j)=macs(i,j)+5;
            end 
            if ema20(i,j)>ema80(i,j)
                macs(i,j)=macs(i,j)+5;
            end         
        end
    end
    
else
   
    for i=1:nsteps
        for j=1:ncols
            if c(i,j)>ema4(i,j)
                macs(i,j)=macs(i,j)+5;
            end
            if ema2(i,j)>ema8(i,j)
                macs(i,j)=macs(i,j)+5;
            end  
            if ema3(i,j)>ema12(i,j)
                macs(i,j)=macs(i,j)+4.5;
            end 
            if ema4(i,j)>ema16(i,j)
                macs(i,j)=macs(i,j)+4.5;
            end 
            if ema5(i,j)>ema20(i,j)
                macs(i,j)=macs(i,j)+4;
            end 
            if ema6(i,j)>ema24(i,j)
                macs(i,j)=macs(i,j)+4;
            end 
            if ema7(i,j)>ema28(i,j)
                macs(i,j)=macs(i,j)+3.5;
            end 
            if ema8(i,j)>ema32(i,j)
                macs(i,j)=macs(i,j)+3.5;
            end 
            if ema9(i,j)>ema36(i,j)
                macs(i,j)=macs(i,j)+3;
            end 
            if ema10(i,j)>ema40(i,j)
                macs(i,j)=macs(i,j)+3;
            end 
            if ema11(i,j)>ema44(i,j)
                macs(i,j)=macs(i,j)+2.5;
            end 
            if ema12(i,j)>ema48(i,j)
                macs(i,j)=macs(i,j)+2.5;
            end 
            if ema13(i,j)>ema52(i,j)
                macs(i,j)=macs(i,j)+2;
            end 
            if ema14(i,j)>ema56(i,j)
                macs(i,j)=macs(i,j)+2;
            end 
            if ema15(i,j)>ema60(i,j)
                macs(i,j)=macs(i,j)+1.5;
            end 
            if ema16(i,j)>ema64(i,j)
                macs(i,j)=macs(i,j)+1.5;
            end 
            if ema17(i,j)>ema68(i,j)
                macs(i,j)=macs(i,j)+1;
            end 
            if ema18(i,j)>ema72(i,j)
                macs(i,j)=macs(i,j)+1;
            end 
            if ema19(i,j)>ema76(i,j)
                macs(i,j)=macs(i,j)+0.5;
            end 
            if ema20(i,j)>ema80(i,j)
                macs(i,j)=macs(i,j)+0.5;
            end         
        end
    end
    
end
%fmacs=TrendSmoother(macs,'ema',FastPeriod);
%smacs=TrendSmoother(macs,'ema',SlowPeriod);
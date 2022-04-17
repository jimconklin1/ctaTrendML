function[Y] = MACS(c)


c;                              ema4=TrendSmoother(c,'ema',4);
ema2=TrendSmoother(c,'ema',2);  ema8=TrendSmoother(c,'ema',8);
ema3=TrendSmoother(c,'ema',3);  ema12=TrendSmoother(c,'ema',12);
                                ema16=TrendSmoother(c,'ema',16);         
ema5=TrendSmoother(c,'ema',5);  ema20=TrendSmoother(c,'ema',20); 
ema6=TrendSmoother(c,'ema',6);  ema24=TrendSmoother(c,'ema',24);  
ema7=TrendSmoother(c,'ema',7);  ema28=TrendSmoother(c,'ema',28);  
                                ema32=TrendSmoother(c,'ema',32);  
ema9=TrendSmoother(c,'ema',9);  ema36=TrendSmoother(c,'ema',36);  
ema10=TrendSmoother(c,'ema',10);ema40=TrendSmoother(c,'ema',40);  
ema11=TrendSmoother(c,'ema',11);ema44=TrendSmoother(c,'ema',44);  
                                ema48=TrendSmoother(c,'ema',48);  
ema13=TrendSmoother(c,'ema',13);ema52=TrendSmoother(c,'ema',52);  
ema14=TrendSmoother(c,'ema',14);ema56=TrendSmoother(c,'ema',56);  
ema15=TrendSmoother(c,'ema',15);ema60=TrendSmoother(c,'ema',60);  
                                ema64=TrendSmoother(c,'ema',64);  
ema17=TrendSmoother(c,'ema',17);ema68=TrendSmoother(c,'ema',68);  
ema18=TrendSmoother(c,'ema',18);ema72=TrendSmoother(c,'ema',72);  
ema19=TrendSmoother(c,'ema',19);ema76=TrendSmoother(c,'ema',76);  
                                ema80=TrendSmoother(c,'ema',80);  
                                 
Y=zeros(size(c));
[nsteps,ncols]=size(c);

for j=1:ncols
    for i=1:nsteps
        if c(i,j)>ema4(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema2(i,j)>ema8(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema3(i,j)>ema12(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema4(i,j)>ema16(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema5(i,j)>ema20(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema6(i,j)>ema24(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema7(i,j)>ema28(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema8(i,j)>ema32(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema9(i,j)>ema36(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema10(i,j)>ema40(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema11(i,j)>ema44(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema12(i,j)>ema48(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema13(i,j)>ema52(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema14(i,j)>ema56(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema15(i,j)>ema60(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema16(i,j)>ema64(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema17(i,j)>ema68(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema18(i,j)>ema72(i,j)
            Y(i,j)=Y(i,j)+5;
        end    
        if ema19(i,j)>ema76(i,j)
            Y(i,j)=Y(i,j)+5;
        end
        if ema20(i,j)>ema80(i,j)
            Y(i,j)=Y(i,j)+5;
        end     
    end
end



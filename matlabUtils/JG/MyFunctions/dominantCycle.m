

function z = dominantCycle(h,l,c, parameters, method)

if strcmp(method, 'zeroCrossing')
    
    period = parameters(1,1);
    bandwith = parameters(1,2);
    
    alpha2 = (cosine(0.25*bandwith*360/period)+sine(0.25*bandwith*360/period)-1)/cosine(0.25*bandwith*360/period);
    
    for j=1:ncols
        
        for i=1;nsteps
    
            hp(i) = (1+alpha2/2) * (c(i,j)-c(i-1,j)) + (1-alpha2) * hp(i-1);
            beta1 = cosine(360/period);
            gamma1 = 1/cosine(360*bandwith/period);
            bp(i,j) = 0.5*(1-alpha1)*(hp(i,j)-hp(i-2,j)) + beta1*(1+alpha1)*bp(i-1,j)-alpha1*bp(i-2,j);

            if i==2 || i==2
                bp(i,j)=0;
            end

            peak(i,j)=0.991-peak(i,j);

            if abs(bp(i,j))>peak(i,j)
                peak(i,j)=abs(bp(i,j);
            end

            if peak(i,j) ~=0
                real(i,j)=bp(i,j)/peak(i,j);
            end

            dc(i,j)=dc(i-1,j);
            if dc(i,j)<6
                dc(i,j)=6;
            end
            counter = counter+1;
            if (real(i,j) > 0 && real(i-1,j) < 0 ) || (real(i,j) < 0 && real(i-1,j) > 0 )
                dc(i,j) = 2*counter;
                if 2*counter > 1.25 *dc(i-1,j)
                    dc(i,j) = 1.25*dc(i-1,j);
                end
                if 2*counter < 0.8* dc(i-1,j)
                    dc(i,j) = 0.8 * dc(i-1,j);
                end
                counter = 0;
            end
            
        end
        
    end
    
end
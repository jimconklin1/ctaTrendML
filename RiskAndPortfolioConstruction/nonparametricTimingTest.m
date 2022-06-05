function o = nonparametricTimingTest(hrtns,frtns,rfrtns,hHeader,fHeader,outlierPercent,verbose)

    function res = mij(xi, xj, yi, yj)
        res = (yj - yi) / (xj - xi);
    end

    function res = ht(x, y)
        res = (x(1) < x(2) < x(3))*sign(mij(x(2), x(3),y(2),y(3)) - mij(x(1), x(2), y(1), y(2))) ...
             +(x(1) < x(3) < x(2))*sign(mij(x(3),x(2),y(3),y(2)) - mij(x(1),x(3),y(1),y(3))) ...
             +(x(2) < x(1) < x(3))*sign(mij(x(1),x(3),y(1),y(3)) - mij(x(2),x(1),y(2),y(1))) ...
             +(x(2) < x(3) < x(1))*sign(mij(x(3),x(1),y(3),y(1)) - mij(x(2),x(3),y(2),y(3))) ...
             +(x(3) < x(1) < x(2))*sign(mij(x(1),x(2),y(1),y(2)) - mij(x(3),x(1),y(3),y(1))) ...
             +(x(3) < x(2) < x(1))*sign(mij(x(2),x(1),y(2),y(1)) - mij(x(3),x(2),y(3),y(2)));
    end
        

if ~exist('verbose','var')
    verbose = true;
end

y = hrtns - rfrtns/12;
x = frtns - rfrtns/12;
[T, ~] = size(y);

combos = nchoosek(1:T,3)';
[~, iters] = size(combos);
tmptrue = 0;

for i = combos
   [newx, x_order] = sort(x(i));
   newy = y(i);
   newy = newy(x_order);
   if (newy(3) - newy(2)) / (newx(3)-newx(2)) > (newy(2) - newy(1)) / (newx(2)-newx(1))
       tmptrue = tmptrue + 1;
   end
end

theta = 2 * tmptrue / iters  - 1;

%[newx, x_order] = sort(x, 'descend');
%newy = y(x_order);

[newx2, x_order2] = sort(x);
newy2 = y(x_order2);

%varU = 0;
varU2 = 0;
%scaling = nchoosek(length(x), 2);
scaling2 = nchoosek(length(x) - 1, 2);

%for i = length(x):-1:3
%    combos = nchoosek(1:(i-1),2)';
%    h = 0;
%    for c = combos
%        h = h + 2*((newy(c(1)) - newy(c(2)))/(newx(c(1)) - newx(c(2))) > (newy(c(2)) - newy(i))/(newx(c(2)) - newx(i))) - 1; 
%    end
%    h = h / scaling;
%    varU = varU + (h - theta)^2;
%end

for i = 1:length(x)
    combos = nchoosek(1:length(x), 2)';
    h = 0;
    for c = combos
        if c(1) ~= i && c(2) ~= i
            h = h + ht(newx2([i, c(1), c(2)]), newy2([i, c(1), c(2)]));
        end
    end
    h = h / scaling2;
    varU2 = varU2 + (h - theta)^2;
end

%sdU = sqrt(9 * varU / length(x))/sqrt(length(x));
%pval = 1 - normcdf(theta/sdU);

sdU2 = sqrt(9 * varU2 / length(x))/sqrt(length(x));
pval2 = 1 - normcdf(theta/sdU2);


if verbose
    fprintf("**********Non-Parametric Test Results for %s in term of %s**********\n", char(hHeader(1)),char(fHeader(1)));
    fprintf("Value: %f \n", theta);
    %fprintf("SD: %f \n", sdU);
    fprintf("SD: %f \n", sdU2);
    %fprintf("Z-score: %f \n", theta/sdU);
    fprintf("Z-score: %f \n", theta/sdU2);
    %fprintf("p-value: %f \n", pval);
    fprintf("p-value: %f \n", pval2);
end

o = [theta, sdU2, pval2];
end
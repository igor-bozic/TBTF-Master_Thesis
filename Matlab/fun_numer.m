function [ num ] = fun_numer( n, delta, c, pivec)
% calculates the critical value (maximum) for b such that the numerator is <=0

fun_fraction = @(pi) (1-pi)/(1-delta*pi);

% numerator of the fraction:
a=1;
for i = 1:n-1
  a = a * fun_fraction(pivec(i))  ;
end

top = 1 - delta^n * a;

% denominator of the fraction:
b = 0;
for i=2:n-1
    temp=1;
   for j = 2:i
     temp = temp*fun_fraction(pivec(n-j+1)) ; 
   end
   b = b + delta^i*temp;
end

bottom = 1 + delta + b;

num = c * top / bottom;

end


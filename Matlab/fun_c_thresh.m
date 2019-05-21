function [ c_thresh ] = fun_c_thresh( x,n, b, delta )
% fun_c_thresh -  implements the solution  for c such that the state is 
% indifferent between saving and not saving the bank

% Note: the solution was obtained analytically.
% Note: n must be the number of bullets left. So that for n=2 pi_1_bar is relevant

% numerator:
sum1 = 1;

for i=1:n-1
    
   prod1 = 1;
   for j=n-i+1:n
       prod1 = prod1 * (1-x(j))/(1-delta*x(j));
   end
   prod1 = (delta^i)*prod1;
   sum1 = sum1 + prod1;

end

% denominator:
   prod2 = 1;
   for j=1:n
       prod2 = prod2 * (1-x(j))/(1-delta*x(j));
   end
   prod2 = (delta^n)*prod2;
   
% ratio:   
c_thresh = b*sum1/(1-prod2);

end


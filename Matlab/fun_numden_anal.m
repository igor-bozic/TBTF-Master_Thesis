function [ nums,dens ] = fun_numden_anal( delta, c, pivec)
% analytical check of the first three critical values of b for numerator
% and denominator

fun_fraction = @(pi) (1-pi)/(1-delta*pi);


num_pi1 = c*(1-delta^2*fun_fraction(pivec(1)))/(1+delta) ;
den_pi1 = c*(1-delta*fun_fraction(pivec(1)))/2;

num_pi2 = c*(1-delta^3*fun_fraction(pivec(1))*fun_fraction(pivec(2)))/(1+delta+delta^2*fun_fraction(pivec(2)));
den_pi2 = c*(1-delta^2*fun_fraction(pivec(1))*fun_fraction(pivec(2)))/(2+delta*fun_fraction(pivec(2)));

num_pi3 = c*(1-delta^4*fun_fraction(pivec(1))*fun_fraction(pivec(2))*fun_fraction(pivec(3)))/(1+delta+delta^2*fun_fraction(pivec(3))+delta^3*fun_fraction(pivec(3))*fun_fraction(pivec(2)));
den_pi3 = c*(1-delta^3*fun_fraction(pivec(1))*fun_fraction(pivec(2))*fun_fraction(pivec(3)))/(2+delta*fun_fraction(pivec(3)) + delta^2*fun_fraction(pivec(3))*fun_fraction(pivec(2)));

nums = [num_pi1; num_pi2; num_pi3];
dens = [den_pi1; den_pi2; den_pi3];
end


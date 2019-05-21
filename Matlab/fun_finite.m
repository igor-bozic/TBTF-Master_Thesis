function [ opt_pi_bank_min,pi_state_thresh_min ,n_end, V_bank, v_state_opt_min,...
                pi_prime, V_prime_bank, pi_bar_numer,pi_bar_denom ] = fun_finite( delta, Rmax, Rmin, b, c, nper )

% fun_finite - solves the model in finite case

% NOTE: probabilities and values are calculated assuming that there is
% always a bailout. The only indicator that it will not happen is n_end not equal to 0.

% INPUT: 
% delta - discount rate
% Rmax - project's return in case of success
% Rmin - return on a safe project
% b - bailout cost
% c - deadweight cost to the state in case of bank's liquidation
% nper - number of periods

% OUTPUT:
% opt_pi_bank_min - optimal probabilities for the bank 
% pi_state_thresh_min - threshold probabilities for the state, 
% n_end - the number of period when the game is over and the bank is not saved
% V_bank - value for the bank 
% v_state_opt_min - the state
% pi_prime - threshold probability for the bank
% V_prime_bank - corresponding value for the bank
% pi_bar_numer - numerator from the pi_bar formula in eq.(23)  
% pi_bar_denom - denominator from the pi_bar formula in eq.(23)



% Define function R for any probability x: calculates the project return R
% for a given probability of success x
R = @(x) Rmin + (Rmax - Rmin)*(1-x);

% 1. Bank's problem

% bank's problem at the last stage: max(pi) pi*R(pi)/(1-delta*pi)
f_opt_bank_0 = @(x) -x.*R(x)./(1-delta*x); % minus for minimization; x=pi; from eq.(27)

% optimal value for period 0:
opt_pi_bank = zeros(nper,1);
V_bank = zeros(nper,1);
[opt_pi_bank(1),fval] = fmincon(f_opt_bank_0,0.5,[],[],[],[],0,1); % optimize for period 0
V_bank(1) = -fval; % optimal value for period 0

% Critical values pi_prime:
pi_prime = zeros(nper,1);
pi_prime(1) = opt_pi_bank(1); % in period 0 bank chooses optimal probability anyways
V_prime_bank = zeros(nper,1);
V_prime_bank(1) = f_opt_bank_0(pi_prime(1));

% bank problem in the rest of the periods, eq.(27):
f_bank = @(x,y) -((x.*(Rmin + (Rmax-Rmin)*(1-x))+(1-x)*(b+delta*y))./(1-delta*x)); % x=pi

% function for finding the critical probability for the bank pi_prime,
% calculates the squared difference between value without bailout and with
% bailout.
f_crit = @(x,y,v0) (v0-((x.*(Rmin + (Rmax-Rmin)*(1-x))+(1-x)*(b+delta*y))./(1-delta*x)))^2; % x=pi, y=Vlag1, z=V0

options = optimset('TolFun',1e-15);

% solve the problem for the rest of the periods:
 for k=2:nper
 
% optimal values:
f_opt_bank = @(x) f_bank(x,V_bank(k-1));
[opt_pi_bank(k),fval] = fmincon(f_opt_bank,0.7,[],[],[],[],0,1);
V_bank(k) = -fval; 

% critical values:
f_crit_bank = @(x) f_crit(x,V_bank(k-1),V_bank(1));
[pi_prime(k),fval] = fmincon(f_crit_bank,0.7,[],[],[],[],0,1);
V_prime_bank(k) = f_opt_bank(pi_prime(k)); 
 end

 
% 2. State's problem

% solve the equations from (20) on:

v_state_opt_min = zeros(nper,1);
pi_state_thresh_min = zeros(nper,1);
opt_pi_bank_min = opt_pi_bank;

% n=0, pi_0 does not change
f_state_0 = @(x) (-c + b + delta * c * (1-x)./(1-delta*x))^2; % x=pi_0, squared for optimization
pi_state_thresh_min(1) = fmincon(f_state_0,0.5,[],[],[],[],0,1);

v_state_opt_min(1) =  c * (1 - opt_pi_bank_min(1))/(1 - delta*opt_pi_bank_min(1));

pi_bar_numer = zeros(nper,1);
pi_bar_denom = zeros(nper,1);
pi_bar_numer(1) = c-(c-b)/delta;
pi_bar_denom(1) = b;


% previous periods, n>0:
f_state = @(x,y) (- c + b + delta * (b+delta*y) * (1-x)./(1-delta*x))^2;

n_end = 0;
for i=2:nper
   f_state_opt =  @(x) f_state(x,v_state_opt_min(i-1));
   pi_state_thresh_min(i) = fmincon(f_state_opt,0.5,[],[],[],[],0,1);
   
   if min(c, b + delta*v_state_opt_min(i-1)) == c % if state decides not to save the bank, note the period when
       n_end = nper-i+1;
   end    
   v_state_opt_min(i) = min(c, b + delta*v_state_opt_min(i-1)) * (1 - opt_pi_bank_min(i))/(1 - delta*opt_pi_bank_min(i));

pi_bar_numer(i) = (b + delta*v_state_opt_min(i-1)) - (c-b)/delta;
pi_bar_denom(i) = (b + delta*v_state_opt_min(i-1)) - (c-b);
   
   
end

if n_end ~= 0
       fprintf('GAME OVER AT n = %d \n',nper-n_end+1)
end

figure
plot(1:nper,flip(opt_pi_bank_min),1:nper,flip(pi_state_thresh_min))
if n_end ~= 0
    line([n_end,n_end],[0,1],'Color','r')
end
legstr = {'Bank', 'State','Game over'};
xlabel('Stage of the game'); ylabel('Probability'); legend(legstr,'Location','SouthWest')
title('Optimal Probabilities')

% figure
% plot(1:n_per,flip(pi_bank_an),1:n_per,flip(pi_state_an),)
% xlabel('Stage of the game'); ylabel('Probability'); legend('Bank', 'State')
% title('Analytical results')

figure
plot(flip(v_state_opt_min)); ylim([0,1.2*max(v_state_opt_min)+1e-15])
if n_end ~= 0
    line([n_end,n_end],[0,1.2*max(v_state_opt_min)],'Color','r')
end
title('State value if it choses whether to save the bank')


end


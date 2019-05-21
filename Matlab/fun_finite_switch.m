function [ pi_real_bank,V_real_bank,pi_opt_bank,V_opt_bank,pi_bar_state, v_state_opt,...
                pi_prime_bank, V_prime_bank ] = fun_finite_switch( delta, Rmax, Rmin, b, c, nper )
% fun_finite_switch - solves the model in finite case where the bank
% switches to pi_bar_state if optimal pi_bank is higher than pi_prime_state 


R = @(x) Rmin + (Rmax - Rmin)*(1-x);
options = optimset('TolFun',1e-15);

pi_opt_bank = zeros(nper,1);
V_opt_bank = zeros(nper,1);
pi_prime_bank = zeros(nper,1); % critical values pi_prime
V_prime_bank = zeros(nper,1); % critical values V_prime
pi_real_bank = zeros(nper,1); % real probabilities that the bank will choose
V_real_bank = zeros(nper,1); % real values for bank
v_state_opt = zeros(nper,1);
pi_bar_state = zeros(nper,1);


% 1. Stage 0 (n=1, 1 baiout left)

% Bank's problem at the last stage: chooses pi_optimal 
f_opt_bank_0 = @(x) -x.*R(x)./(1-delta*x); % minus for minimization; x=pi; from eq.(27)

[pi_opt_bank(1),fval] = fmincon(f_opt_bank_0,0.5,[],[],[],[],0,1); % optimal pi_0
V_opt_bank(1) = -fval; % opitmal value
pi_prime_bank(1) = pi_opt_bank(1); % at the last stage pi_optimal = pi_prime
pi_real_bank(1) = pi_opt_bank(1); % at the last stage pi_real = pi_prime
V_prime_bank(1) = -f_opt_bank_0(pi_prime_bank(1));
V_real_bank(1) = -f_opt_bank_0(pi_real_bank(1));

% State's problem at the last stage: chooses pi_bar
f_state_0 = @(x) (- c + b + delta * c * (1-x)./(1-delta*x))^2;
pi_bar_state(1) = fmincon(f_state_0,0.5,[],[],[],[],0,1); % threshold pi_bar_0
v_state_opt(1) =  c * (1 - pi_real_bank(1))/(1 - delta*pi_real_bank(1));

% if pi_bar_state(1) > pi_opt_bank(1) % if theta_0 = 0, game ends
    
%     display('THE BANK IS NOT SAVED AT THE LAST STAGE n=1, THETA_0 = 0')
    
% else % otherwise proceed to the next stages:
    

% bank problem in the rest of the periods:
f_bank = @(x,y) -((x.*(Rmin + (Rmax-Rmin)*(1-x))+(1-x)*(b+delta*y))./(1-delta*x)); % x=pi
f_crit = @(x,y,v0) (v0-((x.*(Rmin + (Rmax-Rmin)*(1-x))+(1-x)*(b+delta*y))./(1-delta*x)))^2; % x=pi, y=Vlag1, z=V0
f_state = @(x,y) (- c + b + delta * (b+delta*y) * (1-x)./(1-delta*x))^2;


for k=2:nper
 
% Bank's problem: optimal probabilities and values:
f_opt_bank = @(x) f_bank(x,V_opt_bank(k-1));
[pi_opt_bank(k),fval] = fmincon(f_opt_bank,0.7,[],[],[],[],0,1);
V_opt_bank(k) = -fval; 

% critical values:
f_crit_bank = @(x) f_crit(x,V_opt_bank(k-1),V_opt_bank(1));
[pi_prime_bank(k),fval] = fmincon(f_crit_bank,0.7,[],[],[],[],0,1);
V_prime_bank(k) = -f_opt_bank(pi_prime_bank(k)); % check that it equals V_bank(1)!!!


% State's problem: threshold probabilities and values:

f_state_opt =  @(x) f_state(x,v_state_opt(k-1));
pi_bar_state(k) = fmincon(f_state_opt,0.5,[],[],[],[],0,1);
   
   if  pi_bar_state(k) > pi_opt_bank(k) % if bank's optimal pi is too small
      
     if pi_bar_state(k) <= pi_prime_bank(k) % but if the bank can still make profit   
      pi_real_bank(k) =  pi_bar_state(k); % bank switches to the required level of pi
     else
%       display(strcat('THE BANK IS NOT SAVED AT THE STAGE n=',num2str(k),', THETA_',num2str(k-1),' = 0'))
      pi_real_bank(k) =  pi_real_bank(1); % bank switches to required level of pi
     end
   
   else
       
     pi_real_bank(k) =  pi_opt_bank(k); 
     
   end 
   
if pi_real_bank(k)~=0 % if the game is not over, calculate Values for bank and state 
v_state_opt(k) = min(c, b + delta*v_state_opt(k-1)) * (1 - pi_real_bank(k))/(1 - delta*pi_real_bank(k));
V_real_bank(k) = -f_opt_bank(pi_real_bank(k));
end


end





end


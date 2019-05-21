function [ thetas, pi_real_bank, V_real_bank, pi_opt_bank, V_opt_bank, pi_bar_state, v_state,...
                pi_prime_bank, V_prime_bank, V_state, pi_bar_numer, pi_bar_denom] = fun_iter_new( delta, Rmax, Rmin, b, c, nper )

% fun_iter_new - solves the model in finite case where the bank
% switches to pi_bar_state if optimal pi_bank is higher than pi_prime_state

% INPUTS:  
% delta - discount rate
% Rmax - project's return in case of success
% Rmin - return on a safe project
% b - bailout cost
% c - deadweight cost to the state in case of bank's liquidation
% nper - number of periods

% OUTPUTS: 
% thetas - indicators for the bailouts
% pi_real_bank - real probabilities that the bank will choose
% V_real_bank - real values for bank
% pi_opt_bank -  optimal probabilities for bank
% V_opt_bank - value for the bank corresponding to pi_opt_bank
% pi_bar_state - threshold probabilities for the state
% v_state - value v for the state from eq.(18)
% pi_prime_bank - critical values pi_prime for the bank
% V_prime_bank - corresponding values V_prime fot the bank
% V_state - value V for the state from eq.(18)
% pi_bar_numer - numerator for pi_bar formula
% pi_bar_denom - denominator for pi_bar formula


% Define function R for any probability x: calculates the project return R
% for a given probability of success x
R = @(x) Rmin + (Rmax - Rmin)*(1-x);
options = optimset('TolFun',1e-9,'TolCon',1e-8);

pi_opt_bank = zeros(nper,1); % optimal probabilities for bank
V_opt_bank = zeros(nper,1); % value for the bank corresponding to pi_opt_bank
pi_prime_bank = zeros(nper,1); % critical values pi_prime
V_prime_bank = zeros(nper,1); % critical values V_prime
pi_real_bank = zeros(nper,1); % real probabilities that the bank will choose
V_real_bank = zeros(nper,1); % real values for bank
pi_bar_state = zeros(nper,1); % threshold probabilities for the state
v_state = zeros(nper,1); % value for the state
thetas = zeros(nper,1); % indicator of the bailout

pi_bar_numer = zeros(nper,1); % numerator for pi_bar formula
pi_bar_denom = zeros(nper,1); % denominator for pi_bar formula

% ************************************
%  1. Stage 0 (n=1, 1 baiout left)
% ************************************

% State's problem at the last stage: chooses pi_bar

f_state_0 = @(x) (- c + b + delta * c * (1-x)./(1-delta*x)).^2;
pi_bar_state(1) = fmincon(f_state_0,0.5,[],[],[],[],0,1); % threshold pi_bar_0
pi_bar_state(1)

% Bank's problem at the last stage:

% calculates optimal value pi_optimal 
f_opt_bank_0 = @(x) -x.*R(x)./(1-delta*x); % minus for minimization; x=pi; from eq.(27)
[pi_opt_bank(1),fval] = fmincon(f_opt_bank_0,0.5,[],[],[],[],0,1); % optimal pi_0
V_opt_bank(1) = -fval; % opitmal value

% calculates critical value pi_prime
% pi_prime_bank(1) = pi_opt_bank(1); % at the last stage pi_optimal = pi_prime
pi_prime_bank(1) = 1; % bank commits to any pi in order to be saved
V_prime_bank(1) = -f_opt_bank_0(pi_prime_bank(1));

% chooses real probability pi_real
   if  pi_opt_bank(1) < pi_bar_state(1) % if bank's optimal pi is too small
      
     if pi_bar_state(1) <= pi_prime_bank(1) % but if the bank can still make profit with higher pi   

         pi_real_bank(1) =  pi_bar_state(1); % bank switches to the required level of pi - pi_bar

     else
         
         pi_real_bank(1) =  pi_opt_bank(1); % otherwise bank chooses pi_opt_0 and gets v_0
     end
   
   else
       
       pi_real_bank(1) =  pi_opt_bank(1); % if optimal pi exceeds the threshold pi_bar, bank sticks to it

   end
   
% given the true probability chosen by the bank, define Bank's and State's real values:
     V_real_bank(1) = -f_opt_bank_0(pi_real_bank(1));
     v_state(1) = c * (1-pi_real_bank(1))./(1-delta*pi_real_bank(1));
   

if  pi_real_bank(1) >= pi_bar_state(1)
    thetas(1) = 1; % baiout if the bank is safe enough
end

pi_bar_numer(1) = c-(c-b)/delta;
pi_bar_denom(1) = b;


% **************************************
%  2. Stages 1,...,n (n+1 bailouts left)
% **************************************

% state's problem in the rest of the periods:
f_state = @(x,y) (- c + b + delta .* (b+delta*y) .* (1-x)./(1-delta*x)).^2;

% bank's problem in the rest of the periods:
f_bank = @(x,y) -((x.*(Rmin + (Rmax-Rmin)*(1-x))+(1-x)*(b+delta*y))./(1-delta*x)); % x=pi
f_crit = @(x,y,v0) (v0-((x.*(Rmin + (Rmax-Rmin)*(1-x))+(1-x)*(b+delta*y))./(1-delta*x))).^2; % x=pi, y=Vlag1, z=V0


for k=2:nper

% if at the previous stage the bank wasn't saved, jump to pi_0 (n=1) case:
if thetas(k-1) ==0
    pi_bar_state(k) = pi_bar_state(1);
    pi_opt_bank(k) = pi_opt_bank(1);
    pi_prime_bank(k) = pi_prime_bank(1);
    pi_real_bank(k) = pi_opt_bank(1);
    V_opt_bank(k) = V_opt_bank(1);
    V_prime_bank(k) = V_prime_bank(1);
    V_real_bank(k) = -f_opt_bank_0(pi_real_bank(k));
    v_state(k) =  c * (1 - pi_real_bank(k))/(1 - delta*pi_real_bank(k));

else % otherwise

    
% a) State's problem: 

% calculates threshold probabilities pi_bar:
f_state_opt =  @(x) f_state(x,v_state(k-1));
pi_bar_state(k) = fmincon(f_state_opt,0.5,[],[],[],[],0,1,[],options);


% b) Bank's problem: 

% calculates optimal probabilities and values:
f_opt_bank = @(x) f_bank(x,V_opt_bank(k-1));
[pi_opt_bank(k),fval] = fmincon(f_opt_bank,0.7,[],[],[],[],0,1);
V_opt_bank(k) = -fval; 

% calculates critical values:
f_crit_bank = @(x) f_crit(x,V_opt_bank(k-1),V_opt_bank(1));
[pi_prime_bank(k),fval] = fmincon(f_crit_bank,0.8,[],[],[],[],0,1,[],options);
% avoid ineficient corner solution pi = 0, because pi = 1 is optimal in
% this case (see the plot of f_crit_bank)
if pi_prime_bank(k)<0.5 && f_crit_bank(0)>=f_crit_bank(1)
    pi_prime_bank(k)=1;
end
V_prime_bank(k) = -f_opt_bank(pi_prime_bank(k)); 


% chooses real probabilities pi_real:   
   if  pi_opt_bank(k) < pi_bar_state(k) % if bank's optimal pi is too small
      
     if pi_bar_state(k) <= pi_prime_bank(k) % but if the bank can still make profit   
      
         pi_real_bank(k) =  pi_bar_state(k); % bank switches to the required level of pi - pi_bar
         V_real_bank(k) = -f_opt_bank(pi_real_bank(k));
         v_state(k) = (b + delta*v_state(k-1)) * (1 - pi_real_bank(k))/(1 - delta*pi_real_bank(k));

     else
         
         pi_real_bank(k) =  pi_opt_bank(1); % otherwise bank chooses pi_prime and gets v_0
         V_real_bank(k) = -f_opt_bank_0(pi_real_bank(k));
         v_state(k) =  c * (1 - pi_real_bank(k))/(1 - delta*pi_real_bank(k));
         % and no baiout - thetas(k) stays zero
     end
   
   else
     pi_real_bank(k) =  pi_opt_bank(k); % if optimal pi exceeds the threshold pi_bar, bank sticks to it
     V_real_bank(k) = -f_opt_bank(pi_real_bank(k));
     v_state(k) = (b + delta*v_state(k-1)) * (1 - pi_real_bank(k))/(1 - delta*pi_real_bank(k));

   end
end

if  pi_real_bank(k) >= pi_bar_state(k)
    thetas(k) = 1; % baiout if the bank is safe enough
end


pi_bar_numer(k) = (b + delta*v_state(k-1)) - (c-b)/delta;
pi_bar_denom(k) = (b + delta*v_state(k-1)) - (c-b);

end

V_state = v_state.*(1-delta*pi_real_bank)./(1-pi_real_bank);

end


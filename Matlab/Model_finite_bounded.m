%% Finite setting: 

% This file is the same as Model_finite except the probabilities are always
% bounded to [0,1]

% Solves the model in finite setting. Here the
% bank's problem and the state's problem are solved separately, then
% switching for the bank is implemented, then recalculating bank's value is
% implemented.

% For the newer versions, see the files Iterative_game_....m

close all
clear all
clc

delta = 2/3; % discount rate
Rmax = 9; % project's return in case of success
Rmin = 1;  % return on a safe project
b = 2; % bailout cost
c = 3; % deadweight cost to the state in case of bank's liquidation
nper = 10; % number of periods

% Define function R for any probability x: calculates the project return R
% for a given probability of success x
R = @(x) Rmin + (Rmax - Rmin)*(1-x);
 
% 3. Optimization:

% bank's problem at the last stage: max(pi) pi*R(pi)/(1-delta*pi)
f_opt_bank_0 = @(x) -x.*(Rmin + (Rmax-Rmin)*(1-x))./(1-delta*x); % minus for minimization; x=pi; from eq.(27)

% optimal value for period 0:
opt_pi_bank = zeros(nper,1);
V_bank = zeros(nper,1);
[opt_pi_bank(1),fval] = fmincon(f_opt_bank_0,0.5,[],[],[],[],0,1);
V_bank(1) = -fval;

% bank problem in the rest of the periods, eq.(27):

f_bank = @(x,y) -((x.*(Rmin + (Rmax-Rmin)*(1-x))+(1-x)*(b+delta*y))./(1-delta*x)); % x=pi
%  options = optimset('TolFun',1e-15);
for k=2:nper
    f_opt_bank = @(x) f_bank(x,V_bank(k-1));
[opt_pi_bank(k),fval] = fmincon(f_opt_bank,0.7,[],[],[],[],0,1);
V_bank(k) = -fval; 
end

% Analytical results:
% check that analytical solutions coinside with optimal values:

pi_bank_an = zeros(nper,1);
V_bank_an = zeros(nper,1);
temp_Vcheck = zeros(nper,1); 
pi_bank_an(1) = (1 - sqrt(1-Rmax*delta/(Rmax-Rmin)))/delta;
V_bank_an(1) = pi_bank_an(1)*R(pi_bank_an(1))/(1-delta*pi_bank_an(1));
for i=2:nper
    pi_bank_an(i) = (1 - sqrt(1 - delta*(Rmax - (b+delta*V_bank_an(i-1))*(1-delta))/(Rmax-Rmin)))/delta;
    V_bank_an(i) = (pi_bank_an(i)*R(pi_bank_an(i)) + (1-pi_bank_an(i))*(b+delta*V_bank_an(i-1)))/(1-delta*pi_bank_an(i));
end

plot(1:nper,flip(opt_pi_bank),1:nper,flip(pi_bank_an))
title('Optimal probabilities for the bank')
legend('Machine results','Analytical results')

%% State's problem:

% solve the equations from (20) and so on:
v_state_opt = zeros(nper,1);
pi_state_thresh = zeros(nper,1);

% n=0
f_state_0 = @(x) (- c + b + delta * c * (1-x)./(1-delta*x))^2;
pi_state_thresh(1) = fmincon(f_state_0,0.5,[],[],[],[],0,1);
v_state_opt(1) =  c * (1 - opt_pi_bank(1))/(1 - delta*opt_pi_bank(1));

% previous periods:
f_state = @(x,y) (- c + b + delta * (b+delta*y) * (1-x)./(1-delta*x))^2;

for i=2:nper
   f_state_opt =  @(x) f_state(x,v_state_opt(i-1));
   pi_state_thresh(i) = fmincon(f_state_opt,0.5,[],[],[],[],0,1);
  
   % BANK'S PROBABILITIES ARE TAKEN FOR Vs:
   v_state_opt(i) = (b + delta*v_state_opt(i-1)) * (1 - opt_pi_bank(i))/(1 - delta*opt_pi_bank(i));

%  pi_state_an(i) = ( b + delta*v_state_opt(i-1) - (c-b)/delta)/( b + delta*v_state_opt(i-1) - (c-b) );
end

figure
plot(1:nper,flip(opt_pi_bank),1:nper,flip(pi_state_thresh))
xlabel('Stage of the game'); ylabel('Probability'); legend('Bank', 'State')
title('Optimal Probabilities')

figure
plot(flip(v_state_opt))
title('State value')
 
%% State's problem: Change bank's pi if it's less than state's pi:

% solve the equations from (20) and so on:

v_state_opt_switch = zeros(nper,1); % State value if bank switches to state's pi
pi_state_thresh_switch = zeros(nper,1);
opt_pi_bank_switch = opt_pi_bank;
% n=0
f_state_0 = @(x) (- c + b + delta * c * (1-x)./(1-delta*x))^2;
pi_state_thresh_switch(1) = fmincon(f_state_0,0.5,[],[],[],[],0,1);

% bank "promises" the threshold pi in order to be saved at period n=1 even
% if it's optimal pi is lower:
if opt_pi_bank_switch(1) < pi_state_thresh_switch(1)
    opt_pi_bank_switch(1) = pi_state_thresh_switch(1);
end
v_state_opt_switch(1) =  c * (1 - opt_pi_bank_switch(1))/(1 - delta*opt_pi_bank_switch(1));

% previous periods:
f_state = @(x,y) (- c + b + delta * (b+delta*y) * (1-x)./(1-delta*x))^2;

for i=2:nper
   f_state_opt =  @(x) f_state(x,v_state_opt_switch(i-1));
   pi_state_thresh_switch(i) = fmincon(f_state_opt,0.5,[],[],[],[],0,1);
   
   % BANK'S PROBABILITIES CHANGED IF THEY ALE LOWER THAN PI_STATE AND THEN THEY ARE TAKEN FOR Vs:
   if opt_pi_bank_switch(i) < pi_state_thresh_switch(i)
    opt_pi_bank_switch(i) = pi_state_thresh_switch(i);
   end

   v_state_opt_switch(i) = (b + delta*v_state_opt_switch(i-1)) * (1 - opt_pi_bank_switch(i))/(1 - delta*opt_pi_bank_switch(i));

end

figure
plot(1:nper,flip(opt_pi_bank),1:nper,flip(pi_state_thresh_switch),1:nper,flip(opt_pi_bank_switch))
xlabel('Stage of the game'); ylabel('Probability'); legend('Bank', 'State','Bank switched')
title('Optimal Probabilities')

figure
plot(1:nper,flip(v_state_opt_switch),1:nper,flip(v_state_opt))
title('State value if bank switches to state pi')
legend('New value (bank switches)', 'Old value')

%% State's problem: min if bank's prob is not changed:

% solve the equations from (20) and so on:
v_state_opt_min = zeros(nper,1);
pi_state_thresh_min = zeros(nper,1);
opt_pi_bank_min = opt_pi_bank;

% n=0, pi_0 does not change
f_state_0 = @(x) (- c + b + delta * c * (1-x)./(1-delta*x))^2;
pi_state_thresh_min(1) = fmincon(f_state_0,0.5,[],[],[],[],0,1);

v_state_opt_min(1) =  c * (1 - opt_pi_bank_min(1))/(1 - delta*opt_pi_bank_min(1));

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
xlabel('Stage of the game'); ylabel('Probability'); legend(legstr,'Location','SouthEast')
title('Optimal Probabilities')

figure
plot(flip(v_state_opt_min)); ylim([0,1.2*max(v_state_opt_min)+1e-15])
if n_end ~= 0
    line([n_end,n_end],[0,1.2*max(v_state_opt_min)],'Color','r')
end
title('State value if it choses whether to save the bank')


%% Joint problem: after each stage bank promises pi <= pi_state, but recalculates it's value:

opt_pi_bank_joint = zeros(nper,1);
opt_pi_state_joint = zeros(nper,1);
V_bank_joint = zeros(nper,1);
v_state_joint = zeros(nper,1);

% n=0
f_opt_bank_0 = @(x) -x.*(Rmin + (Rmax-Rmin)*(1-x))./(1-delta*x); % minus for minimization; x=pi; from eq.(26)
f_state_0 = @(x) (- c + b + delta * c * (1-x)./(1-delta*x))^2;

[opt_pi_bank_joint(1),fval] = fmincon(f_opt_bank_0,0.5,[],[],[],[],0,1);
opt_pi_state_joint(1) = fmincon(f_state_0,0.5,[],[],[],[],0,1);

% bank "promises" the threshold pi in order to be saved at period n=1 even
% if it's optimal pi is lower:
if opt_pi_bank_joint(1) < opt_pi_state_joint(1)
    opt_pi_bank_joint(1) = opt_pi_state_joint(1);
end
V_bank_joint(1) = -f_opt_bank_0(opt_pi_bank_joint(1));
v_state_joint(1) =  c * (1 - opt_pi_bank_joint(1))/(1 - delta*opt_pi_bank_joint(1));


% previous periods:
f_bank = @(x,y) -((x.*(Rmin + (Rmax-Rmin)*(1-x))+(1-x)*(b+delta*y))./(1-delta*x)); % x=pi
f_state = @(x,y) (- c + b + delta * (b+delta*y) * (1-x)./(1-delta*x))^2;

%  options = optimset('TolFun',1e-15);
for i=2:nper
    f_opt_bank = @(x) f_bank(x,V_bank_joint(i-1));
    f_state_opt =  @(x) f_state(x,v_state_joint(i-1));
    
[opt_pi_bank_joint(i),fval] = fmincon(f_opt_bank,0.7,[],[],[],[],0,1);
   opt_pi_state_joint(i) = fmincon(f_state_opt,0.5,[],[],[],[],0,1);

% BANK'S PROBABILITIES CHANGED IF THEY ALE LOWER THAN PI_STATE AND THEN THEY ARE TAKEN FOR Vs:
   if opt_pi_bank_joint(i) < opt_pi_state_joint(i)
    opt_pi_bank_joint(i) = opt_pi_state_joint(i);
   end

V_bank_joint(i) = -f_opt_bank(opt_pi_bank_joint(i)); 
v_state_joint(i) = (b + delta*v_state_joint(i-1)) * (1 - opt_pi_bank_joint(i))/(1 - delta*opt_pi_bank_joint(i));

end


figure
plot(1:nper,flip(opt_pi_bank_joint),1:nper,flip(opt_pi_state_joint),1:nper,flip(opt_pi_bank_joint))
xlabel('Stage of the game'); ylabel('Probability'); legend('Bank', 'State','Bank switched')
title('Optimal probabilities in joint game')


figure
plot(1:nper,flip(v_state_joint))
title('State value in the joint game')






%% 1. Iterative game. Varying delta

% This file implements the interactive game between the bank and the state.
% It explores the solutions depending on 'delta'.
% The solution to the model in finite setting is implemented in the
% function fun_iter_new.m which is employed here. For the description of
% the solution algorithm see the file fun_iter_new.m

close all
clc

delta = 0.3:0.02:0.99; % discount rate
Rmax = 50; % project's return in case of success
Rmin = 1; % return on a safe project
b = 1; % bailout cost
c = 3; % deadweight cost to the state in case of bank's liquidation
nper = 10; % number of periods

pi_opt_bank_delta = zeros(nper,length(delta)); % optimal probabilities for the bank
V_opt_bank_delta = zeros(nper,length(delta)); % values for the bank corresponding to the optimal probabilities
pi_prime_bank_delta = zeros(nper,length(delta));  % critical values pi_prime for the bank (the maximal pi which the bank could accept, at this point it becomes indifferent between being bailed out and not bailed out.)
V_prime_bank_delta = zeros(nper,length(delta)); % critical values V_prime
pi_real_bank_delta = zeros(nper,length(delta)); % real probabilities chosen by the bank
V_real_bank_delta = zeros(nper,length(delta)); % real values V_bank
v_state_opt_delta = zeros(nper,length(delta)); % small v_state from eq.(18)
pi_bar_state_delta = zeros(nper,length(delta)); % threshold probability for the state at which it saves the bank
V_state_opt_delta = zeros(nper,length(delta)); % capital V_state from eq.(18)

thetas_delta = zeros(nper,length(delta)); % bailout indicators

for i=1:length(delta)
                   
[ans0, ans1, ans2, ans3, ans4, ans5, ans6, ans7, ans8, ans9] = fun_iter_new( delta(i), Rmax, Rmin, b, c,nper );
thetas_delta(:,i) = flip(ans0);
pi_real_bank_delta(:,i) = flip(ans1);
V_real_bank_delta(:,i) = flip(ans2);
pi_opt_bank_delta(:,i) = flip(ans3);
V_opt_bank_delta(:,i) = flip(ans4);
pi_bar_state_delta(:,i) = flip(ans5);
v_state_opt_delta(:,i) = flip(ans6);
pi_prime_bank_delta(:,i) = flip(ans7);
V_prime_bank_delta(:,i) = flip(ans8);
V_state_opt_delta(:,i) = flip(ans9);
end

% % deltas = repmat(delta,10,1);
% % pi_bar_delta = deltas.*pi_bar_state_delta;
% % pi_bar_delta_ineq = 1 - (1-pi_opt_bank_delta(10,:)).*(1-delta.*pi_bar_state_delta(10,:))./(1-delta.*pi_opt_bank_delta(10,:));
% % 
% % plot(delta,pi_opt_bank_delta(9,:),delta,pi_bar_delta_ineq,delta,pi_opt_bank_delta(10,:))
% % legend('pi bank 1','pi bar delta (RHS)','pi bank 0')
% % xlabel('Delta')
% % ylabel('$\pi$','Interpreter','latex','FontSize',24)

% % %% analytical check:
% % 
% % R = @(x) Rmin + (Rmax - Rmin)*(1-x);
% % 
% % pi_bank_an = zeros(nper,length(delta));
% % V_bank_an = zeros(nper,length(delta));
% % temp_Vcheck = zeros(nper,length(delta)); 
% % pi_bank_an(1,:) = (1 - sqrt(1-Rmax*delta/(Rmax-Rmin)))./delta;
% % V_bank_an(1,:) = pi_bank_an(1).*R(pi_bank_an(1))./(1-delta.*pi_bank_an(1));
% % for i=2:nper
% %     pi_bank_an(i,:) = (1 - sqrt(1 - delta.*(Rmax - (b+delta.*V_bank_an(i-1,:)).*(1-delta))./(Rmax-Rmin)))./delta;
% %     V_bank_an(i,:) = (pi_bank_an(i,:).*R(pi_bank_an(i,:)) + (1-pi_bank_an(i,:)).*(b+delta.*V_bank_an(i-1,:)))./(1-delta.*pi_bank_an(i,:));
% % end
% % 
% % 
% % v_state_an = zeros(nper,length(delta));
% % 
% % f_state_0 = @(x) - c + b + delta * c * (1-x)./(1-delta*x);
% % v_state_an(1,:) =  c * (1 - pi_bank_an(1,:))./(1 - delta.*pi_bank_an(1,:));
% % 
% % % analytical check:
% % pi_state_an = zeros(nper,length(delta));
% % pi_state_an(1,:) = ( c - (c-b)./delta)/b;
% % 
% % % previous periods:
% % f_state = @(x,y) - c + b + delta.* (b+delta.*y).* (1-x)./(1-delta.*x);
% % 
% % for i=2:nper
% %    f_state_opt =  @(x) f_state(x,v_state_an(i-1,:));
% % % !!!!MISTAKE:
% % v_state_an(i,:) = (b + delta.*v_state_an(i-1,:)).* (1 - pi_bank_an(i,:))./(1 - delta.*pi_bank_an(i,:)); % !!! should be pi_bank_an(nper-i+1,:)
% % 
% %    pi_state_an(i,:) = ( b + delta.*v_state_an(i-1,:) - (c-b)./delta)./( b + delta.*v_state_an(i-1,:) - (c-b) );
% % 
% % end


%% 3D Plots 

% plot threshold probability for the state:
figure
mesh(pi_bar_state_delta, 'LineWidth',1.5,'XData',delta); view(-27,40); rotate3d on
xlabel('Value of delta'); ylabel('Number of bailouts left'); zlabel('State Threshold Probability');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(delta(thetas_delta(10,:)==0),repmat(10,sum(thetas_delta(10,:)==0),1),pi_bar_state_delta(10,thetas_delta(10,:)==0),500,'k.')
cons = pi_opt_bank_delta<pi_real_bank_delta;
xcoord = repmat(delta,nper,1);
ycoord = repmat([1:nper]',1,length(delta));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),pi_bar_state_delta(cons==1),500,'g.')
% add blue surface for optimal bank's probability pi_opt 
mesh(pi_opt_bank_delta, 'LineWidth',1.5,'XData',delta,'EdgeColor','b'); view(-27,40); rotate3d on
% % % add yellow surface for threshold bank's probability pi_prime 
% % mesh(pi_prime_bank_delta, 'LineWidth',1.5,'XData',delta,'EdgeColor','y'); view(-27,40); rotate3d on
hold off


% plot real bank's probability:
figure
mesh(pi_real_bank_delta, 'LineWidth',1.5,'XData',delta); view(-27,40); rotate3d on
xlabel('Value of delta'); ylabel('Number of bailouts left'); zlabel('Bank Real Probability');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(delta(thetas_delta(10,:)==0),repmat(10,sum(thetas_delta(10,:)==0),1),pi_real_bank_delta(10,thetas_delta(10,:)==0),500,'k.')
cons = pi_opt_bank_delta<pi_real_bank_delta;
xcoord = repmat(delta,nper,1);
ycoord = repmat([1:nper]',1,length(delta));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),pi_real_bank_delta(cons==1),500,'g.')
hold off

% plot optimal value v for the state
figure
mesh(v_state_opt_delta, 'LineWidth',1.5,'XData',delta); view(-27,40); rotate3d on
xlabel('Value of delta'); ylabel('Number of bailouts left'); zlabel('Value v for the state');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(delta(thetas_delta(10,:)==0),repmat(10,sum(thetas_delta(10,:)==0),1),v_state_opt_delta(10,thetas_delta(10,:)==0),500,'k.')
cons = pi_opt_bank_delta<pi_real_bank_delta;
xcoord = repmat(delta,nper,1);
ycoord = repmat([1:nper]',1,length(delta));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),v_state_opt_delta(cons==1),500,'g.')
hold off

% plot optimal value V for the state
figure
mesh(V_state_opt_delta, 'LineWidth',1.5,'XData',delta); view(-27,40); rotate3d on
xlabel('Value of delta'); ylabel('Number of bailouts left'); zlabel('Value V for the state');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(delta(thetas_delta(10,:)==0),repmat(10,sum(thetas_delta(10,:)==0),1),V_state_opt_delta(10,thetas_delta(10,:)==0),500,'k.')
cons = pi_opt_bank_delta<pi_real_bank_delta;
xcoord = repmat(delta,nper,1);
ycoord = repmat([1:nper]',1,length(delta));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),V_state_opt_delta(cons==1),500,'g.')
hold off

% plot optimal probabilities for the bank
figure
mesh(pi_opt_bank_delta, 'LineWidth',1.5,'XData',delta); view(-27,40); rotate3d on
xlabel('Value of delta'); ylabel('Number of bailouts left'); zlabel('Optimal Probability for the Bank');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(delta(thetas_delta(10,:)==0),repmat(10,sum(thetas_delta(10,:)==0),1),pi_opt_bank_delta(10,thetas_delta(10,:)==0),500,'k.')
cons = pi_opt_bank_delta<pi_real_bank_delta;
xcoord = repmat(delta,nper,1);
ycoord = repmat([1:nper]',1,length(delta));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),pi_opt_bank_delta(cons==1),500,'g.')
hold off

% plot threshold probabilities for the bank
figure
mesh(pi_prime_bank_delta, 'LineWidth',1.5,'XData',delta); view(-27,40); rotate3d on
xlabel('Value of delta'); ylabel('Number of bailouts left'); zlabel('Critical Probability pi prime for the Bank');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(delta(thetas_delta(10,:)==0),repmat(10,sum(thetas_delta(10,:)==0),1),pi_prime_bank_delta(10,thetas_delta(10,:)==0),500,'k.')
cons = pi_opt_bank_delta<pi_real_bank_delta;
xcoord = repmat(delta,nper,1);
ycoord = repmat([1:nper]',1,length(delta));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),pi_prime_bank_delta(cons==1),500,'g.')
hold off





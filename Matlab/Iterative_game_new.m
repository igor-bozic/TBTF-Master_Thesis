%% 1. Iterative game. Varying c

% This file implements the interactive game between the bank and the state.
% It explores the solutions depending on 'c' and 'b'.
% The solution to the model in finite setting is implemented in the
% function fun_iter_new.m which is employed here. For the description of
% the solution algorithm see the file fun_iter_new.m

close all
clear all 
clc


delta = 0.5; % discount rate
Rmax = 10; % project's return in case of success
Rmin = 1; % return on a safe project
b = 2; % bailout cost
%c = 2:0.02:5; % deadweight cost to the state in case of bank's liquidation
c=2:1:3;
nper = 10; % number of periods


pi_opt_bank = zeros(nper,length(c)); % optimal probabilities for the bank
V_opt_bank = zeros(nper,length(c)); % values for the bank corresponding to the optimal probabilities
pi_prime_bank = zeros(nper,length(c)); % critical values pi_prime for the bank (the maximal pi which the bank could accept, at this point it becomes indifferent between being bailed out and not bailed out.)
V_prime_bank = zeros(nper,length(c)); % critical values V_prime
pi_real_bank = zeros(nper,length(c)); % real probabilities chosen by the bank
V_real_bank = zeros(nper,length(c)); % real values V_bank
v_state_opt = zeros(nper,length(c)); % small v_state from eq.(18)
pi_bar_state = zeros(nper,length(c)); % threshold probability for the state at which it saves the bank
V_state_opt = zeros(nper,length(c)); % capital V_state from eq.(18)

pi_bar_numer = zeros(nper, length(c)); % numerator from the pi_bar formula in eq.(23)
pi_bar_denom = zeros(nper, length(c));  % denominator from the pi_bar formula in eq.(23)

thetas = zeros(nper,length(c)); % bailout indicators

for i=1:length(c)
% the solution itself is implemented in the function fun_iter_new:                   
[ans0, ans1, ans2, ans3, ans4, ans5, ans6, ans7, ans8, ans9, ans10, ans11] = fun_iter_new(delta, Rmax, Rmin, b, c(i), nper);
thetas(:,i) = flip(ans0);
pi_real_bank(:,i) = flip(ans1);
V_real_bank(:,i) = flip(ans2);
pi_opt_bank(:,i) = flip(ans3);
V_opt_bank(:,i) = flip(ans4);
pi_bar_state(:,i) = flip(ans5);
v_state_opt(:,i) = flip(ans6);
pi_prime_bank(:,i) = flip(ans7);
V_prime_bank(:,i) = flip(ans8);
V_state_opt(:,i) = flip(ans9);

pi_bar_numer(:,i) = flip(ans10);
pi_bar_denom(:,i) = flip(ans11);

end


% check the kink at pi_bar_2, n=3

% marks for kink at n=3 (at pi_bar_2)
kink_2 = (pi_bar_state(9,:)>pi_bar_state(8,:)+1e-16 & pi_bar_state(7,:)>pi_bar_state(8,:)+1e-16);
kink_3 = (pi_bar_state(8,:)>pi_bar_state(7,:)+1e-16 & pi_bar_state(6,:)>pi_bar_state(7,:)+1e-16);
nkink = sum(kink_2);
bkink = c(kink_2);
% marks for the inequality with pi_1 to hold:
pi_bar_delta_ineq = 1 - (1-pi_opt_bank(10,:)).*(1-delta.*pi_bar_state(10,:))./(1-delta.*pi_opt_bank(10,:));
ineq_2 = pi_opt_bank(9,:)>pi_bar_delta_ineq+1e-16;

% mark the kinks everywhere:
% kinks = zeros(nper,length(c));
% for i=2:nper-1
%     
%  kinks(i,:) = (pi_bar_state(i+1,:)>pi_bar_state(i,:)+1e-16 & pi_bar_state(i-1,:)>pi_bar_state(i,:)+1e-16);
%   
% end

%% Plot State's probabilities
figure
mesh(pi_bar_state, 'LineWidth',1.5,'XData',c); view(-27,40); rotate3d on
xlabel('Value of c'); ylabel('Number of bailouts left'); zlabel('State Threshold Probability');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
cons = pi_opt_bank<pi_real_bank;
xcoord = repmat(c,nper,1);
ycoord = repmat([1:nper]',1,length(c));
scatter3(xcoord(cons==1),ycoord(cons==1),pi_bar_state(cons==1),500,'g.') % green marks for constrained probabilities
scatter3(xcoord(thetas==0),ycoord(thetas==0),pi_bar_state(thetas==0),500,'k.') % black marks for the cases where the bank is not saved
scatter3(xcoord(1,ineq_2),ycoord(9,ineq_2),pi_bar_state(9,ineq_2),500,'m.') % magenta marks for the inequality with pi_bank1 to hold 
scatter3(xcoord(1,kink_2),ycoord(8,kink_2),pi_bar_state(8,kink_2),500,'r.') % red marks for kink at pi_bar2

% scatter3(xcoord(kinks),ycoord(kinks),pi_bar_state(kinks),500,'r.') % red marks for all kinks
%  mesh(pi_prime_bank, 'LineWidth',1.5,'XData',b,'EdgeColor','y'); view(-27,40); rotate3d on
hold off

%% Figure 5
close all

figure('Position', [100, 50, 1250, 900])

c_a = 3.7;
c_b = 4.4;
c_c = 2;
plot(pi_bar_state(:,c==c_b),'Color',[0.5 0.5 0.5],'LineWidth',1.2,'LineStyle','-')
hold on
plot(pi_bar_state(:,c==c_a),'Color',[0.5 0.5 0.5],'LineWidth',2.5,'LineStyle','-')
plot(pi_bar_state(:,c==c_c),'Color',[0.5 0.5 0.5],'LineWidth',1.5,'LineStyle','-')
plot(pi_prime_bank(:,c==c_a),'Color',[0 0 0],'LineWidth',2.5,'LineStyle',':')
plot(pi_opt_bank(:,c==c_a),'Color',[0 0 0],'LineWidth',2.5,'LineStyle','-')


hold off

text(10.15,0,'$n$','Interpreter','latex','FontSize',24)
text(0.94,1.03,'$\pi$','Interpreter','latex','FontSize',24)
text(10.2,pi_opt_bank(nper,c==c_a),'$\pi_0$','Interpreter','latex','FontSize',24)
text(10.2,pi_prime_bank(nper,c==c_a),'$\pi^{\prime}_0$','Interpreter','latex','FontSize',24)
text(10.2,pi_bar_state(nper,c==c_a)+0.01,'$\bar{\pi}_{0}^{c_2}$','Interpreter','latex','FontSize',24)
text(10.2,pi_bar_state(nper,c==c_b)+0.01,'$\bar{\pi}_{0}^{c_3}$','Interpreter','latex','FontSize',24)
text(10.2,pi_bar_state(nper,c==c_c)+0.01,'$\bar{\pi}_{0}^{c_1}$','Interpreter','latex','FontSize',24)
text(7.55,0.676,'$H$','Interpreter','latex','FontSize',24)
text(4.18,0.596,'$J$','Interpreter','latex','FontSize',24)

text(1.8,pi_opt_bank(2,c==c_a)-0.025,'$\pi$','Interpreter','latex','FontSize',24)
text(1.8,pi_prime_bank(2,c==c_a)-0.025,'$\pi^{\prime}$','Interpreter','latex','FontSize',24)
text(1.8,pi_bar_state(2,c==c_a)-0.025,'$\bar{\pi}^{c_2}$','Interpreter','latex','FontSize',24)
text(1.8,pi_bar_state(2,c==c_b)-0.025,'$\bar{\pi}^{c_3}$','Interpreter','latex','FontSize',24)
text(1.8,pi_bar_state(2,c==c_c)-0.025,'$\bar{\pi}^{c_1}$','Interpreter','latex','FontSize',24)

text(0.7,1,'$1$','Interpreter','latex','FontSize',24)
text(0.7,0.006,'$0$','Interpreter','latex','FontSize',24)
text(0.92,-0.048,'$10$','Interpreter','latex','FontSize',24)
text(1.92,-0.048,'$9$','Interpreter','latex','FontSize',24)
text(2.95,-0.048,'$8$','Interpreter','latex','FontSize',24)
text(3.95,-0.048,'$7$','Interpreter','latex','FontSize',24)
text(4.95,-0.048,'$6$','Interpreter','latex','FontSize',24)
text(5.95,-0.048,'$5$','Interpreter','latex','FontSize',24)
text(6.95,-0.048,'$4$','Interpreter','latex','FontSize',24)
text(7.95,-0.048,'$3$','Interpreter','latex','FontSize',24)
text(8.95,-0.048,'$2$','Interpreter','latex','FontSize',24)
text(9.9,-0.048,'$1$','Interpreter','latex','FontSize',24)

% get rid of the ticks on top of the graph:
set(gca,'Box','off')
set(gca,'XTick',[0:10],'XTickLabel',{},'Ytick',[])
line('XData',[1,10],'Ydata',[1, 1],'LineStyle','-')
line('XData',[10,10],'Ydata',[0, 1],'LineStyle','-')
ylim([0,1]);

%% Figure 6 all lines
close all

figure('Position', [100, 50, 1250, 900])

c_a = 3.7;
c_b = 4.4;
c_c = 2;
odd = 2*(0:floor(size(pi_bar_state,2)/2))+1; % only odd columns
plot(pi_bar_state(:,odd),'Color',[0.75 0.75 0.75],'LineWidth',0.4,'LineStyle','-')
hold on
plot(pi_bar_state(:,c==c_b),'Color',[0.5 0.5 0.5],'LineWidth',2.5,'LineStyle','-')
plot(pi_bar_state(:,c==c_a),'Color',[0.5 0.5 0.5],'LineWidth',2.5,'LineStyle','-')
plot(pi_bar_state(:,c==c_c),'Color',[0.5 0.5 0.5],'LineWidth',2.5,'LineStyle','-')
plot(pi_prime_bank(:,c==c_a),'Color',[0 0 0],'LineWidth',2.5,'LineStyle',':')
plot(pi_opt_bank(:,c==c_a),'Color',[0 0 0],'LineWidth',2.5,'LineStyle','-')

hold off

text(10.15,0,'$n$','Interpreter','latex','FontSize',24)
text(0.94,1.03,'$\pi$','Interpreter','latex','FontSize',24)
text(10.2,pi_opt_bank(nper,c==c_a),'$\pi_0$','Interpreter','latex','FontSize',24)
text(10.2,pi_prime_bank(nper,c==c_a),'$\pi^{\prime}_0$','Interpreter','latex','FontSize',24)
text(10.2,pi_bar_state(nper,c==c_a)+0.01,'$\bar{\pi}_{0}^{c_2}$','Interpreter','latex','FontSize',24)
text(10.2,pi_bar_state(nper,c==c_b)+0.01,'$\bar{\pi}_{0}^{c_3}$','Interpreter','latex','FontSize',24)
text(10.2,pi_bar_state(nper,c==c_c)+0.01,'$\bar{\pi}_{0}^{c_1}$','Interpreter','latex','FontSize',24)
text(7.55,0.676,'$H$','Interpreter','latex','FontSize',24)
text(4.18,0.596,'$J$','Interpreter','latex','FontSize',24)

text(1.8,pi_opt_bank(2,c==c_a)-0.025,'$\pi$','Interpreter','latex','FontSize',24)
text(1.8,pi_prime_bank(2,c==c_a)-0.025,'$\pi^{\prime}$','Interpreter','latex','FontSize',24)
text(1.8,pi_bar_state(2,c==c_a)-0.025,'$\bar{\pi}^{c_2}$','Interpreter','latex','FontSize',24)
text(1.8,pi_bar_state(2,c==c_b)-0.025,'$\bar{\pi}^{c_3}$','Interpreter','latex','FontSize',24)
text(1.8,pi_bar_state(2,c==c_c)-0.025,'$\bar{\pi}^{c_1}$','Interpreter','latex','FontSize',24)

text(0.7,1,'$1$','Interpreter','latex','FontSize',24)
text(0.7,0.006,'$0$','Interpreter','latex','FontSize',24)
text(0.92,-0.048,'$10$','Interpreter','latex','FontSize',24)
text(1.92,-0.048,'$9$','Interpreter','latex','FontSize',24)
text(2.95,-0.048,'$8$','Interpreter','latex','FontSize',24)
text(3.95,-0.048,'$7$','Interpreter','latex','FontSize',24)
text(4.95,-0.048,'$6$','Interpreter','latex','FontSize',24)
text(5.95,-0.048,'$5$','Interpreter','latex','FontSize',24)
text(6.95,-0.048,'$4$','Interpreter','latex','FontSize',24)
text(7.95,-0.048,'$3$','Interpreter','latex','FontSize',24)
text(8.95,-0.048,'$2$','Interpreter','latex','FontSize',24)
text(9.9,-0.048,'$1$','Interpreter','latex','FontSize',24)

% get rid of the ticks on top of the graph:
set(gca,'Box','off')
set(gca,'XTick',[0:10],'XTickLabel',{},'Ytick',[])
line('XData',[1,10], 'Ydata',[1, 1],'LineStyle','-')
line('XData',[10,10], 'Ydata',[0, 1],'LineStyle','-')
line('XData',[1,1], 'Ydata',[0, 1],'LineStyle','-')
line('XData',[1,10], 'Ydata',[0, 0],'LineStyle','-')
ylim([0,1]);


%% Analytical check

% in analytical solution probabilities are not restricted to [0,1],
% therefore the values often fall out of that region

pi_bar_an = zeros(nper,length(c));
v_state_an = zeros(nper,length(c));

pi_bar_an(1,:) = (c-(c-b)/delta)./b;
v_state_an(1,:) = c.*(1-pi_opt_bank(nper,:))./(1-delta*pi_opt_bank(nper,:));
for i=2:nper
    pi_bar_an(i,:) = ((b+delta*v_state_an(i-1,:)) - (c-b)/delta)./(((b+delta*v_state_an(i-1,:)) - (c-b)));
    
    v_state_an(i,:) = (b + delta*v_state_an(i-1,:)).*(1-pi_opt_bank(nper-i+1,:))./(1-delta*pi_opt_bank(nper-i+1,:));
end

figure
mesh(pi_bar_an, 'LineWidth',1.5,'XData',c); view(-27,40); rotate3d on
xlabel('Value of c'); ylabel('Number of bailouts left'); zlabel('State Threshold Probability');


%% 2. Iterative game: Varying b
close all
clear all 
clc 

delta = 0.9; % discount rate
Rmax = 50; % project's return in case of success
Rmin = 1; % return on a safe project
nper = 10; % number of periods

b = 0:0.02:3;
c = 3;

pi_opt_bank = zeros(nper,length(b)); % optimal probabilities for the bank
V_opt_bank = zeros(nper,length(b)); % values for the bank corresponding to the optimal probabilities
pi_prime_bank = zeros(nper,length(b));  % critical values pi_prime for the bank (the maximal pi which the bank could accept, at this point it becomes indifferent between being bailed out and not bailed out.)
V_prime_bank = zeros(nper,length(b)); % critical values V_prime
pi_real_bank = zeros(nper,length(b)); % real probabilities chosen by the bank
V_real_bank = zeros(nper,length(b)); % real values V_bank
v_state_opt = zeros(nper,length(b)); % small v_state from eq.(18)
pi_bar_state = zeros(nper,length(b)); % threshold probability for the state at which it saves the bank
V_state_opt = zeros(nper,length(b)); % capital V_state from eq.(18)

pi_bar_numer = zeros(nper, length(b)); % numerator from the pi_bar formula in eq.(23)
pi_bar_denom = zeros(nper, length(b)); % denominator from the pi_bar formula in eq.(23)

thetas = zeros(nper,length(b)); % bailout indicators

for i=1:length(b)
                   
[ans0,ans1, ans2, ans3, ans4, ans5, ans6, ans7, ans8, ans9,ans10,ans11] = fun_iter_new( delta, Rmax, Rmin, b(i), c,nper );
thetas(:,i) = flip(ans0);
pi_real_bank(:,i) = flip(ans1);
V_real_bank(:,i) = flip(ans2);
pi_opt_bank(:,i) = flip(ans3);
V_opt_bank(:,i) = flip(ans4);
pi_bar_state(:,i) = flip(ans5);
v_state_opt(:,i) = flip(ans6);
pi_prime_bank(:,i) = flip(ans7);
V_prime_bank(:,i) = flip(ans8);
V_state_opt(:,i) = flip(ans9);

pi_bar_numer(:,i) = flip(ans10);
pi_bar_denom(:,i) = flip(ans11);

end


% check the kink at pi_bar_2, n=3

% marks for kink at n=3 (at pi_bar_2)
kink_2 = (pi_bar_state(9,:)>pi_bar_state(8,:)+1e-16 & pi_bar_state(7,:)>pi_bar_state(8,:)+1e-16);
kink_3 = (pi_bar_state(8,:)>pi_bar_state(7,:)+1e-16 & pi_bar_state(6,:)>pi_bar_state(7,:)+1e-16);
nkink = sum(kink_2);
% bkink = c(kink_2);
% marks for the inequality with pi_1 to hold:
pi_bar_delta_ineq = 1 - (1-pi_opt_bank(10,:)).*(1-delta.*pi_bar_state(10,:))./(1-delta.*pi_opt_bank(10,:));
ineq_2 = pi_opt_bank(9,:)>pi_bar_delta_ineq+1e-16;

% mark the kinks everywhere:
% kinks = zeros(nper,length(b));
% for i=2:nper-1
%     
%  kinks(i,:) = (pi_bar_state(i+1,:)>pi_bar_state(i,:)+1e-16 & pi_bar_state(i-1,:)>pi_bar_state(i,:)+1e-16);
%   
% end

% % figure
% % mesh(pi_bar_an, 'LineWidth',1.5,'XData',b); view(-27,40); rotate3d on
% % xlabel('Value of b'); ylabel('Number of bailouts left'); zlabel('State Threshold Probability');
% % % set(gca,'YTickLabel',10:-1:1)



%% 2D Plots:

% plot all probabilities
figure
plot(pi_bar_state,'b')
hold on
plot(pi_opt_bank,'g') % optimal probabilities for the bank plotted in green
plot(pi_prime_bank,'y') % threshold probabilities for the bank plotted in yellow
plot(pi_real_bank, 'r.') % mark real probabilities with red
hold off
set(gca,'XTickLabel',10:-1:1); ylabel('Probabilities'); xlabel('Stage of the game (number of bailouts left)');
title('All probabilities')

% plot only the points where the bank is saved
figure
temp=1:nper;
hold on
for i=1:length(b)
plot(temp(thetas(:,i)==1),pi_bar_state(thetas(:,i)==1,i),'b')
plot(temp(thetas(:,i)==1),pi_opt_bank(thetas(:,i)==1,i),'g')
plot(temp(thetas(:,i)==1),pi_prime_bank(thetas(:,i)==1,i),'y')
plot(temp(thetas(:,i)==1),pi_real_bank(thetas(:,i)==1,i), 'r.')
end
hold off
title('Only the points where the bank is saved')


% plot only the points where the bank is saved IN ALL PERIODS
figure
temp=1:nper;
hold on
for i=1:length(b)
    if sum(thetas(:,i)==1)==10
plot(temp(thetas(:,i)==1),pi_bar_state(:,i),'b')
plot(temp(thetas(:,i)==1),pi_opt_bank(:,i),'g')
plot(temp(thetas(:,i)==1),pi_prime_bank(:,i),'y')
plot(temp(thetas(:,i)==1),pi_real_bank(:,i), 'r.')
    end
end
hold off
set(gca,'XTickLabel',10:-1:1); ylabel('Probabilities'); xlabel('Stage of the game (number of bailouts left)');
title('Only the points where the bank is saved IN ALL PERIODS')


%% 3D Plots: 

% Plot Bank's probabilities:

figure
mesh(pi_real_bank, 'LineWidth',1.5,'XData',b); view(-27,40); rotate3d on
xlabel('Value of b'); ylabel('Number of bailouts left'); zlabel('Bank Real Probability');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
cons = pi_opt_bank<pi_real_bank;
xcoord = repmat(b,nper,1);
ycoord = repmat([1:nper]',1,length(b));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),pi_real_bank(cons==1),500,'g.')
% add black dots where the bank is not saved
scatter3(xcoord(thetas==0),ycoord(thetas==0),pi_real_bank(thetas==0),500,'k.')
% mesh(pi_prime_bank, 'LineWidth',1.5,'XData',b,'EdgeColor','y'); view(-27,40); rotate3d on
hold off

% plot value v for the state
figure
mesh(v_state_opt, 'LineWidth',1.5,'XData',b); view(-27,40); rotate3d on
xlabel('Value of b'); ylabel('Number of bailouts left'); zlabel('Value v for the state');
set(gca,'YTickLabel',10:-1:1)
hold on 
scatter3(b(thetas(10,:)==0),repmat(10,sum(thetas(10,:)==0),1),v_state_opt(10,thetas(10,:)==0),500,'k.')
cons = pi_opt_bank<pi_real_bank;
xcoord = repmat(b,nper,1);
ycoord = repmat([1:nper]',1,length(b));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),v_state_opt(cons==1),500,'g.')
% add black dots where the bank is not saved
scatter3(xcoord(thetas==0),ycoord(thetas==0),v_state_opt(thetas==0),500,'k.')
% red dots where there is a kink at n = 2
scatter3(xcoord(1,kink_2),ycoord(8,kink_2),v_state_opt(8,kink_2),500,'r.')
% magenta marks for the inequality with pi_bank1 to hold 
scatter3(xcoord(1,ineq_2),ycoord(9,ineq_2),v_state_opt(9,ineq_2),500,'m.') 
hold off

% % plot value V for the state
figure
mesh(V_state_opt, 'LineWidth',1.5,'XData',b); view(-27,40); rotate3d on
xlabel('Value of b'); ylabel('Number of bailouts left'); zlabel('Value V for the state');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(b(thetas(10,:)==0),repmat(10,sum(thetas(10,:)==0),1),V_state_opt(10,thetas(10,:)==0),500,'k.')
cons = pi_opt_bank<pi_real_bank;
xcoord = repmat(b,nper,1);
ycoord = repmat([1:nper]',1,length(b));
% add black dots where the bank is not saved
scatter3(xcoord(thetas==0),ycoord(thetas==0),V_state_opt(thetas==0),500,'k.')
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),V_state_opt(cons==1),500,'g.')
% blue dots where there is a kink at n = 2
scatter3(xcoord(1,kink_2),ycoord(8,kink_2),V_state_opt(8,kink_2),500,'b.')
% magenta marks for the inequality with pi_bank1 to hold 
scatter3(xcoord(1,ineq_2),ycoord(9,ineq_2),V_state_opt(9,ineq_2),500,'m.') 
hold off

% % plot real value V_real for the state
figure
mesh(V_real_bank, 'LineWidth',1.5,'XData',b); view(146,32); rotate3d on
xlabel('Value of b'); ylabel('Number of bailouts left'); zlabel('Value V for the Bank');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(b(thetas(10,:)==0),repmat(10,sum(thetas(10,:)==0),1),V_real_bank(10,thetas(10,:)==0),500,'k.')
cons = pi_opt_bank<pi_real_bank;
xcoord = repmat(b,nper,1);
ycoord = repmat([1:nper]',1,length(b));
% add black dots where the bank is not saved
scatter3(xcoord(thetas==0),ycoord(thetas==0),V_real_bank(thetas==0),500,'k.')
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),V_real_bank(cons==1),500,'g.')
hold off

% plot optimal probabilities for the bank:
figure
mesh(pi_opt_bank, 'LineWidth',1.5,'XData',b); view(-27,40); rotate3d on
xlabel('Value of b'); ylabel('Number of bailouts left'); zlabel('Optimal Probability for the Bank');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(b(thetas(10,:)==0),repmat(10,sum(thetas(10,:)==0),1),pi_opt_bank(10,thetas(10,:)==0),500,'k.')
cons = pi_opt_bank<pi_real_bank;
xcoord = repmat(b,nper,1);
ycoord = repmat([1:nper]',1,length(b));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),pi_opt_bank(cons==1),500,'g.')
% add black dots where the bank is not saved
scatter3(xcoord(thetas==0),ycoord(thetas==0),pi_opt_bank(thetas==0),500,'k.')
hold off

% plot the threshold probability pi_prime for the bank
figure
mesh(pi_prime_bank, 'LineWidth',1.5,'XData',b); view(-27,40); rotate3d on
xlabel('Value of b'); ylabel('Number of bailouts left'); zlabel('Critical Probability for the Bank pi prime');
set(gca,'YTickLabel',10:-1:1)
hold on % add dots where the bank is not saved
scatter3(b(thetas(10,:)==0),repmat(10,sum(thetas(10,:)==0),1),pi_prime_bank(10,thetas(10,:)==0),500,'k.')
cons = pi_opt_bank<pi_real_bank;
xcoord = repmat(b,nper,1);
ycoord = repmat([1:nper]',1,length(b));
% green dots where the state's probability is binding
scatter3(xcoord(cons==1),ycoord(cons==1),pi_prime_bank(cons==1),500,'g.')
% add black dots where the bank is not saved
scatter3(xcoord(thetas==0),ycoord(thetas==0),pi_prime_bank(thetas==0),500,'k.')
hold off

% % bailout = pi_prime_bank>pi_bar_state;
% % sum(sum(thetas ~= bailout))
% % b(sum(thetas ~= bailout)==1)

%% inequality with pi_bank1 

% pi_bar_delta = delta*pi_bar_state;

% deltas = repmat(delta,10,1);
% pi_bar_delta = deltas.*pi_bar_state_delta;
pi_bar_delta_ineq = 1 - (1-pi_opt_bank(10,:)).*(1-delta.*pi_bar_state(10,:))./(1-delta.*pi_opt_bank(10,:));

plot(b,pi_opt_bank(9,:),b,pi_bar_delta_ineq,b,pi_opt_bank(10,:))
legend('pi bank 1','pi bar delta (RHS)','pi bank 0')

b_condition1 = c*(1-delta); % bailouts not necessary in infinite case
b_condition2 = (c-delta^2*v_state_opt)/(1+delta);
b_condition_kink2 = ((1-delta)./(1-pi_real_bank(nper-1,:))).*((1-pi_real_bank(nper,:))./(1-delta*pi_real_bank(nper,:)))*c;

frac = @(x) (1-x)/(1-delta*x);
b_condition_kink3 = (1-frac(pi_real_bank(nper-2,:))*delta^2).*frac(pi_real_bank(nper,:))*c./(frac(pi_real_bank(nper-2,:))./frac(pi_real_bank(nper-1,:)) - frac(pi_real_bank(nper-2,:))*delta - 1);
                        
%% Num and Denom
figure
mesh(pi_bar_numer, 'LineWidth',1.5,'XData',b); view(72,38); rotate3d on
hold on
scatter3(xcoord(1,kink_2),ycoord(8,kink_2),pi_bar_numer(8,kink_2),500,'r.') % red marks for kink at pi_bar2
hold off
xlabel('Value of b'); ylabel('Stage of the game'); zlabel('Numerator')

figure
mesh(pi_bar_denom, 'LineWidth',1.5,'XData',b); view(72,38); rotate3d on
hold on
scatter3(xcoord(1,kink_2),ycoord(8,kink_2),pi_bar_denom(8,kink_2),500,'r.') % red marks for kink at pi_bar2
xlabel('Value of b'); ylabel('Stage of the game'); zlabel('Denominator')
hold off





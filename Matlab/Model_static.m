%% Static Setting 

% In the static setting the optimal solution is found by grid search. That
% is, for each value of probability in a grid the corresponding Expected
% return (EU) is calculated. The optimal probability is the value that
% corresponds to the maximum EU.

close all
clear all
clc

% set the variables values:
Rmax = 10; % project's return in case of success
Rmin = 1; % return on a safe project
b = 2; % bailout cost
c = 3; % deadweight cost to the state in case of bank's liquidation
accuracy = 0.001; % indecate the accuracy level for optimal probabilities (0.001 is a good choice)

% 1. Grid search

% calculations:
pi = (0:accuracy:1)'; % create a grid (string of values) of probabiliites
Rstep = (Rmax - Rmin)*accuracy; % step in vector of returns
Rvec = Rmin + (Rmax - Rmin)*(1-pi); % vector of returns

% expected returns:
EU = Rvec.*pi; % bank's expected utility wihtout baiout
EU_b = Rvec.*pi + b*(1-pi); % bank's expected utility with bailout
EU_c = Rvec.*pi - c*(1-pi); % social utility with bailout

% optimal values of expected returns:
[Opt_EU, ind_EU] = max(EU); 
[Opt_EU_b, ind_EU_b] = max(EU_b); 
[Opt_EU_c, ind_EU_c] = max(EU_c); 

% corresponding optimal probabilities:
Opt_prob_EU = pi(ind_EU);
Opt_prob_EU_b = pi(ind_EU_b);
Opt_prob_EU_c = pi(ind_EU_c);

% optimal EUs given optimal probability with collateral:
Opt_c_EU = EU(ind_EU_c);
Opt_c_EU_b = EU_b(ind_EU_c);

% differences between optimal EUs and optimal EU under collateral:
EU_diff = Opt_EU - Opt_c_EU;
EU_diff_rel = EU_diff/Opt_c_EU; % diff relative to EU under collateral
EU_b_diff = Opt_EU_b - Opt_c_EU_b;
EU_b_diff_rel = EU_b_diff/Opt_c_EU_b; % diff relative to EU under collateral

% Summarizinng table:
var_names = {'max_EU_value','optim_pi','EU_under_opt_c', 'EU_diff', 'Rel_diff'};
types = {'EU', 'EU_b','EU_c'};
EU_table = table([Opt_EU;Opt_EU_b;Opt_EU_c],...
                 [Opt_prob_EU;Opt_prob_EU_b;Opt_prob_EU_c],...
                 [Opt_c_EU;Opt_c_EU_b;Opt_EU_c],...
                 [EU_diff;EU_b_diff;0],...
                 [EU_diff_rel;EU_b_diff_rel;0],...
                 'VariableNames',var_names,'RowNames',types);
disp(EU_table)


%% Plot: Figure 2
close all

figure('Position', [100, 50, 1250, 900])

% plot:
plot(pi,EU,'Color',[0 0 0],'LineWidth',2.5,'LineStyle','-')
hold on
plot(pi,EU_b,'Color',[0.5 0.5 0.5],'LineWidth',2.5,'LineStyle','--')
plot(pi,EU_c,'Color',[0.3 0.3 0.3],'LineWidth',2.5,'LineStyle',':')
hold off
set(gca,'XTick',[],'Ytick',[])
ylim([1.1*min(EU_c),1.23*max(EU_b)]);

% add axes ticks:
text(-0.05,-c,'-$c$','Interpreter','latex','FontSize',24)
text(-0.035,0,'$0$','Interpreter','latex','FontSize',24)
text(-0.035,b,'$b$','Interpreter','latex','FontSize',24)
text(-0.01,1.3*max(EU_b),'$V$','Interpreter','latex','FontSize',24)
text(Opt_prob_EU_b-0.06,-0.4,'$\pi^B(1)$','Interpreter','latex','FontSize',24)
text(Opt_prob_EU-0.05,-1.2,'$\pi^B(0)=\pi^*$','Interpreter','latex','FontSize',24)
text(Opt_prob_EU_c-0.01,-0.4,'$\pi^{**}$','Interpreter','latex','FontSize',24)
text(0.98,-0.4,'$1$','Interpreter','latex','FontSize',24)
text(1.02,0,'$\pi$','Interpreter','latex','FontSize',24)
text(1.015,EU(end),'$\underline{R}$','Interpreter','latex','FontSize',24)

% add formulas:
text(0.07,b+0.1,'$(1-\pi)b$','Interpreter','latex','FontSize',24, 'Rotation',33)
text(0.14,0.65,'$(1-\pi)c$','Interpreter','latex','FontSize',24, 'Rotation',33)

% add dotted lines:
line('XData',[Opt_prob_EU_b,Opt_prob_EU_b], 'Ydata',[0 Opt_EU_b],'LineStyle',':','LineWidth',1)
line('XData',[Opt_prob_EU,Opt_prob_EU], 'Ydata',[-0.8 Opt_EU],'LineStyle',':','LineWidth',1)
line('XData',[Opt_prob_EU_c,Opt_prob_EU_c], 'Ydata',[0 Opt_EU_c],'LineStyle',':','LineWidth',1)
% line('XData',[0,Opt_prob_EU_b], 'Ydata',[Opt_EU_b, Opt_EU_b],'LineStyle',':','LineWidth',1.5)
% line('XData',[0,Opt_prob_EU], 'Ydata',[Opt_EU, Opt_EU],'LineStyle',':','LineWidth',1.5)
% line('XData',[0,Opt_prob_EU_c], 'Ydata',[Opt_EU_c, Opt_EU_c],'LineStyle',':','LineWidth',1.5)
line('XData',[0,1], 'Ydata',[0, 0],'LineStyle','-')

% add arrows:
annotation('doublearrow',[Opt_prob_EU_b*0.788, Opt_prob_EU_b*0.68],[0.5, 0.63])
annotation('doublearrow',[Opt_prob_EU_b*0.676, Opt_prob_EU_b*0.6],[0.637, 0.73])


%% Save to file:
fileID = fopen('Figure2.png','w+');
print('-dpng','Figure2.png');
fclose(fileID);
fileID = fopen('Figure2.eps','w+');
print('-depsc','Figure2.eps');
fclose(fileID);



%% Analytical form:

% solutions derived manually:

pi_star_an = Rmax / (2*(Rmax-Rmin)); % social optimum

pi_bank_an = (Rmax - b) / (2*(Rmax-Rmin)); % bank optimum with bailout

pi_social_an = (Rmax + c) / (2*(Rmax-Rmin)); % social optimum with bailout




%% Infinite Setting 

% In infinite setting the optimal solution is found by grid search. That
% is, for each value of probability in a grid the corresponding Expected
% return (EU) is calculated. The optimal probability is the value that
% corresponds to the maximum EU.

close all
clear all
clc

% set the variables' values:
delta = 2/3; % discount rate
r = 1; 
Rmax = 15; % project's return in case of success
Rmin = 1; % return on a safe project
b = 1.1; % bailout cost
c = 3; % deadweight cost to the state in case of bank's liquidation
accuracy = 0.001; % indecate the accuracy level for optimal probabilities (0.001 is a good choice)

% 1. Grid search

% calculations:
pi = (0:accuracy:1)'; % create a grid (string of values) of probabiliites
Rstep = (Rmax - Rmin)*accuracy; % step in vector of returns
Rvec = Rmin + (Rmax - Rmin)*(1-pi); % vector of returns

% expected returns:
EU = (Rvec.*pi./(1-delta*pi)); % bank's expected utility wihtout baiout
EU_b = ((Rvec.*pi + b*(1-pi))./(1-delta)); % bank's expected utility with bailout
EU_c = ((Rvec.*pi - c*(1-pi))./(1-delta*pi)); % social utility with bailout

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

% % plot:
% leg = {'EU','EU + bailout','EU - collateral'};
% plot(pi,EU,pi,EU_b,pi,EU_c); legend(leg,'Location','SouthEast')
% title('Expected Utilities'); xlabel('pi'); ylabel('EU') , ylim([1.1*min(EU_c),1.1*max(EU_b)]);

%% Plot: Figure 3

close all

figure('Position', [100, 50, 1250, 900])

% shade the area between pi_B_1 and pi_prime:
ymax = 1.23*max(EU_b);
ycoords = [0, 1.23*max(EU_b);0, ymax];
fun_EU_b = @(x) ((Rmin + (Rmax - Rmin)*(1-x))*x + b*(1-x))./(1-delta) - max(EU);
x3 = fsolve(fun_EU_b,0.7);  
xcoords = [Opt_prob_EU_b, x3];
plot(pi,EU,'Color',[0 0 0],'LineWidth',2.5,'LineStyle','-')
hold on
area(xcoords,ycoords,'FaceColor',[0.9,0.9,0.9],'LineStyle','none')
plot(pi,EU,'Color',[0 0 0],'LineWidth',2.5,'LineStyle','-')
plot(pi,EU_b,'Color',[0.5 0.5 0.5],'LineWidth',2.5,'LineStyle','--')
hold off
set(gca,'XTick',[],'Ytick',[])
ylim([0,ymax]);

% add axes ticks:
text(-0.03,0,'$0$','Interpreter','LaTex','FontSize',24)
text(-0.06,b/(1-delta),'$\frac{b}{1- \delta}$','Interpreter','LaTex','FontSize',24)
text(-0.0065,ymax+0.5,'$V$','Interpreter','LaTex','FontSize',24)
text(Opt_prob_EU_b-0.01,-0.7,'$\pi^B(1)$','Interpreter','LaTex','FontSize',24)
text(Opt_prob_EU-0.01,-0.7,'$\pi^B(0)$','Interpreter','LaTex','FontSize',24)
text(1.02,-c-0.1,'$\pi$','Interpreter','LaTex','FontSize',24)
text(1.015,EU(end),'$\frac{\underline{R}}{1- \delta}$','Interpreter','LaTex','FontSize',24)
text(0.99,-0.6,'$1$','Interpreter','latex','FontSize',24)
text(1.02,0,'$\pi$','Interpreter','latex','FontSize',24)

% add formulas:
text(0.177,b+4.5,'$\frac{(1-\pi)b}{1- \delta}$','Interpreter','latex','FontSize',24)

% add arrow: 
annotation('doublearrow',[pi(round(length(pi)/3)), pi(round(length(pi)/3))],[(EU(round(length(pi)/3)))/(1.12*max(EU_b)), (EU_b(round(length(pi)/3)))/(1.4*max(EU_b))])

% add dotted lines:
line('XData',[Opt_prob_EU_b,Opt_prob_EU_b], 'Ydata',[0 ymax],'LineStyle',':','LineWidth',1)
% line('XData',[Opt_prob_EU_b,Opt_prob_EU_b], 'Ydata',[Opt_EU_b ymax],'LineStyle','-','LineWidth',1)
% line('XData',[Opt_prob_EU_b,1], 'Ydata',[ymax ymax],'LineStyle','-','LineWidth',1)
line('XData',[Opt_prob_EU,Opt_prob_EU], 'Ydata',[0 Opt_EU],'LineStyle',':','LineWidth',1)
line('XData',[0,x3], 'Ydata',[Opt_EU, Opt_EU],'LineStyle',':','LineWidth',1)
line('XData',[Opt_prob_EU_b*1.3,Opt_prob_EU_b*1.3], 'Ydata',[0, ymax],'LineStyle',':','LineWidth',1.5)
line('XData',[Opt_prob_EU_b*0.75,Opt_prob_EU_b*0.75], 'Ydata',[0, ymax],'LineStyle',':','LineWidth',1.5)
line('XData',[x3,x3], 'Ydata',[0,ymax],'LineStyle',':','LineWidth',1)
% line('XData',[x3,x3], 'Ydata',[Opt_EU, ymax],'LineStyle','-','LineWidth',1)


text(Opt_prob_EU_b*1.28,1.265*max(EU_b),'$\bar{\pi}_2$','Interpreter','LaTex','FontSize',24)
text(Opt_prob_EU_b*0.73,1.265*max(EU_b),'$\bar{\pi}_1$','Interpreter','LaTex','FontSize',24)
text(x3-0.01,1.265*max(EU_b),'$\bar{\pi}_3$','Interpreter','LaTex','FontSize',24)
text(x3-0.01,-0.6,'$\pi^{\prime}$','Interpreter','LaTex','FontSize',24)

set(gca,'Layer','top','Box','on')


%% Save to file:
fileID = fopen('Figure3.eps','w+');
print('-depsc','Figure3.eps');
fclose(fileID);
fileID = fopen('Figure3.png','w+');
print('-dpng','Figure3.png');
fclose(fileID);

%% Figure 4
close all

figure('Position', [100, 50, 1250, 900])

set(gca,'XTick',[],'Ytick',[],'Layer','top', 'Box', 'on')
ylim([0,1]);xlim([0,1]);

% fill the area
hold on
area([0,Opt_prob_EU_b],[0,Opt_prob_EU_b;0,Opt_prob_EU_b],'FaceColor',[0.9,0.9,0.9],'LineStyle','none')
area([Opt_prob_EU_b, x3],[0,Opt_prob_EU_b;0,x3],'FaceColor',[0.9,0.9,0.9],'LineStyle','none')

hold off

% main lines
line('XData',[0 Opt_prob_EU_b], 'Ydata',[Opt_prob_EU_b,Opt_prob_EU_b],'LineStyle','-','LineWidth',2.5)
line('XData',[Opt_prob_EU_b x3], 'Ydata',[Opt_prob_EU_b,x3],'LineStyle','-','LineWidth',2.5)
line('XData',[x3 1], 'Ydata',[Opt_prob_EU,Opt_prob_EU],'LineStyle','-','LineWidth',2.5)

% additional lines
line('XData',[0 0], 'Ydata',[0 1],'LineStyle','-','LineWidth',1)
line('XData',[0 1], 'Ydata',[Opt_prob_EU,Opt_prob_EU],'LineStyle',':','LineWidth',1)
line('XData',[Opt_prob_EU_b Opt_prob_EU_b], 'Ydata',[0,Opt_prob_EU_b],'LineStyle',':','LineWidth',1)
line('XData',[x3 x3], 'Ydata',[0,x3],'LineStyle',':','LineWidth',1)

% text
text(Opt_prob_EU_b/2.5,0.3,'not binding','Interpreter','LaTex','FontSize',24)
text(Opt_prob_EU_b*1.3,0.3,'binding','Interpreter','LaTex','FontSize',24)
% text(x3+0.003,0.3,'viol-','Interpreter','LaTex','FontSize',24)
% text(x3+0.003,0.27,'ated','Interpreter','LaTex','FontSize',24)

% labels
text(-0.03,0,'$0$','Interpreter','LaTex','FontSize',24)
text(-0.03,0.987,'$1$','Interpreter','LaTex','FontSize',24)
text(-0.009,1.03,'$\pi$','Interpreter','LaTex','FontSize',24)
text(Opt_prob_EU_b-0.01,-0.045,'$\pi^B(1)$','Interpreter','LaTex','FontSize',24)
text(-0.09,Opt_prob_EU_b,'$\pi^B(1)$','Interpreter','LaTex','FontSize',24)
text(x3-0.01,-0.04,'$\pi^{\prime}$','Interpreter','LaTex','FontSize',24)
text(-0.09,Opt_prob_EU,'$\pi^B(0)$','Interpreter','LaTex','FontSize',24)
% text(0.91,Opt_prob_EU+0.035,'$\pi^B(0)$','Interpreter','LaTex','FontSize',24)
text(0.987,-0.04,'$1$','Interpreter','latex','FontSize',24)
text(1.02,0,'$\bar{\pi}$','Interpreter','latex','FontSize',24)
text(x3-0.33,Opt_prob_EU-0.09,'$\bar{\pi}$','Interpreter','LaTex','FontSize',24)
text(Opt_prob_EU_b-0.017,Opt_prob_EU_b+0.026,'$B$','Interpreter','latex','FontSize',24)
text(x3-0.01,x3+0.025,'$A$','Interpreter','latex','FontSize',24)


%% Save to file:
fileID = fopen('Figure4.eps','w+');
print('-depsc','Figure4.eps');
fclose(fileID);
fileID = fopen('Figure4.png','w+');
print('-dpng','Figure4.png');
fclose(fileID);

%% table:
var_names = {'max_EU_value','optim_pi','EU_under_opt_c', 'EU_diff', 'Rel_diff'};
types = {'EU', 'EU_b','EU_c'};
EU_table = table([Opt_EU;Opt_EU_b;Opt_EU_c],...
                 [Opt_prob_EU;Opt_prob_EU_b;Opt_prob_EU_c],...
                 [Opt_c_EU;Opt_c_EU_b;Opt_EU_c],...
                 [EU_diff;EU_b_diff;0],...
                 [EU_diff_rel;EU_b_diff_rel;0],...
                 'VariableNames',var_names,'RowNames',types);
disp(EU_table)


%% 2. Analytical form: 

pi_state_an = (b - (1-delta)*c)/(delta*b); % state's optimum 

pi_bank_an = (1 - sqrt( 1 - (Rmax*delta)/(Rmax-Rmin) )) / delta; % bank optimum without bailout

pi_bank_an_b = (Rmax - b)/(2*(Rmax-Rmin) ); % bank optimum with bailout



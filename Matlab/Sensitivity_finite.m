%% OLD FILE

% it investigates sensitivity of the solutions to varying b, c, and Rmax
% but it uses old function fun_finite.m which ignores the interaction
% between the bank and the state.

% the newest is the file Iterative_game_new.m and function fun_iter_new.m

%% c
close all

delta = 2/3; 
Rmax = 9;
Rmin = 1;
b = 2.5;
c = 1:0.25:10;
nper = 10; % number of periods

pi_bank_matx = zeros(nper, length(c));
pi_state_matx = zeros(nper, length(c));
nend_vect = zeros(length(c),1);
v_bank_matx = zeros(nper,length(c));
v_state_matx = zeros(nper,length(c));

for i=1:length(c)
    
    close all
    
[ans1, ans2, nend_vect(i),ans4,ans5] = fun_finite( delta, Rmax, Rmin, b, c(i),nper );
pi_bank_matx(:,i) = flip(ans1);
pi_state_matx(:,i) = flip(ans2);
v_bank_matx(:,i) = flip(ans4);
v_state_matx(:,i) = flip(ans5);
end
res_bank_c = pi_bank_matx;
res_state_c = pi_state_matx;

close all

mesh(res_state_c, 'LineWidth',1.5,'XData',c); view(68,34); rotate3d on
xlabel('Value of c'); ylabel('Number of bailouts left'); zlabel('State Threshold Probability');
set(gca,'YTickLabel',10:-1:1)
hold on
z_coord = zeros(length(c),1);
for i=1:length(c)
    if nend_vect(i)>0
z_coord(i) = res_state_c(nend_vect(i),i);
    else
z_coord(i) = res_state_c(nper,i);
    end
end
scatter3(c(nend_vect~=0),nend_vect(nend_vect~=0),z_coord(nend_vect~=0),500,'k.')
hold off

% plot the kink appearance
figure
kink_indx = res_state_c(9,:)<res_state_c(10,:);
plot(c,kink_indx,'r.'); title('Kink index plotted')

% plot only the first few values to see the kink
figure
nkink = sum(kink_indx==0)+10;
plot(res_state_c(:,1:nkink),'b')
ylabel('Threshold probability'); xlabel('Number of bailouts left'); title('State Threshold Probabilities');
set(gca,'XTickLabel',10:-1:1)
hold on 
plot(res_state_c(:,kink_indx(1:nkink)==1),'r')
plot(res_bank_c(:,1),'g')
hold off

%% threshold c values :

c_thresh = zeros(nper,1);
for i=1:nper
  c_thresh(i) = fun_c_thresh( flip(pi_bank_matx(:,1)),i, b, delta );
end

plot(c_thresh,'b.')
% check that it coinsides with an. solution, the first 3 values:

c_check1 = b*(1-delta*pi_bank_matx(end,1))/(1-delta)

c_check2 = b*(1+delta*(1-pi_bank_matx(9,1))/(1-delta*pi_bank_matx(9,1)))/(1-delta^2*((1-pi_bank_matx(9,1))/(1-delta*pi_bank_matx(9,1)))*((1-pi_bank_matx(end,1))/(1-delta*pi_bank_matx(end,1))))

c_check3 = b*(1+delta*(1-pi_bank_matx(8,1))/(1-delta*pi_bank_matx(8,1))+...
   delta^2*(1-pi_bank_matx(9,1))/(1-delta*pi_bank_matx(9,1))*...
           (1-pi_bank_matx(8,1))/(1-delta*pi_bank_matx(8,1)))/...
     (1-delta^3*...
     (1-pi_bank_matx(8,1))/(1-delta*pi_bank_matx(8,1))*...
     (1-pi_bank_matx(9,1))/(1-delta*pi_bank_matx(9,1))*...
     (1-pi_bank_matx(end,1))/(1-delta*pi_bank_matx(end,1)))
 
c_thresh

%% varying b
close all

delta = 2/3; 
Rmax = 9;
Rmin = 1;
b = 1:0.05:3;
c = 3;
nper = 10; % number of periods

pi_bank_matx = zeros(nper, length(b));
pi_state_matx = zeros(nper, length(b));
nend_vect = zeros(length(b),1);

for i=1:length(b)
    
    close all
    
[ans1, ans2, nend_vect(i)] = fun_finite( delta, Rmax, Rmin, b(i), c,nper );
pi_bank_matx(:,i) = flip(ans1);
pi_state_matx(:,i) = flip(ans2);

end
res_bank_b = pi_bank_matx;
res_state_b = pi_state_matx;

close all

mesh(pi_state_matx, 'LineWidth',1.5,'XData',b); view(300,42); rotate3d on
xlabel('Value of b'); ylabel('Stage of the game'); zlabel('Probability')
hold on
z_coord = zeros(length(b),1);
for i=1:length(b)
    if nend_vect(i)>0
z_coord(i) = pi_state_matx(nend_vect(i),i);
    else
z_coord(i) = pi_state_matx(nper,i);
    end
end
scatter3(b(nend_vect~=0),nend_vect(nend_vect~=0),z_coord(nend_vect~=0),500,'k.')

%%  varying Rmax
close all

delta = 2/3; 
Rmax = 1:0.5:40;
Rmin = 1;
b = 3;
c = 7;
nper = 10; % number of periods

pi_bank_matx = zeros(nper, length(Rmax));
pi_state_matx = zeros(nper, length(Rmax));
nend_vect = zeros(length(Rmax),1);

for i=1:length(Rmax)
    
    close all
    
[ans1, ans2, nend_vect(i)] = fun_finite( delta, Rmax(i), Rmin, b, c,nper );
pi_bank_matx(:,i) = flip(ans1);
pi_state_matx(:,i) = flip(ans2);

end
res_bank_R = pi_bank_matx;
res_state_R = pi_state_matx;


close all

mesh(pi_state_matx, 'LineWidth',1.5,'XData',Rmax); view(72,38); rotate3d on
xlabel('Value of R'); ylabel('Stage of the game'); zlabel('Probability')
hold on
z_coord = zeros(length(Rmax),1);
for i=1:length(Rmax)
    if nend_vect(i)>0
z_coord(i) = pi_state_matx(nend_vect(i),i);
    else
z_coord(i) = pi_state_matx(nper,i);
    end
end
scatter3(Rmax(nend_vect~=0),nend_vect(nend_vect~=0),z_coord(nend_vect~=0),500,'k.')

%% deriving pi_prime for the bank

close all

delta = 2/3; 
Rmax = 9;
Rmin = 1;
b = 2;
c = 3;
nper = 10; % number of periods

pi_bank_matx = zeros(nper, length(c));
pi_state_matx = zeros(nper, length(c));
nend_vect = zeros(length(c),1);
V_bank_matx = zeros(nper,length(c));
V_state_matx = zeros(nper,length(c));
pi_prime_bank = zeros(nper,length(c));
temp_v_prime_bank = zeros(nper,length(c));

for i=1:length(c)
    
[ans1, ans2, nend_vect(i), ans4, ans5, ans6, ans7] = fun_finite( delta, Rmax, Rmin, b, c(i),nper );
pi_bank_matx(:,i) = flip(ans1);
pi_state_matx(:,i) = flip(ans2);
V_bank_matx(:,i) = flip(ans4);
V_state_matx(:,i) = flip(ans5);
pi_prime_bank(:,i) = flip(ans6);
temp_v_prime_bank(:,i) = flip(ans7);
close all
end


close all
% compare with analytical solution:
temp_pi1_prime = ( -b+Rmax + sqrt( (b-Rmax)^2 - 4*(Rmax-Rmin)*(ans4(1)*(1-delta)-b) ) )/(2*(Rmax-Rmin));

% plot only the first few values to see the kink

kink_indx = pi_state_matx(9,:)<pi_state_matx(10,:);
nkink = sum(kink_indx==0);

figure
plot(pi_state_matx(:,1:nkink),'b')
ylabel('Threshold probability'); xlabel('Number of bailouts left'); title('State Threshold Probabilities');
set(gca,'XTickLabel',10:-1:1)
hold on 
plot(pi_state_matx(:,kink_indx==1),'r')
plot(pi_bank_matx(:,1),'Color',[0,0.6,0.4],'LineWidth',2)
plot(pi_prime_bank(:,1),'k','LineWidth',2)
hold off
% % %% save to file
% % fileID = fopen('piprime.png','w');
% % print('-dpng','piprime.png');
% % fclose(fileID);
% % 

%% Iterative game:

close all

delta = 2/3; 
Rmax = 9;
Rmin = 1;
b = 2;
c = 2:0.05:5;
nper = 10; % number of periods

pi_opt_bank = zeros(nper,length(c));
V_opt_bank = zeros(nper,length(c));
pi_prime_bank = zeros(nper,length(c)); % critical values pi_prime
V_prime_bank = zeros(nper,length(c)); % critical values V_prime
pi_real_bank = zeros(nper,length(c));
V_real_bank = zeros(nper,length(c)); % critical values V_prime
v_state_opt = zeros(nper,length(c));
pi_bar_state = zeros(nper,length(c));

for i=1:length(c)
    
% fun_finite( delta, Rmax, Rmin, b, c(i),nper )    
[ans1, ans2, ans3, ans4, ans5, ans6, ans7, ans8] = fun_finite_switch( delta, Rmax, Rmin, b, c(i),nper );
pi_real_bank(:,i) = flip(ans1);
V_real_bank(:,i) = flip(ans2);
pi_opt_bank(:,i) = flip(ans3);
V_opt_bank(:,i) = flip(ans4);
pi_bar_state(:,i) = flip(ans5);
v_state_opt(:,i) = flip(ans6);
pi_prime_bank(:,i) = flip(ans7);
V_prime_bank(:,i) =flip(ans8);

end


% % %%
% % figure
% % plot(1:nper, pi_bar_state) 
% % hold on 
% % plot(1:nper,pi_opt_bank,'Color',[0,0.6,0.4],'LineWidth',3)
% % plot( 1:nper, pi_prime_bank,'k','LineWidth',3)
% % plot(1:nper,pi_real_bank,'b.')
% % title('Probabilities for the bank')
% % 
% % hold off
% % 
% % figure
% % plot(V_real_bank)
% % hold on
% % plot(V_opt_bank,'Color',[0,0.6,0.4],'LineWidth',3)
% % plot(V_prime_bank,'k','LineWidth',3)
% % title('Values for the bank')
% % 
% % hold off
% % 
% % figure
% % plot(v_state_opt)
% % title('Value for the state')

% %% save to file
% fileID = fopen('piprime.png','w');
% print('-dpng','piprime.png');
% fclose(fileID);

%% check b s.t. the puzzle inequality holds, one example

delta = 2/3; 
Rmax = 9;
Rmin = 1;
b = 1.3;
c = 3;
nper = 10; % number of periods
    
[topt_pi_bank_min,tpi_state_thresh_min ,tn_end, tV_bank, tv_state_opt_min,...
               tpi_prime, tV_prime_bank ] = fun_finite( delta, Rmax, Rmin, b, c,nper );

%% iterate b s.t. the puzzle inequality holds

delta = 2/3; 
Rmax = 9;
Rmin = 1;
b = 1:0.02:3;
c = 3;
nper = 10; % number of periods

pi_bank_matx_puzzle = zeros(nper, length(b));
pi_state_matx_puzzle = zeros(nper, length(b));
nend_vect_puzzle = zeros(length(b),1);
v_state_matx_puzzle = zeros(nper, length(b));

pi_bar_numer_puzzle = zeros(nper, length(b));
pi_bar_denom_puzzle =  zeros(nper, length(b));

for i=1:length(b)
    
[topt_pi_bank_min,tpi_state_thresh_min ,tn_end, tV_bank, tv_state_opt_min,...
               tpi_prime, tV_prime_bank, tpi_bar_numer,tpi_bar_denom  ] = fun_finite( delta, Rmax, Rmin, b(i), c,nper );
pi_bank_matx_puzzle(:,i) = flip(topt_pi_bank_min);
pi_state_matx_puzzle(:,i) = flip(tpi_state_thresh_min);
nend_vect_puzzle(i) = tn_end;
v_state_matx_puzzle(:,i) = flip(tv_state_opt_min);

pi_bar_numer_puzzle(:,i) = flip(tpi_bar_numer);
pi_bar_denom_puzzle(:,i) = flip(tpi_bar_denom);

close all
end

% plots
figure
plot(pi_bank_matx_puzzle); title('pi bank')

figure
plot(pi_state_matx_puzzle(:,pi_state_matx_puzzle(nper,:)>pi_state_matx_puzzle(nper-1,:) & ...
        v_state_matx_puzzle(nper,:)<v_state_matx_puzzle(nper-1,:)),'r')
hold on
plot(pi_state_matx_puzzle(:,pi_state_matx_puzzle(nper,:)<=pi_state_matx_puzzle(nper-1,:)),'b')
plot(pi_state_matx_puzzle(:,pi_state_matx_puzzle(nper,:)>pi_state_matx_puzzle(nper-1,:) & ...
        v_state_matx_puzzle(nper,:)>=v_state_matx_puzzle(nper-1,:)),'g')
    plot(pi_state_matx_puzzle(:,1.22<b & b<2),'k.')
    title('Pi bar')
hold off

figure
plot(v_state_matx_puzzle(:,pi_state_matx_puzzle(nper,:)>pi_state_matx_puzzle(nper-1,:) & ...
        v_state_matx_puzzle(nper,:)<v_state_matx_puzzle(nper-1,:)),'r')
hold on
plot(v_state_matx_puzzle(:,pi_state_matx_puzzle(nper,:)<=pi_state_matx_puzzle(nper-1,:)),'b')
plot(v_state_matx_puzzle(:,pi_state_matx_puzzle(nper,:)>pi_state_matx_puzzle(nper-1,:) & ...
        v_state_matx_puzzle(nper,:)>=v_state_matx_puzzle(nper-1,:)),'g')
    title('V state')
    plot(v_state_matx_puzzle(:,1.22<b & b<2),'k.')
hold off

figure
plot(pi_bar_numer_puzzle)
title('Numerator')

figure
mesh(pi_bar_numer_puzzle, 'LineWidth',1.5,'XData',b); view(72,38); rotate3d on
xlabel('Value of b'); ylabel('Stage of the game'); zlabel('Numerator')

mesh(pi_bar_denom_puzzle, 'LineWidth',1.5,'XData',b); view(72,38); rotate3d on
xlabel('Value of b'); ylabel('Stage of the game'); zlabel('Denominator')




figure
plot(pi_bar_denom_puzzle)
title('Denominator')

%% Calculating threshold values of b for Num and Den to be <>=0

close all

% 1. solve the model for different values of b.
delta = 2/3; 
Rmax = 9;
Rmin = 1;
b = 1:0.05:3;
c = 3;
nper = 10; % number of periods

pi_opt_bank = zeros(nper,length(b));
V_opt_bank = zeros(nper,length(b));
pi_prime_bank = zeros(nper,length(b)); % critical values pi_prime
V_prime_bank = zeros(nper,length(b)); % critical values V_prime
pi_real_bank = zeros(nper,length(b));
V_real_bank = zeros(nper,length(b)); % critical values V_prime
v_state_opt = zeros(nper,length(b));
pi_bar_state = zeros(nper,length(b));

for i=1:length(b)
    
% fun_finite( delta, Rmax, Rmin, b, c(i),nper )    
[ans1, ans2, ans3, ans4, ans5, ans6, ans7, ans8] = fun_finite_switch( delta, Rmax, Rmin, b(i), c,nper );
pi_real_bank(:,i) = flip(ans1);
V_real_bank(:,i) = flip(ans2);
pi_opt_bank(:,i) = flip(ans3);
V_opt_bank(:,i) = flip(ans4);
pi_bar_state(:,i) = flip(ans5);
v_state_opt(:,i) = flip(ans6);
pi_prime_bank(:,i) = flip(ans7);
V_prime_bank(:,i) =flip(ans8);

end

% 2. in each case find the critical value
crit_b_numer = zeros(nper,length(b));
crit_b_denom = zeros(nper,length(b));

% first values for pi_bar_0
crit_b_numer(end,:) = (1-delta)*c;
crit_b_denom(end,:) = 0;

% analytical check of pi1,pi2,pi3
an_check_num = zeros(3,length(b));
an_check_den = zeros(3,length(b));
differ = zeros(3,length(b));

for val = 1:length(b)

for k = 2:nper % solve for numer and denom for each n
   crit_b_numer(nper-k+1,val) = fun_numer( k, delta, c, flip(pi_real_bank(:,val))) ;
   crit_b_denom(nper-k+1,val) = fun_denom( k, delta, c, flip(pi_real_bank(:,val))) ;
end
    % find analytical value for pi1,pi2,pi3:
   [an_check_num(:,val),an_check_den(:,val)] = fun_numden_anal( delta, c, flip(pi_real_bank(:,val)));
   differ(:,val) = crit_b_numer(nper-3:nper-1,val) - flip(an_check_num(:,val));
end

% check that the differences btw program and analytics = 0 for pi1,pi2,pi3:
sum(sum(differ>1e-10))

plot(crit_b_numer,'g')
hold on
plot(crit_b_denom,'b')
hold off
title('Critical values for b for the numerator(green) and denomenator(blue) to be negative')
xlabel('Stage'); ylabel('Value of b')

% fileID = fopen('crit_b.png','w');
% print('-dpng','crit_b.png');
% fclose(fileID);
% 

% 3. analysis

% find where crit_denom > crit_numer to see which one is binding:
temp = sum(sum(crit_b_denom > crit_b_numer));

% find where b is smaller than critical values for the numerator and
% denominator:
temp_an_num = zeros(nper,length(b));
temp_an_den = zeros(nper,length(b));

for i=1:length(b)
 temp_an_num(:,i) = crit_b_numer(:,i) > b(i);
 temp_an_den(:,i) = crit_b_denom(:,i) > b(i);
end
 
 
 
%
temp = repmat(1:nper,length(b),1)';
figure
plot(1:nper, pi_bar_state) 
hold on 
plot(1:nper,pi_opt_bank,'Color',[0,0.6,0.4],'LineWidth',3)
plot( 1:nper, pi_prime_bank,'k','LineWidth',3)
plot(1:nper,pi_real_bank,'b.')
scatter(temp(temp_an_num==1),pi_real_bank(temp_an_num==1),'r.')
title('Probabilities for the bank')

hold off

figure
plot(V_real_bank)
hold on
plot(V_opt_bank,'Color',[0,0.6,0.4],'LineWidth',3)
plot(V_prime_bank,'k','LineWidth',3)
title('Values for the bank')

hold off

figure
plot(v_state_opt)
title('Value for the state')








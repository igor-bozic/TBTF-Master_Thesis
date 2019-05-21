""" 

Function(s): model_finite_bounded, banks_problem_analytical_results, states_problem, states_problem_change_banks_pi,
             states_problem_min_banks_prob_not_changed, joint_problem

Description:
   This file is the same as model_finite_bounded except the probabilities are always bounded to [0,1]

   Solves the model in finite setting. Here the bank's problem and the state's problem are solved separately, then
   switching for the bank is implemented, then recalculating bank's value is implemented.

Reference:
   The code below has been taken form the Department of Banking and Finance. It has been rewritten from Matlab.
   Variable names have been changed for a better understanding. For a better understanding it was devided
   into multiple functions.

Additional: PDF and HTML (mpld3) output has been included. For a better understanding it was devided into multiple
   functions

Author(s): Igor Bozic, Department of Banking and Finance

"""

from numpy.lib.twodim_base import flipud
from scipy import optimize
import matplotlib.pyplot as pyplot, mpld3
import math


def model_finite_bounded(r_max, r_min, bailout_cost, deadweight_cost, discount_rate, nr_of_periods):

   nr_of_periods = int(round(nr_of_periods)) # needs to be an intger number

   # Define function R for any probability x: calculates the project return R
   # for a given probability of success x
   R = lambda x: r_min + (r_max - r_min) * (1 - x)

   html_text_fig1, opt_pi_bank, pi_bank_analytical = banks_problem_analytical_results(r_max, r_min, bailout_cost,
                                                                                      discount_rate, nr_of_periods, R)
   html_text_fig2, html_text_fig3, v_state_opt = states_problem(bailout_cost, deadweight_cost, discount_rate,
                                                                nr_of_periods, opt_pi_bank)
   html_text_fig4, html_text_fig5 = states_problem_change_banks_pi(bailout_cost, deadweight_cost, discount_rate,
                                                                   nr_of_periods, opt_pi_bank, v_state_opt)
   html_text_fig6, html_text_fig7 = states_problem_min_banks_prob_not_changed(bailout_cost, deadweight_cost,
                                                                              discount_rate, nr_of_periods, opt_pi_bank)
   html_text_fig8, html_text_fig9 = joint_problem(r_max, r_min, bailout_cost, deadweight_cost, discount_rate,
                                                  nr_of_periods)

   return html_text_fig1, html_text_fig2, html_text_fig3, html_text_fig4, html_text_fig5, html_text_fig6,\
          html_text_fig7, html_text_fig8, html_text_fig9

def banks_problem_analytical_results(r_max, r_min, bailout_cost, discount_rate, nr_of_periods, R):
   # Bank's problem:

   # bank's problem at the last stage: max(pi) pi*R(pi)/(1-delta*pi)
   f_opt_bank_0 = lambda x: -x * (r_min + (r_max - r_min) * (1 - x)) / (1 - discount_rate * x)

   # Analytical results:

   # optimal value for period 0
   opt_pi_bank = [0] * nr_of_periods
   v_bank = [0] * nr_of_periods

   opt_pi_bank[0] = optimize.fmin(f_opt_bank_0, 0.5) # optimization using: Simplex method: the Nelder-Mead
   v_bank[0] = -f_opt_bank_0(opt_pi_bank[0])

   # bank problem in the rest of the periods, eq.(28)
   f_bank = lambda x,y: -((x * (r_min + (r_max - r_min) * (1 - x)) + (1 - x) * (bailout_cost + discount_rate * y)) /
                          (1 - discount_rate * x))
   for k in range(1, nr_of_periods):
      f_opt_bank_0 = lambda x: f_bank(x, v_bank[k - 1])
      opt_pi_bank[k] = optimize.fmin(f_opt_bank_0, 0.7)
      v_bank[k] = -f_opt_bank_0(opt_pi_bank[k])

   # Analytical results:
   # check that analytical solutions coinside with optimal values:
   pi_bank_analytical = [0] * nr_of_periods
   v_bank_analytical = [0] * nr_of_periods
   temp_v_vheck = [0] * nr_of_periods
   pi_bank_analytical[0] = (1 - math.sqrt(1 - r_max * discount_rate / (r_max - r_min))) / discount_rate
   v_bank_analytical[0] = pi_bank_analytical[0] * R(pi_bank_analytical[0]) / (1 - discount_rate * pi_bank_analytical[0])
   for i in range(1, nr_of_periods):
      pi_bank_analytical[i] = (1 - math.sqrt(1 - discount_rate * (r_max - (bailout_cost + discount_rate * v_bank_analytical[i - 1]) *
                                                                  (1 - discount_rate)) / (r_max - r_min))) / discount_rate
      v_bank_analytical[i] = (pi_bank_analytical[i] * R(pi_bank_analytical[i]) + (1 - pi_bank_analytical[i]) *
                              (bailout_cost + discount_rate * v_bank_analytical[i - 1])) / (1 - discount_rate * pi_bank_analytical[i])

   nr_per = [0] * nr_of_periods
   for i in range(0, nr_of_periods):
      nr_per[i] = i

   # Create plots and pdf file. Save pdf file into graphics folder
   fig1, ax = pyplot.subplots()
   ax.plot(nr_per, flipud(opt_pi_bank), label='Machine Results', color='red',  linestyle=':')
   ax.plot(nr_per, flipud(pi_bank_analytical), label='Analytical Results', color='blue', linestyle='--')
   ax.set_xlabel('Number of Periods')
   ax.set_ylabel('Probabilities')
   ax.set_title('Optimal probabilities for the bank')
   ax.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig1 = mpld3.fig_to_html(fig1)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_Optimal_Probabilities_for_the_Bank.pdf', format='pdf')
   pyplot.close(fig1)

   return html_text_fig1, opt_pi_bank, pi_bank_analytical

def states_problem(bailout_cost, deadweight_cost, discount_rate, nr_of_periods, opt_pi_bank):
   # State's Problem

   # solve the equations from (20) on:
   v_state_opt = [0] * nr_of_periods
   pi_state_thresh = [0] * nr_of_periods

   x = math.pow(5,2)

   # Period n=0
   f_state_0 = lambda x: math.pow(- deadweight_cost + bailout_cost + discount_rate * deadweight_cost * (1 - x) /
                                  (1 - discount_rate * x),2)
   pi_state_thresh[0] = optimize.fsolve(f_state_0, 0.5)
   v_state_opt[0] = deadweight_cost * (1 - opt_pi_bank[0]) / (1 - discount_rate * opt_pi_bank[0])

   # previous periods:
   f_state = lambda x,y: math.pow(- deadweight_cost + bailout_cost + discount_rate * (bailout_cost + discount_rate * y)
                                  * (1 - x) / (1 - discount_rate * x), 2)

   # solve for the rest of the periods:
   for i in range(1, nr_of_periods):
      f_state_opt = lambda x: f_state(x, v_state_opt[i - 1])
      pi_state_thresh[i] = optimize.fsolve(f_state_opt, 0.5)

      #BANK's PROBABILITIE'sS ARE TAKEN FOR v_state
      v_state_opt[i] = (bailout_cost + discount_rate * v_state_opt[i - 1]) * (1 - opt_pi_bank[i]) / \
                       (1 - discount_rate * opt_pi_bank[i])

   nr_per = [0] * nr_of_periods
   for i in range(0, nr_of_periods):
      nr_per[i] = i

   # Create plots and pdf file. Save pdf file into graphics folder
   fig2, ax = pyplot.subplots()
   ax.plot(nr_per, flipud(opt_pi_bank), label='Bank', color='red',  linestyle=':')
   ax.plot(nr_per, flipud(pi_state_thresh), label='State', color='blue', linestyle='--')
   ax.set_xlabel('Stage of the Game')
   ax.set_ylabel('Probability')
   ax.set_title('Optimal Probabilities')
   ax.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig2 = mpld3.fig_to_html(fig2)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_Optimal_Probabilities.pdf', format='pdf')
   pyplot.close(fig2)

   fig3, bx = pyplot.subplots()
   bx.plot(nr_per, flipud(v_state_opt), label='Bank', color='red')
   bx.set_title('State Value')
   bx.legend(loc='lower left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig3 = mpld3.fig_to_html(fig3)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_State_Value.pdf', format='pdf')
   pyplot.close(fig3)

   return html_text_fig2, html_text_fig3, v_state_opt

def states_problem_change_banks_pi(bailout_cost, deadweight_cost, discount_rate, nr_of_periods, opt_pi_bank, v_state_opt):
   # State's problem: Change Bank's pi if it's less then State's pi

   # solve the equation from (20) on:
   v_state_opt_switch = [0] * nr_of_periods
   pi_state_tresh_switch = [0] * nr_of_periods
   opt_pi_bank_switch = [0] * nr_of_periods

   # n=0
   f_state_0 = lambda x: math.pow(- deadweight_cost + bailout_cost + discount_rate * deadweight_cost * (1 - x) /
                                  (1 - discount_rate * x),2)
   pi_state_tresh_switch[0] = optimize.fsolve(f_state_0, 0.5)

   # Bank's "promises" the threshold pi in order to be saved at period n=1 even
   # if it's optimal pi is lower:
   if opt_pi_bank[0] < pi_state_tresh_switch[0]:
      opt_pi_bank_switch[0] = pi_state_tresh_switch[0]
   else:
      opt_pi_bank_switch[0] = opt_pi_bank[0]

   v_state_opt_switch[0] = deadweight_cost * (1 - opt_pi_bank_switch[0]) / (1 - discount_rate * opt_pi_bank_switch[0])

   # previous periods
   f_state = lambda x,y: math.pow(- deadweight_cost + bailout_cost + discount_rate * (bailout_cost + discount_rate * y) * \
                                                            (1 - x) / (1 - discount_rate * x),2)

   # solve for all the previous periods:
   for i in range(1, nr_of_periods):
      f_state_opt = lambda x: f_state(x, v_state_opt_switch[i-1])
      pi_state_tresh_switch[i] = optimize.fsolve(f_state_opt, 0.5)

      # BANK's PROBABILITIES CHANGED IF THEY ALE LOWER THAN PI_STATE AND THEN THEY ARE TAKEN FOR V's:
      if opt_pi_bank[i] < pi_state_tresh_switch[i]:
         opt_pi_bank_switch[i] = pi_state_tresh_switch[i]
      else:
         opt_pi_bank_switch[i] = opt_pi_bank[i]

      v_state_opt_switch[i] = (bailout_cost + discount_rate * v_state_opt_switch[i-1]) * (1 - opt_pi_bank_switch[i])\
                              / (1 - discount_rate * opt_pi_bank_switch[i])

   nr_per = [0] * nr_of_periods
   for i in range(0, nr_of_periods):
      nr_per[i] = i

   # Create plots and pdf file. Save pdf file into graphics folder
   fig4, ax = pyplot.subplots()
   ax.plot(nr_per, flipud(opt_pi_bank), label='Bank', color='red')
   ax.plot(nr_per, flipud(pi_state_tresh_switch), label='State', color='blue', linestyle=':')
   ax.plot(nr_per, flipud(opt_pi_bank_switch), label='Bank Switched', color='green', linestyle='--')
   ax.set_xlabel('Stage of the Game')
   ax.set_ylabel('Probability')
   ax.set_title('Optimal Probabilities')
   ax.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig4 = mpld3.fig_to_html(fig4)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_Optimal_Probabilities_Change_Banks_PI.pdf', format='pdf')
   pyplot.close(fig4)

   fig5, bx = pyplot.subplots()
   bx.plot(nr_per, flipud(v_state_opt_switch), label='New value (Bank switches)', color='red', linestyle=':')
   bx.plot(nr_per, flipud(v_state_opt), label='Old value', color='blue', linestyle='--')
   bx.set_title('State value if Bank switches to state pi')
   bx.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig5 = mpld3.fig_to_html(fig5)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_State_Value_if_Bank_switches_to_State_PI.pdf', format='pdf')
   pyplot.close(fig5)

   return html_text_fig4, html_text_fig5

def states_problem_min_banks_prob_not_changed(bailout_cost, deadweight_cost, discount_rate, nr_of_periods, opt_pi_bank):
   # State's problem: min if Bank's probabilitie is not changed

   # Solve the equation from (20) on:
   v_state_opt_min = [0] * nr_of_periods
   pi_state_tresh_min = [0] * nr_of_periods
   opt_pi_bank_min = opt_pi_bank

   # n=0, pi=0 does not change
   f_state_0 = lambda x: math.pow(- deadweight_cost + bailout_cost + discount_rate * deadweight_cost * (1 - x) /
                                  (1 - discount_rate * x),2)
   pi_state_tresh_min[0] = optimize.root(f_state_0, 0.5, method='lm').x
   v_state_opt_min[0] = deadweight_cost * (1 - opt_pi_bank_min[0]) / (1 - discount_rate * opt_pi_bank_min[0])

   # previous periods, n > 0:
   f_state = lambda x,y: math.pow(- deadweight_cost + bailout_cost + discount_rate * (bailout_cost + discount_rate * y) * \
                                                            (1 - x) / (1 - discount_rate * x),2)

   n_end = 0

   for i in range(1, nr_of_periods):
      f_state_opt = lambda x: f_state(x, v_state_opt_min[i-1])
      pi_state_tresh_min[i] = optimize.root(f_state_opt, 0.5, method='lm').x

      if min(deadweight_cost, bailout_cost + discount_rate * v_state_opt_min[i-1]) == deadweight_cost:
         n_end = nr_of_periods - i + 1

      v_state_opt_min[i] = min(deadweight_cost, bailout_cost + discount_rate * v_state_opt_min[i-1]) *\
                           (1 - opt_pi_bank_min[i]) / (1 - discount_rate * opt_pi_bank_min[i])


   nr_per = [0] * nr_of_periods
   for i in range(0, nr_of_periods):
      nr_per[i] = i

   # Create plots and pdf file. Save pdf file into graphics folder
   fig6, ax = pyplot.subplots()
   ax.plot(nr_per, flipud(opt_pi_bank_min), label='Bank', color='red', linestyle=':')
   ax.plot(nr_per, flipud(pi_state_tresh_min), label='State', color='blue', linestyle='--')
   ax.set_xlabel('Stage of the Game')
   ax.set_ylabel('Probability')
   ax.set_title('Optimal Probabilities')
   ax.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig6 = mpld3.fig_to_html(fig6)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_Optimal_Probabilities_Banks_Prob_not_changed.pdf', format='pdf')
   pyplot.close(fig6)

   fig7, bx = pyplot.subplots()
   bx.plot(nr_per, flipud(v_state_opt_min), label='Value', color='red')
   bx.set_xlabel('Stage of the Game')
   bx.set_ylabel('Value')
   bx.set_title('State value if it choses whether to save the bank')
   bx.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig7 = mpld3.fig_to_html(fig7)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_State_Value_if_choses_whether_to_save_the_Bank.pdf', format='pdf')
   pyplot.close(fig7)

   return html_text_fig6, html_text_fig7

def joint_problem(r_max, r_min, bailout_cost, deadweight_cost, discount_rate, nr_of_periods):
   # Joint problem: after each stage Bank promises pi <= pi_state, but recalculates it's value

   opt_pi_bank_joint = [0] * nr_of_periods
   opt_pi_state_joint = [0] * nr_of_periods
   v_bank_joint = [0] * nr_of_periods
   v_state_joint = [0] * nr_of_periods

   # n=0
   f_opt_bank_0 = lambda x: - x * (r_min + (r_max - r_min) * (1 - x)) / (1 - discount_rate * x)
   f_state_0 = lambda x: math.pow(- deadweight_cost + bailout_cost + discount_rate * deadweight_cost * (1 - x) /
                                  (1 - discount_rate * x), 2)

   opt_pi_bank_joint[0] = optimize.fmin(f_opt_bank_0, 0.5) # optimization using: Simplex method: the Nelder-Mead
   opt_pi_state_joint[0] = optimize.root(f_state_0, 0.5, method='lm').x

   # Bank "promises" the threshold pi in order to be saved at period n=1 even it it's optimal pi is lower:
   if opt_pi_bank_joint[0] < opt_pi_state_joint[0]:
      opt_pi_bank_joint[0] = opt_pi_state_joint[0]

   v_bank_joint[0] = - f_opt_bank_0(opt_pi_bank_joint[0])
   v_state_joint[0] = deadweight_cost * (1 - opt_pi_bank_joint[0]) / (1 - discount_rate * opt_pi_bank_joint[0])

   # Previous periods:
   f_bank = lambda x,y: -((x * (r_min + (r_max - r_min) * (1 - x)) + (1 - x) * (bailout_cost + discount_rate * y)) /
                          (1 - discount_rate * x))
   f_state = lambda x,y: math.pow(- deadweight_cost + bailout_cost + discount_rate * (bailout_cost + discount_rate * y) * \
                                                            (1 - x) / (1 - discount_rate * x), 2)

   # Options = optimset('TolFun', 1e-15):
   for i in range(1, nr_of_periods):
      f_opt_bank = lambda x: f_bank(x, v_bank_joint[i-1])
      f_state_opt = lambda x: f_state(x, v_state_joint[i-1])

      opt_pi_bank_joint[i] = optimize.fmin(f_opt_bank, 0.7)
      opt_pi_state_joint[i] = optimize.root(f_state_opt, 0.5, method='lm').x

      # BANKS's PROBABILITES CHANGED IF THEY ALE LOWER THAN PI_STATE AND THEN THEY ARE TAKEN FOR V's:
      if opt_pi_bank_joint[i] < opt_pi_state_joint[i]:
         opt_pi_bank_joint[i] = opt_pi_state_joint[i]

      v_bank_joint[i] = -f_opt_bank(opt_pi_bank_joint[i])
      v_state_joint[i] = (bailout_cost + discount_rate * v_state_joint[i-1]) * (1 - opt_pi_bank_joint[i]) /\
                         (1 - discount_rate * opt_pi_bank_joint[i])

   nr_per = [0] * nr_of_periods
   for i in range(0, nr_of_periods):
      nr_per[i] = i

   # Create plots and pdf file. Save pdf file into graphics folder
   fig8, ax = pyplot.subplots()
   ax.plot(nr_per, flipud(opt_pi_bank_joint), label='Bank', color='red', linestyle=':')
   ax.plot(nr_per, flipud(opt_pi_state_joint), label='State', color='blue', linestyle='--')
   ax.set_xlabel('Stage of the Game')
   ax.set_ylabel('Probability')
   ax.set_title('Optimal probabilities in joint game')
   ax.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig8 = mpld3.fig_to_html(fig8)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_Optimal_Probabilities_in_Joint_Game.pdf', format='pdf')
   pyplot.close(fig8)

   fig9, bx = pyplot.subplots()
   bx.plot(nr_per, flipud(v_state_joint), color='red')
   bx.set_title('State value in the joint game')
   bx.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig9 = mpld3.fig_to_html(fig9)
   pyplot.savefig('tbtf/modelfinitebounded/graphics/FB_State_Value_in_the_Joint_Game.pdf', format='pdf')
   pyplot.close(fig9)

   return html_text_fig8, html_text_fig9

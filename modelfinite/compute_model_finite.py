""" 
Function(s): model_finite, banks_problem, analytical_results, states_problem, states_problem_change_banks_pi,
             states_problem_min_banks_prob_not_changed, joint_problem

Description:
   Solves the model in finite setting. In this file solutions for probabilities are not restricted to [0,1],
   therefore they are often implausible.

   This was the very first file to implement the finite setting. Here the bank's problem and the state's problem
   are solved separately, then switching for the bank is implemented, then recalculating bank's value is implemented.

Reference:
   The code below has been taken form the Department of Banking and Finance .It has been rewritten from Matlab.
   Variable names have been changed for a better understanding.

Additional: PDF and HTML (mpld3) output has been included. For a better understanding it was devided into multiple
   functions

Author(s): Igor Bozic, Department of Banking and Finance

"""

import numpy as np
from numpy.lib.twodim_base import flipud
from scipy import optimize
import matplotlib.pyplot as pyplot, mpld3
import math


def model_finite(r_max, r_min, bailout_cost, deadweight_cost, accuracy, discount_rate, r, nr_of_periods):

   nr_of_periods = int(round(nr_of_periods)) # needs to be an intger number

   # Define function R for any probability x: calculates the project return R
   # for a given probability of success x
   R = lambda x: r_min + (r_max - r_min) * (1 - x)

   html_text_fig1, f_opt_bank_0 = banks_problem(r_max, r_min, accuracy, discount_rate)
   html_text_fig2, opt_pi_bank, pi_bank_analytical = analytical_results(r_max, r_min, bailout_cost, discount_rate,
                                                                        nr_of_periods, R, f_opt_bank_0)
   html_text_fig3, html_text_fig4, html_text_fig5, opt_pi_bank = states_problem(bailout_cost, deadweight_cost,
                                                                                discount_rate, nr_of_periods,
                                                                                opt_pi_bank, pi_bank_analytical)

   html_text_fig6, html_text_fig7 = states_problem_change_banks_pi(bailout_cost, deadweight_cost, discount_rate,
                                                   nr_of_periods, opt_pi_bank)

   html_text_fig8, html_text_fig9 = states_problem_min_banks_prob_not_changed(bailout_cost, deadweight_cost, discount_rate,
                                                              nr_of_periods, opt_pi_bank)

   html_text_fig10, html_text_fig11 = joint_problem(r_max, r_min, bailout_cost, deadweight_cost, discount_rate,
                                                    nr_of_periods)

   return html_text_fig1, html_text_fig2, html_text_fig3, html_text_fig4, html_text_fig5, html_text_fig6,\
          html_text_fig7, html_text_fig8, html_text_fig9, html_text_fig10, html_text_fig11

def banks_problem(r_max, r_min, accuracy, discount_rate):
   # Bank's problem:

   # NOTE: Bank's problem is solved here independently from state's problem.
   # Bailout assumed everywhere.

   # bank's problem at the last stage: max(pi) pi*R(pi)/(1-delta*pi)

   f_opt_bank_0 = lambda x: -x * (r_min + (r_max - r_min) * (1 - x)) / (1 - discount_rate * x)

   # check the function graphically:
   temp1 = np.arange(0, 1, accuracy)
   temp = -f_opt_bank_0(temp1)
   # Create plots and pdf file. Save pdf file into graphics folder
   fig1, ax = pyplot.subplots()
   ax.plot(temp1, temp)
   ax.set_xlabel('Probability')
   ax.set_ylabel('Value for Bank')
   ax.set_title('Value for the bank in Last Period, no bailout scenario')
   ax.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig1 = mpld3.fig_to_html(fig1)
   pyplot.savefig('tbtf/modelfinite/graphics/F_Value_for_the_Bank_Last_Period_No_Bailout.pdf', format='pdf')
   pyplot.close(fig1)

   return html_text_fig1, f_opt_bank_0

def analytical_results(r_max, r_min, bailout_cost, discount_rate, nr_of_periods, R, f_opt_bank_0):
   # Analytical results:

   # optimal value for period 0
   opt_pi_bank = [0] * nr_of_periods
   v_bank = [0] * nr_of_periods

   #opt_pi_bank[0] = optimize.fmin(f_opt_bank_0, 0.5) # optimization using: Simplex method: the Nelder-Mead
   opt_pi_bank[0] = optimize.minimize(f_opt_bank_0, 0.5, method='L-BFGS-B', bounds=[(0.0,1.0)])['x']
   v_bank[0] = -f_opt_bank_0(opt_pi_bank[0])

   # bank problem in the rest of the periods, eq.(28)
   f_bank = lambda x,y: -((x * (r_min + (r_max - r_min) * (1 - x)) + (1 - x) * (bailout_cost + discount_rate * y)) /
                          (1 - discount_rate * x))
   for k in range(1, nr_of_periods):
      f_opt_bank_0 = lambda x: f_bank(x, v_bank[k - 1])
      #opt_pi_bank[k] = optimize.fmin(f_opt_bank_0, 0.7)
      opt_pi_bank[k] = optimize.minimize(f_opt_bank_0, 0.7, method='L-BFGS-B', bounds=[(0.0,1.0)])['x']
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

   # We want to solve for Rmax that would give the pi_bank same as pi_state in
   # the last period:
   temp_fun = lambda r_max: pi_bank_analytical[0] - (1 - math.sqrt(1-r_max * discount_rate / (r_max - r_min))) / discount_rate
   res_sol_temp_fun = optimize.fsolve(temp_fun, 5)

   # compare optimization results and analytical results:
   nr_per = [0] * nr_of_periods
   for i in range(0, nr_of_periods):
      nr_per[i] = i

   # Create plots and pdf file. Save pdf file into graphics folder
   fig2, bx = pyplot.subplots()
   bx.plot(nr_per, flipud(opt_pi_bank), label='Optimization Results', color='red',  linestyle=':')
   bx.plot(nr_per, flipud(pi_bank_analytical), label='Analytical Results', color='blue', linestyle='--')
   bx.set_xlabel('Number of Periods')
   bx.set_ylabel('Probabilities')
   bx.set_title('Optimal probabilities for the bank')
   bx.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig2 = mpld3.fig_to_html(fig2)
   pyplot.savefig('tbtf/modelfinite/graphics/F_Optimal_Probabilities_for_the_Bank.pdf', format='pdf')
   pyplot.close(fig2)

   return html_text_fig2, opt_pi_bank, pi_bank_analytical

def states_problem(bailout_cost, deadweight_cost, discount_rate, nr_of_periods, opt_pi_bank, pi_bank_analytical):
   # State's Problem

   # solve the equations from (20) on:
   v_state_opt = [0] * nr_of_periods
   pi_state_thresh = [0] * nr_of_periods

   # Period n=0
   f_state_0 = lambda x: - deadweight_cost + bailout_cost + discount_rate * deadweight_cost * (1 - x) / (1 - discount_rate * x)
   pi_state_thresh[0] = optimize.fsolve(f_state_0, 0.5)
   v_state_opt[0] = deadweight_cost * (1 - opt_pi_bank[0]) / (1 - discount_rate * opt_pi_bank[0])

   # analytical check:
   pi_state_analytical = [0] * nr_of_periods
   pi_state_analytical[0] = (deadweight_cost - (deadweight_cost - bailout_cost) / discount_rate) / bailout_cost

   # previous periods:
   f_state = lambda x,y: - deadweight_cost + bailout_cost + discount_rate * (bailout_cost + discount_rate * y) * (1 - x) /\
                                                            (1 - discount_rate * x)

   # solve for the rest of the periods:
   for i in range(1, nr_of_periods):
      f_state_opt = lambda x: f_state(x, v_state_opt[i - 1])
      pi_state_thresh[i] = optimize.fsolve(f_state_opt, 0.5)

      #BANK's PROBABILITIE'sS ARE TAKEN FOR v_state
      v_state_opt[i] = (bailout_cost + discount_rate * v_state_opt[i - 1]) * (1 - opt_pi_bank[i]) / (1 - discount_rate * opt_pi_bank[i])

      pi_state_analytical[i] = (bailout_cost + (discount_rate * v_state_opt[i-1]) - (deadweight_cost - bailout_cost) /
                                discount_rate) / (bailout_cost + (discount_rate * v_state_opt[i-1]) - (deadweight_cost - bailout_cost))

   nr_per = [0] * nr_of_periods
   for i in range(0, nr_of_periods):
      nr_per[i] = i

   # Create plots and pdf file. Save pdf file into graphics folder
   fig3, cx = pyplot.subplots()
   cx.plot(nr_per, flipud(opt_pi_bank), label='Bank', color='red',  linestyle=':')
   cx.plot(nr_per, flipud(pi_state_thresh), label='State', color='blue', linestyle='--')
   cx.set_xlabel('Stage of the Game')
   cx.set_ylabel('Probability')
   cx.set_title('Machine Results')
   cx.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig3 = mpld3.fig_to_html(fig3)
   pyplot.savefig('tbtf/modelfinite/graphics/F_Machine_Results.pdf', format='pdf')
   pyplot.close(fig3)

   fig4, dx = pyplot.subplots()
   dx.plot(nr_per, flipud(pi_bank_analytical), label='Bank', color='red',  linestyle=':')
   dx.plot(nr_per, flipud(pi_state_analytical), label='State', color='blue', linestyle='--')
   dx.set_xlabel('Stage of the Game')
   dx.set_ylabel('Probability')
   dx.set_title('Analytical Results')
   dx.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig4 = mpld3.fig_to_html(fig4)
   pyplot.savefig('tbtf/modelfinite/graphics/F_Analytical_Results.pdf', format='pdf')
   pyplot.close(fig4)

   fig5, ex = pyplot.subplots()
   ex.plot(nr_per, flipud(v_state_opt), label='State_Value_Function')
   ex.set_title('State Value Function')
   html_text_fig5 = mpld3.fig_to_html(fig5)
   pyplot.savefig('tbtf/modelfinite/graphics/F_State_Value_Function.pdf', format='pdf')
   pyplot.close(fig5)

   return html_text_fig3, html_text_fig4, html_text_fig5, opt_pi_bank

def states_problem_change_banks_pi(bailout_cost, deadweight_cost, discount_rate, nr_of_periods, opt_pi_bank):
   # State's problem: Change Bank's pi if it's less then State's pi

   # solve the equation from (20) on:
   v_state_opt_switch = [0] * nr_of_periods
   pi_state_tresh_switch = [0] * nr_of_periods
   opt_pi_bank_switch = opt_pi_bank

   # n=0
   f_state_0 = lambda x: - deadweight_cost + bailout_cost + discount_rate * deadweight_cost * (1 - x) / (1 - discount_rate * x)
   pi_state_tresh_switch[0] = optimize.fsolve(f_state_0, 0.5)

   # Bank's "promises" the threshold pi in order to be saved at period n=1 even
   # if it's optimal pi is lower:
   if opt_pi_bank_switch[0] < pi_state_tresh_switch[0]:
      opt_pi_bank_switch[0] = pi_state_tresh_switch[0]

   v_state_opt_switch[0] = deadweight_cost * (1 - opt_pi_bank_switch[0]) / (1 - discount_rate * opt_pi_bank_switch[0])

   # previous periods
   f_state = lambda x,y: - deadweight_cost + bailout_cost + discount_rate * (bailout_cost + discount_rate * y) * \
                                                            (1 - x) / (1 - discount_rate * x)

   # solve for all the previous periods:
   for i in range(1, nr_of_periods):
      f_state_opt = lambda x: f_state(x, v_state_opt_switch[i-1])
      pi_state_tresh_switch[i] = optimize.fsolve(f_state_opt, 0.5)

      # BANK's PROBABILITIES CHANGED IF THEY ALE LOWER THAN PI_STATE AND THEN THEY ARE TAKEN FOR V's:
      if opt_pi_bank_switch[i] < pi_state_tresh_switch[i]:
         opt_pi_bank_switch[i] = pi_state_tresh_switch[i]

      v_state_opt_switch[i] = (bailout_cost + discount_rate * v_state_opt_switch[i-1]) * (1 - opt_pi_bank_switch[i])\
                              / (1 - discount_rate * opt_pi_bank_switch[i])

   nr_per = [0] * nr_of_periods
   for i in range(0, nr_of_periods):
      nr_per[i] = i

   # Create plots and pdf file. Save pdf file into graphics folder
   fig6, fx = pyplot.subplots()
   fx.plot(nr_per, flipud(opt_pi_bank), label='Bank', color='red')
   fx.plot(nr_per, flipud(pi_state_tresh_switch), label='State', color='blue', linestyle=':')
   fx.plot(nr_per, flipud(opt_pi_bank_switch), label='Bank Switched', color='green', linestyle='--')
   fx.set_xlabel('Stage of the Game')
   fx.set_ylabel('Probability')
   fx.set_title('Optimal Probabilities')
   fx.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig6 = mpld3.fig_to_html(fig6)
   pyplot.savefig('tbtf/modelfinite/graphics/F_Optimal_Probabilities.pdf', format='pdf')
   pyplot.close(fig6)

   fig7, gx = pyplot.subplots()
   gx.plot(nr_per, flipud(v_state_opt_switch), label='New value (Bank switches)', color='red', linestyle=':')
   gx.plot(nr_per, flipud(v_state_opt_switch), label='Old value', color='blue', linestyle='--')
   gx.set_title('State value if Bank switches to state pi')
   gx.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig7 = mpld3.fig_to_html(fig7)
   pyplot.savefig('tbtf/modelfinite/graphics/F_State_Value_if_Bank_Switches_to_State_pi.pdf', format='pdf')
   pyplot.close(fig7)

   return html_text_fig6, html_text_fig7

def states_problem_min_banks_prob_not_changed(bailout_cost, deadweight_cost, discount_rate, nr_of_periods, opt_pi_bank):
   # State's problem: min if Bank's probabilitie is not changed

   # Solve the equation from (20) on:
   v_state_opt_min = [0] * nr_of_periods
   pi_state_tresh_min = [0] * nr_of_periods
   opt_pi_bank_min = opt_pi_bank

   # n=0, pi=0 does not change
   f_state_0 = lambda x: - deadweight_cost + bailout_cost + discount_rate * deadweight_cost * (1 - x) / (1 - discount_rate * x)
   pi_state_tresh_min[0] = optimize.root(f_state_0, 0.5, method='lm').x
   v_state_opt_min[0] = deadweight_cost * (1 - opt_pi_bank_min[0]) / (1 - discount_rate * opt_pi_bank_min[0])

   # previous periods, n > 0:
   f_state = lambda x,y: - deadweight_cost + bailout_cost + discount_rate * (bailout_cost + discount_rate * y) * \
                                                            (1 - x) / (1 - discount_rate * x)

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
   fig8, hx = pyplot.subplots()
   hx.plot(nr_per, flipud(opt_pi_bank_min), label='Bank', color='red', linestyle=':')
   hx.plot(nr_per, flipud(pi_state_tresh_min), label='State', color='blue', linestyle='--')
   hx.set_xlabel('Stage of the Game')
   hx.set_ylabel('Probability')
   hx.set_title('Optimal Probabilities, State Chooses min(c,b+dv)')
   hx.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig8 = mpld3.fig_to_html(fig8)
   pyplot.savefig('tbtf/modelfinite/graphics/F_Optimal_Probabilities_State_Chooses_min(c_b_dv).pdf', format='pdf')
   pyplot.close(fig8)

   fig9, ix = pyplot.subplots()
   ix.plot(nr_per, flipud(v_state_opt_min), label='Value', color='red')
   ix.set_xlabel('Stage of the Game')
   ix.set_ylabel('Value')
   ix.set_title('State value if it choses whether to save the bank')
   ix.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig9 = mpld3.fig_to_html(fig9)
   pyplot.savefig('tbtf/modelfinite/graphics/F_State_Value_if_it_choses_whether_to_save_the_Bank.pdf', format='pdf')
   pyplot.close(fig9)

   return html_text_fig8, html_text_fig9

def joint_problem(r_max, r_min, bailout_cost, deadweight_cost, discount_rate, nr_of_periods):
   # Joint problem: after each stage Bank promises pi <= pi_state, but recalculates it's value

   opt_pi_bank_joint = [0] * nr_of_periods
   opt_pi_state_joint = [0] * nr_of_periods
   v_bank_joint = [0] * nr_of_periods
   v_state_joint = [0] * nr_of_periods

   # n=0
   f_opt_bank_0 = lambda x: - x * (r_min + (r_max - r_min) * (1 - x)) / (1 - discount_rate * x)
   f_state_0 = lambda x: - deadweight_cost + bailout_cost + discount_rate * deadweight_cost * (1 - x) / (1 - discount_rate * x)

   #opt_pi_bank_joint[0] = optimize.fmin(f_opt_bank_0, 0.5) # optimization using: Simplex method: the Nelder-Mead
   opt_pi_bank_joint[0] = optimize.minimize(f_opt_bank_0, 0.5, method='L-BFGS-B', bounds=[(0.0,1.0)])['x']
   opt_pi_state_joint[0] = optimize.root(f_state_0, 0.5, method='lm').x

   # Bank "promises" the threshold pi in order to be saved at period n=1 even it it's optimal pi is lower:
   if opt_pi_bank_joint[0] < opt_pi_state_joint[0]:
      opt_pi_bank_joint[0] = opt_pi_state_joint[0]

   v_bank_joint[0] = - f_opt_bank_0(opt_pi_bank_joint[0])
   v_state_joint[0] = deadweight_cost * (1 - opt_pi_bank_joint[0]) / (1 - discount_rate * opt_pi_bank_joint[0])

   # Previous periods:
   f_bank = lambda x,y: -((x * (r_min + (r_max - r_min) * (1 - x)) + (1 - x) * (bailout_cost + discount_rate * y)) /
                          (1 - discount_rate * x))
   f_state = lambda x,y: - deadweight_cost + bailout_cost + discount_rate * (bailout_cost + discount_rate * y) * \
                                                            (1 - x) / (1 - discount_rate * x)

   # Options = optimset('TolFun', 1e-15):
   for i in range(1, nr_of_periods):
      f_opt_bank = lambda x: f_bank(x, v_bank_joint[i-1])
      f_state_opt = lambda x: f_state(x, v_state_joint[i-1])

      #opt_pi_bank_joint[i] = optimize.fmin(f_opt_bank, 0.7)
      opt_pi_bank_joint[i] = optimize.minimize(f_opt_bank, 0.7, method='L-BFGS-B', bounds=[(0.0,1.0)])['x']
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
   fig10, jx = pyplot.subplots()
   jx.plot(nr_per, flipud(opt_pi_bank_joint), label='Bank', color='red', linestyle=':')
   jx.plot(nr_per, flipud(opt_pi_state_joint), label='State', color='blue', linestyle='--')
   jx.set_xlabel('Stage of the Game')
   jx.set_ylabel('Probability')
   jx.set_title('Optimal probabilities in joint game')
   jx.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig10 = mpld3.fig_to_html(fig10)
   pyplot.savefig('tbtf/modelfinite/graphics/F_Optimal_Probabilities_in_Joint_Game.pdf', format='pdf')
   pyplot.close(fig10)

   fig11, kx = pyplot.subplots()
   kx.plot(nr_per, flipud(v_state_joint), color='red')
   kx.set_title('State value in the joint game')
   kx.legend(loc='lower left', frameon=True, fontsize = 'medium', title='', fancybox=True)
   html_text_fig11 = mpld3.fig_to_html(fig11)
   pyplot.savefig('tbtf/modelfinite/graphics/F_State_Value_in_Joint_Game.pdf', format='pdf')
   pyplot.close(fig11)

   return html_text_fig10, html_text_fig11
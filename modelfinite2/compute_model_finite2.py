""" 
Function(s): calc_model_finite2_opt_values, plot_model_finte2_opt_values

Description:
   Solves the model in finite setting. In this file solutions for probabilities are not restricted to [0,1],
   therefore they are often implausible.

   This was the very first file to implement the finite setting. Here the bank's problem and the state's problem
   are solved separately, then switching for the bank is implemented, then recalculating bank's value is implemented.

Reference:
   The function "calc_model_finite2_opt_values" has been taken form the Department of Banking and Finance.
   It has been rewritten from Matlab. Variable names have been changed for a better understanding.

Additional: PDF and HTML (mpld3) output has been included. For a better understanding it was devided into multiple
   functions

Author(s): Igor Bozic, Department of Banking and Finance

"""

import numpy as np
from numpy.lib.twodim_base import flipud
from scipy import optimize
import matplotlib.pyplot as pyplot, mpld3
import math

def calc_model_finite2_opt_values(r_max, r_min, bailout_cost, discount_rate, delta, nper):
   nper = int(round(nper))
   # Define function R for any probability x: calculates the project return R
   # for a given probability of success x
   R = lambda x: r_min + (r_max - r_min)*(1-x)
   # options = numpy.optimset('TolFun',1e-9,'TolCon',1e-8); not needed in python (in matlab)

   pi_opt_bank = [0] * nper     # optimal probabilities for bank
   v_opt_bank = [0] * nper      # value for the bank corresponding to pi_opt_bank
   pi_prime_bank = [0] * nper   # critical values pi_prime
   v_prime_bank = [0] * nper    # critical values V_prime
   pi_real_bank = [0] * nper    # real probabilities that the bank will choose
   v_real_bank = [0] * nper     # real values for bank
   pi_bar_state = [0] * nper    # threshold probabilities for the state
   v_state = [0] * nper         # value for the state
   thetas = [0] * nper          # indicator of the bailout

   pi_bar_numer = [0] * nper    # numerator for pi_bar formula
   pi_bar_denom = [0] * nper    # denominator for pi_bar formula

   # ************************************
   # 1. Stage 0 (n=1, 1 baiout left)
   # ************************************

   # State's problem at the last stage: chooses pi_bar
   f_state_0 = lambda x: math.pow(-discount_rate + bailout_cost + delta * discount_rate * (1-x) / (1 - delta * x),2)
   pi_bar_state[0] = optimize.minimize(f_state_0, 0.5, method='L-BFGS-B', bounds=[(0.0,1.0)])['x'] # using method with boundaries

   # calculates optimal value pi_optimal
   f_opt_bank_0 = lambda x: -x * R(x) / (1-delta*x)   # minus for minimization; x=pi; from eq.(27)
   pi_opt_bank[0] = optimize.fmin(f_opt_bank_0, 0.5)  # optimal pi_0
   v_opt_bank[0] = -f_opt_bank_0(pi_opt_bank[0])      # opitmal value

   # calculates critical value pi_prime
   # pi_prime_bank[0] = pi_opt_bank[0]    # at the last stage pi_optimal = pi_prime
   pi_prime_bank[0] = 1                   # bank commits to any pi in order to be saved
   v_prime_bank[0] = -f_opt_bank_0(pi_prime_bank[0])

   # chooses real probability pi_real
   if(pi_opt_bank[0] < pi_bar_state[0]):        # if bank's optimal pi is too small

     if(pi_bar_state[0] <= pi_prime_bank[0]):   # but if the bank can still make profit with higher pi
         pi_real_bank[0] =  pi_bar_state[0]     # bank switches to the required level of pi - pi_bar

     else:
         pi_real_bank[0] =  pi_opt_bank[0]      # otherwise bank chooses pi_opt_0 and gets v_0

   else:
       pi_real_bank[0] =  pi_opt_bank[0]        # if optimal pi exceeds the threshold pi_bar, bank sticks to it

   # given the true probability chosen by the bank, define Bank's and State's real values:
   v_real_bank[0] = -f_opt_bank_0(pi_real_bank[0]);
   v_state[0] = discount_rate * (1-pi_real_bank[0]) / (1-delta*pi_real_bank[0]);

   if(pi_real_bank[0] >= pi_bar_state[0]):
      thetas[0] = 1                             # baiout if the bank is safe enough

   if delta == 0.0:
      pi_bar_numer[0] = discount_rate
   else:
      pi_bar_numer[0] = discount_rate - (discount_rate-bailout_cost) / delta

   pi_bar_denom[0] = bailout_cost

   # **************************************
   #  2. Stages 1,...,n (n+1 bailouts left)
   # **************************************

   # state's problem in the rest of the periods:
   f_state = lambda x,y: math.pow((- discount_rate + bailout_cost + delta * (bailout_cost+delta*y) * (1-x) / (1-delta*x)),2)

   # bank's problem in the rest of the periods:
   f_bank = lambda x,y: -((x*(r_min + (r_max-r_min)*(1-x))+(1-x)*(bailout_cost+delta*y))/(1-delta*x))                     # x=pi
   f_crit = lambda x,y,v0: math.pow((v0-((x*(r_min + (r_max-r_min)*(1-x))+(1-x)*(bailout_cost+delta*y))/(1-delta*x))),2)  # x=pi, y=Vlag1, z=V0

   for k in range(1, nper):
      # if at the previous stage the bank wasn't saved, jump to pi_0 (n=1) case:
      if (thetas[k-1] == 0):
         pi_bar_state[k] = pi_bar_state[0]
         pi_opt_bank[k] = pi_opt_bank[0]
         pi_prime_bank[k] = pi_prime_bank[0]
         pi_real_bank[k] = pi_opt_bank[0]
         v_opt_bank[k] = v_opt_bank[0]
         v_prime_bank[k] = v_prime_bank[0]
         v_real_bank[k] = -f_opt_bank_0(pi_real_bank[k])
         v_state[k] =  discount_rate * (1 - pi_real_bank[k]) / (1 - delta * pi_real_bank[k])

      else: # otherwise
         # a) State's problem:

         # calculates threshold probabilities pi_bar:
         f_state_opt =  lambda x: f_state(x,v_state[k-1])
         # Minimize a function using method L-BFGS-B with boundaries
         pi_bar_state[k] = optimize.minimize(f_state_opt, 0.5, method='L-BFGS-B', bounds=[(0.0,1.0)])['x']

         # b) Bank's problem:

         # calculates optimal probabilities and values:
         f_opt_bank = lambda x: f_bank(x, v_opt_bank[k-1])
         # Minimize a function using method L-BFGS-B with boundaries
         pi_opt_bank[k] = optimize.minimize(f_opt_bank, 0.7, method='L-BFGS-B', bounds=[(0.0,1.0)])['x']
         v_opt_bank[k] = -f_opt_bank(pi_opt_bank[k])

         # calculates critical values:
         f_crit_bank = lambda x: f_crit(x, v_opt_bank[k-1], v_opt_bank[0])
         # Minimize a function using method L-BFGS-B with boundaries
         pi_prime_bank[k] = optimize.minimize(f_crit_bank, 0.8, method='L-BFGS-B', bounds=[(0.0,1.0)])['x']
         # avoid ineficient corner solution pi = 0, because pi = 1 is optimal in
         # this case (see the plot of f_crit_bank)
         if ((pi_prime_bank[k] < 0.5) and (f_crit_bank(0) >= f_crit_bank(1))):
            pi_prime_bank[k] = 1

         v_prime_bank[k] = -f_opt_bank(pi_prime_bank[k])

         # chooses real probabilities pi_real:
         if (pi_opt_bank[k] < pi_bar_state[k]):          # if bank's optimal pi is too small

            if (pi_bar_state[k] <= pi_prime_bank[k]):    # but if the bank can still make profit
               pi_real_bank[k] =  pi_bar_state[k]        # bank switches to the required level of pi - pi_bar
               v_real_bank[k] = -f_opt_bank(pi_real_bank[k])
               v_state[k] = (bailout_cost + delta * v_state[k-1]) * (1 - pi_real_bank[k]) / (1 - delta * pi_real_bank[k])

            else:
               pi_real_bank[k] =  pi_opt_bank[1]         # otherwise bank chooses pi_prime and gets v_0
               v_real_bank[k] = -f_opt_bank_0(pi_real_bank[k])
               v_state[k] =  discount_rate * (1 - pi_real_bank[k]) / (1 - delta * pi_real_bank[k])
               # and no bailout_cost - thetas(k) stays zero

         else:
            pi_real_bank[k] =  pi_opt_bank[k]            # if optimal pi exceeds the threshold pi_bar, bank sticks to it
            v_real_bank[k] = -f_opt_bank(pi_real_bank[k])
            v_state[k] = (bailout_cost + delta*v_state[k-1]) * (1 - pi_real_bank[k]) / (1 - delta * pi_real_bank[k])

      if (pi_real_bank[k] >= pi_bar_state[k]):
         thetas[k] = 1                                   # baiout if the bank is safe enough

      pi_bar_numer[k] = (bailout_cost + delta*v_state[k-1]) - (discount_rate-bailout_cost) / delta
      pi_bar_denom[k] = (bailout_cost + delta*v_state[k-1]) - (discount_rate-bailout_cost)

   v_state_ret = [0] * nper
   for i in range(0, nper):
      v_state_ret[i] = v_state[i] * (1 - delta * pi_real_bank[i]) / (1 - pi_real_bank[i])
      if (v_state[i] == 0):
         v_state_ret[i] = 0

   thetas = np.fliplr([thetas])[0]
   pi_real_bank = np.fliplr([pi_real_bank])[0]
   v_real_bank = np.fliplr([v_real_bank])[0]
   pi_opt_bank = np.fliplr([pi_opt_bank])[0]
   v_opt_bank = np.fliplr([v_opt_bank])[0]
   pi_bar_state = np.fliplr([pi_bar_state])[0]
   v_state = np.fliplr([v_state])[0]
   pi_prime_bank = np.fliplr([pi_prime_bank])[0]
   v_prime_bank = np.fliplr([v_prime_bank])[0]
   v_state_ret = np.fliplr([v_state_ret])[0]
   pi_bar_numer = np.fliplr([pi_bar_numer])[0]
   pi_bar_denom = np.fliplr([pi_bar_denom])[0]

   return thetas, pi_real_bank, v_real_bank, pi_opt_bank, v_opt_bank, pi_bar_state, v_state, pi_prime_bank,\
          v_prime_bank, v_state_ret, pi_bar_numer, pi_bar_denom

def plot_model_finte2_opt_values(r_max, r_min, bailout_cost, discount_rate, delta, nper):

   thetas, pi_real_bank, v_real_bank, pi_opt_bank, v_opt_bank, pi_bar_state, v_state, pi_prime_bank,\
          v_prime_bank, v_state_ret, pi_bar_numer, pi_bar_denom = calc_model_finite2_opt_values(r_max, r_min, bailout_cost, discount_rate, delta, nper)

   # Create plots and pdf file. Save pdf file into graphics folder
   fig1, ax = pyplot.subplots()
   ax.plot(v_real_bank,label='V Real State', color='red',  linestyle='-')
   ax.plot(v_opt_bank,label='V Opt Bank', color='blue',  linestyle='-')
   ax.plot(v_state,label='V State', color='green',  linestyle='-')
   ax.plot(v_prime_bank,label='V Prime Bank', color='brown',  linestyle='-')
   ax.plot(v_state_ret,label='V State Ret', color='black',  linestyle='-')
   ax.set_xlabel('Periods')
   ax.set_ylabel('Values')
   ax.set_title('Values')
   ax.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig1 = mpld3.fig_to_html(fig1)
   pyplot.savefig('tbtf/modelfinite2/graphics/Profit_Loss_Opt.pdf', format='pdf')
   pyplot.close(fig1)

   fig2, bx = pyplot.subplots()
   bx.plot(pi_real_bank,label='PI Real Bank', color='red',  linestyle='-')
   bx.plot(pi_opt_bank,label='PI Opt Bank', color='blue',  linestyle='-')
   bx.plot(pi_bar_state,label='PI Bar State', color='green',  linestyle='-')
   bx.plot(pi_prime_bank,label='PI Prime Bank', color='black',  linestyle='-')
   bx.plot(pi_bar_numer,label='PI Bar Numer', color='pink',  linestyle='-')
   bx.plot(pi_bar_denom,label='PI Bar Denom', color='brown',  linestyle='-')
   bx.set_xlabel('Periods')
   bx.set_ylabel('Probabilitie')
   bx.set_title('PI')
   bx.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig2 = mpld3.fig_to_html(fig2)
   pyplot.savefig('tbtf/modelfinite2/graphics/PI_Opt.pdf', format='pdf')
   pyplot.close(fig2)

   fig3, cx = pyplot.subplots()
   cx.plot(thetas)
   cx.set_xlabel('Periods')
   cx.set_ylabel('Thetas')
   cx.set_title('Thetas')
   cx.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)
   html_text_fig3 = mpld3.fig_to_html(fig3)
   pyplot.savefig('tbtf/modelfinite2/graphics/Thetas.pdf', format='pdf')
   pyplot.close(fig3)

   return html_text_fig1, html_text_fig2, html_text_fig3
"""

Function(s): model_infinite

Description:
   In infinite setting the optimal solution is found by grid search. That is, for each value of probability in a
   grid the corresponding Expected return (EU) is calculated. The optimal probability is the value that
   corresponds to the maximum EU.

Reference:
   The code below has been taken form the Department of Banking and Finance. It has been rewritten from Matlab.
   Variable names have been changed for a better understanding.

Additional: PDF and HTML (mpld3) output has been included. For a better understanding it was devided into multiple
   functions

Author(s): Igor Bozic, Department of Banking and Finance

"""

import numpy as np
import math
import matplotlib.pyplot as pyplot, mpld3
import matplotlib.patches as patches


def model_infinite(r_max, r_min, bailout_cost, deadweight_cost, accuracy, discount_rate, r):

   # 1. Grid Search

   # caluculations:
   pi = np.arange(0, 1, accuracy)               # create a grid (string of values) of probabiliites
   r_step = (r_max - r_min) * accuracy          # step in vector of returns
   r_vec = r_min + (r_max - r_min) * (1 - pi)   # vector of returns

   # expected returns:
   eu = (r_vec * pi) / (1 - discount_rate * pi)   # bank's expected utility wihtout bailout
   eu_b = (r_vec * pi + bailout_cost * (1 - pi)) / (1 - discount_rate) # bank's expected utility with bailout
   eu_c = (r_vec * pi - deadweight_cost * (1 - pi)) / (1 - discount_rate * pi) # social utility with bailout

   # optimal values of expected returns:
   opt_eu = max(eu)
   index_max_eu = eu.argmax()
   opt_eu_b = max(eu_b)
   index_max_eu_b = eu_b.argmax()
   opt_eu_c = max(eu_c)
   index_max_eu_c = eu_c.argmax()

   # corresponding optimal probabilities:
   opt_prob_eu = pi[index_max_eu]
   opt_prob_eu_b = pi[index_max_eu_b]
   opt_prob_eu_c = pi[index_max_eu_c]

   # optimal EUs given optimal probability with collateral:
   opt_col_eu = eu[index_max_eu_c]
   opt_col_eu_b = eu_b[index_max_eu_c]

   # differences between optimal EUs and optimal EU under collateral:
   eu_diff = opt_eu - opt_col_eu
   eu_diff_rel = eu_diff / opt_col_eu        # diff relative to EU under collateral
   eu_b_diff = opt_eu_b - opt_col_eu_b
   eu_b_diff_rel = eu_b_diff / opt_col_eu_b  # diff relative to EU under collateral

   # need to round for grapics showing max numbers
   if int(deadweight_cost)%2 == 0:
      dwc = -math.ceil(deadweight_cost)
      if dwc%2 != 0:
         dwc = dwc - 1
   else:
      dwc = -math.ceil(deadweight_cost + 1)
      if dwc%2 != 0:
         dwc = dwc - 1

   # need to find point in x-axis where eu_b = opt_eu
   diff_eu_b_opt_eu = abs(eu_b - opt_eu)
   for index in range(0, index_max_eu):
      diff_eu_b_opt_eu[index] = 1

   ind_min = diff_eu_b_opt_eu.argmin()
   opt_cross_point = pi[ind_min]

   # Create plots and pdf file. Save pdf file into graphics folder
   fig1, ax = pyplot.subplots()
   ax.plot(pi, eu_b, label='State+Bank (bailout)', linestyle=':')
   ax.plot(pi, eu, label='Bank')
   ax.plot(pi, eu_c, label='State+Bank (no bailout)', linestyle='--')
   #ax.set_xlabel('x-Axis Label')
   #ax.set_ylabel('y-Axis Label')
   ax.plot([opt_prob_eu, opt_prob_eu], [opt_eu, dwc], 'k-', lw=0.5)
   ax.plot([0, 1], [opt_eu, opt_eu], 'k', lw=0.5)
   ax.plot([opt_prob_eu_b, opt_prob_eu_b], [opt_eu_b, dwc], 'k-', lw=0.5)
   ax.plot([opt_prob_eu_c, opt_prob_eu_c], [opt_eu_c, dwc], 'k-', lw=0.5)
   ax.plot([opt_prob_eu, opt_prob_eu_b, opt_prob_eu_c], [opt_eu, opt_eu_b, opt_eu_c], 'ro', color='b', mec='k', ms=5, mew=1, alpha=.6)
   ax.add_patch(patches.Rectangle((opt_prob_eu_b, dwc), opt_cross_point-opt_prob_eu_b, abs(dwc)+opt_eu_b, alpha=0.3, facecolor='yellow'))
   ax.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)

   html_text_fig1 = mpld3.fig_to_html(fig1)
   pyplot.savefig('tbtf/modelinfinite/graphics/I_Model_Infinite_1.pdf', format='pdf')
   pyplot.close(fig1)

   fig2, bx = pyplot.subplots()
   A = 0.8
   bx.plot([0, opt_prob_eu_b], [opt_prob_eu_b, opt_prob_eu_b], linestyle=':', lw=5.0, label='not binding')
   bx.fill_between([0, opt_prob_eu_b], [opt_prob_eu_b, opt_prob_eu_b], facecolor='blue', alpha=0.1, interpolate=True)
   bx.plot([opt_prob_eu_b, opt_cross_point], [opt_prob_eu_b, A], linestyle='--', lw=5.0, label='binding')
   bx.fill_between([opt_prob_eu_b, opt_cross_point], [opt_prob_eu_b, A], facecolor='green', alpha=0.1, interpolate=True)
   bx.plot([opt_cross_point, 1], [opt_prob_eu, opt_prob_eu], 'k-', lw=5.0, label='violated')
   bx.fill_between([opt_cross_point, 1], [opt_prob_eu, opt_prob_eu], facecolor='black', alpha=0.1, interpolate=True)
   bx.legend(loc='upper left', frameon=0, fontsize = 'medium', title='', fancybox=True)

   html_text_fig2 = mpld3.fig_to_html(fig2)
   pyplot.savefig('tbtf/modelinfinite/graphics/I_Model_Infinite_2.pdf', format='pdf')
   pyplot.close(fig2)

   return opt_eu, opt_eu_b, opt_eu_c, opt_prob_eu, opt_prob_eu_b, opt_prob_eu_c, opt_col_eu, opt_col_eu_b,opt_eu_c,\
          eu_diff, eu_b_diff, eu_diff_rel, eu_b_diff_rel, eu, eu_b, eu_c, pi, html_text_fig1, html_text_fig2
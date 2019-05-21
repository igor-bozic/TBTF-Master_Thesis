""" 
Function(s): model_static

Description:
   In the static setting the optimal solution is found by grid search. That is, for each value of probability in a grid
   the corresponding Expected return (EU) is calculated. The optimal probability is the value that corresponds to
   the maximum EU.

Reference:
   The code below has been taken form the Department of Banking and Finance .It has been rewritten from Matlab.
   Variable names have been changed for a better understanding.

Additional: PDF and HTML (mpld3) output has been included.

Author(s): Igor Bozic, Department of Banking and Finance

"""

import numpy as np
import math
import matplotlib.pyplot as pyplot, mpld3


def model_static(r_max, r_min, bailout_cost, deadweight_cost, accuracy):

   # 1. Grid Search

   # calculations:
   pi = np.arange(0, 1, accuracy)
   r_step = (r_max - r_min) * accuracy          # step in vector of returns
   r_vec = r_min + (r_max - r_min) * (1 - pi)   # vector of returns

   # expected returns:
   eu = r_vec * pi
   eu_b = r_vec * pi + bailout_cost * (1 - pi)
   eu_c = r_vec * pi - deadweight_cost * (1 - pi)

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
    
   # Create plots and pdf file. Save pdf file into graphics folder
   fig, ax = pyplot.subplots()
   ax.plot(pi, eu_b, label='State+Bank (bailout)', linestyle=':')
   ax.plot(pi, eu, label='Bank')
   ax.plot(pi, eu_c, label='State+Bank (no bailout)', linestyle='--')
   #ax.set_xlabel('x-Axis Label')
   #ax.set_ylabel('y-Axis Label')
   ax.plot([opt_prob_eu, opt_prob_eu], [opt_eu, dwc], 'k-', lw=0.5)
   ax.plot([opt_prob_eu_b, opt_prob_eu_b], [opt_eu_b, dwc], 'k-', lw=0.5)
   ax.plot([opt_prob_eu_c, opt_prob_eu_c], [opt_eu_c, dwc], 'k-', lw=0.5)
   ax.plot([opt_prob_eu, opt_prob_eu_b, opt_prob_eu_c], [opt_eu, opt_eu_b, opt_eu_c], 'ro', color='b', mec='k', ms=5, mew=1, alpha=.6)
   ax.legend(loc='upper right', frameon=0, fontsize = 'medium', title='', fancybox=True)

   pyplot.savefig('tbtf/modelstatic/graphics/S_Normalized.pdf', format='pdf')    # Generate pdf file and save it into graphics folder

   html_text = mpld3.fig_to_html(fig)                                            # Return results in html format
   pyplot.close(fig)

   return opt_eu, opt_eu_b, opt_eu_c, opt_prob_eu, opt_prob_eu_b, opt_prob_eu_c, opt_col_eu, opt_col_eu_b,opt_eu_c,\
          eu_diff, eu_b_diff, eu_diff_rel, eu_b_diff_rel, eu, eu_b, eu_c, pi, html_text

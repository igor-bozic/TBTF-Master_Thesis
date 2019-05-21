from flask import Blueprint, render_template, request, send_file, make_response
from tbtf.modelinfinite.compute_model_infinite import model_infinite
from tbtf.modelinfinite.model_model_infinite import InputForm

modelinfinite = Blueprint('modelinfinite', __name__, template_folder='templates', static_folder='static')

@modelinfinite.route('/', methods=['GET', 'POST'])
def index():
   form = InputForm(request.form)

   # Check if a button has been pressed
   if request.method == 'POST' and (request.form['btn'] == 'Calculate' or request.form['btn'] == 'Rmax Up' or\
                                    request.form['btn'] == 'Rmax Down' or request.form['btn'] == 'Rmin Up' or\
                                    request.form['btn'] == 'Rmin Down' or request.form['btn'] == 'Bailout Up' or\
                                    request.form['btn'] == 'Bailout Down' or request.form['btn'] == 'Cost Up' or\
                                    request.form['btn'] == 'Cost Down'):

      # Check if entered values are valid
      if form.validate() == False:
         info_init = "Format not valid. Provide correct inputs an press: Start Game..."
         out_r_max = form.r_max.errors
         out_r_min = form.r_min.errors
         out_bailout_cost = form.bailout_cost.errors
         out_deadweight_cost = form.deadweight_cost.errors
         out_accuracy = form.accuracy.errors
         out_discount_rate = form.discount_rate.errors
         out_r = form.r.errors

         # Return HTML View with error messages
         return render_template("view_model_infinite_wor.html", form=form, info_init=info_init,
                             output_r_max=out_r_max, output_r_min=out_r_min, output_bailout_cost=out_bailout_cost,
                             output_deadweight_cost=out_deadweight_cost, output_accuracy=out_accuracy,
                             output_discount_rate=out_discount_rate, output_r=out_r)

      else:
         nr_to_round = 5
         r_max = form.r_max.data
         r_min = form.r_min.data
         bailout_cost = form.bailout_cost.data
         deadweight_cost = form.deadweight_cost.data
         accuracy = form.accuracy.data
         discount_rate = form.discount_rate.data
         r = form.r.data

         step_size = form.step_size.data

         # Check if one of the button's UP or Down has been pressed. If yes store data into cookies
         if request.form['btn'] == 'Rmax Up':
            r_max = float(request.cookies.get('cookies_rmax'))
            r_min = float(request.cookies.get('cookies_rmin'))
            bailout_cost = float(request.cookies.get('cookies_b'))
            deadweight_cost = float(request.cookies.get('cookies_c'))
            r_max = r_max + step_size

         if request.form['btn'] == 'Rmax Down':
            r_max = float(request.cookies.get('cookies_rmax'))
            r_min = float(request.cookies.get('cookies_rmin'))
            bailout_cost = float(request.cookies.get('cookies_b'))
            deadweight_cost = float(request.cookies.get('cookies_c'))
            r_max = r_max - step_size

         if request.form['btn'] == 'Rmin Up':
            r_max = float(request.cookies.get('cookies_rmax'))
            r_min = float(request.cookies.get('cookies_rmin'))
            bailout_cost = float(request.cookies.get('cookies_b'))
            deadweight_cost = float(request.cookies.get('cookies_c'))
            r_min = r_min + step_size

         if request.form['btn'] == 'Rmin Down':
            r_max = float(request.cookies.get('cookies_rmax'))
            r_min = float(request.cookies.get('cookies_rmin'))
            bailout_cost = float(request.cookies.get('cookies_b'))
            deadweight_cost = float(request.cookies.get('cookies_c'))
            r_min = r_min - step_size

         if request.form['btn'] == 'Bailout Up':
            r_max = float(request.cookies.get('cookies_rmax'))
            r_min = float(request.cookies.get('cookies_rmin'))
            bailout_cost = float(request.cookies.get('cookies_b'))
            deadweight_cost = float(request.cookies.get('cookies_c'))
            bailout_cost = bailout_cost + step_size

         if request.form['btn'] == 'Bailout Down':
            r_max = float(request.cookies.get('cookies_rmax'))
            r_min = float(request.cookies.get('cookies_rmin'))
            bailout_cost = float(request.cookies.get('cookies_b'))
            deadweight_cost = float(request.cookies.get('cookies_c'))
            bailout_cost = bailout_cost - step_size

         if request.form['btn'] == 'Cost Up':
            r_max = float(request.cookies.get('cookies_rmax'))
            r_min = float(request.cookies.get('cookies_rmin'))
            bailout_cost = float(request.cookies.get('cookies_b'))
            deadweight_cost = float(request.cookies.get('cookies_c'))
            deadweight_cost = deadweight_cost + step_size

         if request.form['btn'] == 'Cost Down':
            r_max = float(request.cookies.get('cookies_rmax'))
            r_min = float(request.cookies.get('cookies_rmin'))
            bailout_cost = float(request.cookies.get('cookies_b'))
            deadweight_cost = float(request.cookies.get('cookies_c'))
            deadweight_cost = deadweight_cost - step_size

         opt_eu, opt_eu_b, opt_eu_c, \
         opt_prob_eu, opt_prob_eu_b, opt_prob_eu_c,\
         opt_col_eu, opt_col_eu_b,opt_eu_c,\
         eu_diff, eu_b_diff,\
         eu_diff_rel, eu_b_diff_rel,\
         eu, eu_b, eu_c, pi, fig1, fig2 = model_infinite(r_max, r_min, bailout_cost, deadweight_cost, accuracy, discount_rate, r)

         opt_eu = round(opt_eu, nr_to_round)
         opt_eu_b = round(opt_eu_b, nr_to_round)
         opt_eu_c = round(opt_eu_c, nr_to_round)
         opt_prob_eu = round(opt_prob_eu, nr_to_round)
         opt_prob_eu_b = round(opt_prob_eu_b, nr_to_round)
         opt_prob_eu_c = round(opt_prob_eu_c, nr_to_round)
         opt_col_eu = round(opt_col_eu, nr_to_round)
         opt_col_eu_b = round(opt_col_eu_b, nr_to_round)
         opt_eu_c = round(opt_eu_c, nr_to_round)
         eu_diff = round(eu_diff, nr_to_round)
         eu_b_diff = round(eu_b_diff, nr_to_round)
         eu_diff_rel = round(eu_diff_rel, nr_to_round)
         eu_b_diff_rel = round(eu_b_diff_rel, nr_to_round)

         # # Return HTML View with results
         resp = make_response(render_template("view_model_infinite.html", form=form, opt_eu = opt_eu, opt_eu_b = opt_eu_b,
                          opt_eu_c = opt_eu_c, opt_prob_eu = opt_prob_eu, opt_prob_eu_b = opt_prob_eu_b,
                          opt_prob_eu_c = opt_prob_eu_c, opt_col_eu = opt_col_eu, opt_col_eu_b = opt_col_eu_b,
                          eu_diff = eu_diff, eu_b_diff = eu_b_diff, eu_diff_rel = eu_diff_rel, eu_b_diff_rel = eu_b_diff_rel,
                          eu = eu, eu_b = eu_b, eu_c = eu_c, pi = pi, fig1=fig1, fig2=fig2,
                          out_r_max=r_max, out_r_min=r_min, out_b=bailout_cost, out_c=deadweight_cost))
         resp.set_cookie('cookies_rmax', str(r_max))
         resp.set_cookie('cookies_rmin', str(r_min))
         resp.set_cookie('cookies_b', str(bailout_cost))
         resp.set_cookie('cookies_c', str(deadweight_cost))
         return resp

   # Check if a button download has been pressed. If yes, download file on local machine
   if request.method == 'POST' and request.form['btn'] == 'Download 1':
      return send_file('modelinfinite/graphics/I_Model_Infinite_1.pdf', as_attachment=True)
   if request.method == 'POST' and request.form['btn'] == 'Download 2':
      return send_file('modelinfinite/graphics/I_Model_Infinite_2.pdf', as_attachment=True)

   # Return HTML View without results
   return render_template("view_model_infinite_wor.html", form=form)

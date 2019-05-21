from flask import Blueprint, render_template, request, send_file, make_response
from tbtf.modelstatic.compute_model_static import model_static
from tbtf.modelstatic.model_model_static import InputForm

modelstatic = Blueprint('modelstatic', __name__, template_folder='templates', static_folder='static')

@modelstatic.route('/', methods=['GET', 'POST'])
def index():
   form = InputForm(request.form)

   # Check if any button has been pressed
   if request.method == 'POST' and (request.form['btn'] == 'Calculate' or request.form['btn'] == 'Rmax Up' or\
                                    request.form['btn'] == 'Rmax Down' or request.form['btn'] == 'Rmin Up' or\
                                    request.form['btn'] == 'Rmin Down' or request.form['btn'] == 'Bailout Up' or\
                                    request.form['btn'] == 'Bailout Down' or request.form['btn'] == 'Cost Up' or\
                                    request.form['btn'] == 'Cost Down'):

      # Check if input values are valid. If not valid return template without results and
      # generate error message
      if form.validate() == False:
         info_init = "Format not valid. Provide correct inputs an press: Start Game..."
         out_r_max = form.r_max.errors
         out_r_min = form.r_min.errors
         out_bailout_cost = form.bailout_cost.errors
         out_deadweight_cost = form.deadweight_cost.errors
         out_accuracy = form.accuracy.errors

         # Return HTML View without results
         return render_template("view_model_static_wor.html", form=form, info_init=info_init,
                             output_r_max=out_r_max, output_r_min=out_r_min, output_bailout_cost=out_bailout_cost,
                             output_deadweight_cost=out_deadweight_cost, output_accuracy=out_accuracy)
      else:

         nr_to_round = 5                                             # rounding the output values
         r_max = form.r_max.data                                     # read input values
         r_min = form.r_min.data
         bailout_cost = form.bailout_cost.data
         deadweight_cost = form.deadweight_cost.data
         accuracy = form.accuracy.data

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

         # Call funtion model_static and do calculation
         opt_eu, opt_eu_b, opt_eu_c, \
         opt_prob_eu, opt_prob_eu_b, opt_prob_eu_c,\
         opt_col_eu, opt_col_eu_b,opt_eu_c,\
         eu_diff, eu_b_diff,\
         eu_diff_rel, eu_b_diff_rel,\
         eu, eu_b, eu_c, pi, fig = model_static(r_max, r_min, bailout_cost, deadweight_cost, accuracy)

         # rounding output values
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

         r_max = round(r_max, nr_to_round)
         r_min = round(r_min, nr_to_round)
         bailout_cost = round(bailout_cost, nr_to_round)
         deadweight_cost = round(deadweight_cost, nr_to_round)

         # Return HTML View with results
         resp = make_response(render_template("view_model_static.html", form=form, opt_eu = opt_eu, opt_eu_b = opt_eu_b,
                          opt_eu_c = opt_eu_c, opt_prob_eu = opt_prob_eu, opt_prob_eu_b = opt_prob_eu_b,
                          opt_prob_eu_c = opt_prob_eu_c, opt_col_eu = opt_col_eu, opt_col_eu_b = opt_col_eu_b,
                          eu_diff = eu_diff, eu_b_diff = eu_b_diff, eu_diff_rel = eu_diff_rel, eu_b_diff_rel = eu_b_diff_rel,
                          eu = eu, eu_b = eu_b, eu_c = eu_c, pi = pi, fig=fig,
                          out_r_max=r_max, out_r_min=r_min, out_b=bailout_cost, out_c=deadweight_cost))
         resp.set_cookie('cookies_rmax', str(r_max))
         resp.set_cookie('cookies_rmin', str(r_min))
         resp.set_cookie('cookies_b', str(bailout_cost))
         resp.set_cookie('cookies_c', str(deadweight_cost))
         return resp

   # Check if button download is pressed. If yes, download pdf file
   if request.method == 'POST' and request.form['btn'] == 'Download':
      return send_file('modelstatic/graphics/S_Normalized.pdf', as_attachment=True)

   # Return HTML View without results.
   return render_template("view_model_static_wor.html", form=form)

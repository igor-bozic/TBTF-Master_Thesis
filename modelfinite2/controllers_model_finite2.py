from flask import Blueprint, render_template, request, send_file
from tbtf.modelfinite2.compute_model_finite2 import plot_model_finte2_opt_values
from tbtf.modelfinite2.model_model_finite2 import InputForm

modelfinite2 = Blueprint('modelfinite2', __name__, template_folder='templates', static_folder='static')

@modelfinite2.route('/', methods=['GET', 'POST'])
def index():
   form = InputForm(request.form)

   # Check if any button is pressed.
   if request.method == 'POST':
      # Check if button calculate is pressed
      if request.form['btn'] == 'Calculate':
         # Check if values are valid
         if form.validate() == False:
            info_init = "Format not valid. Provide correct inputs an press: Start Game..."
            out_r_max = form.r_max.errors
            out_r_min = form.r_min.errors
            out_bailout_cost = form.bailout_cost.errors
            out_deadweight_cost = form.deadweight_cost.errors
            out_discount_rate = form.discount_rate.errors
            out_nr_of_periods = form.nr_of_periods.errors

            # Return HTML View with error messages
            return render_template("view_model_finite2_wor.html", form=form, info_init=info_init,
                                output_r_max=out_r_max, output_r_min=out_r_min, output_bailout_cost=out_bailout_cost,
                                output_deadweight_cost=out_deadweight_cost, output_discount_rate=out_discount_rate,
                                output_nr_of_periods=out_nr_of_periods)

         else:
            r_max = form.r_max.data
            r_min = form.r_min.data
            bailout_cost = form.bailout_cost.data
            deadweight_cost = form.deadweight_cost.data
            discount_rate = form.discount_rate.data
            nr_of_periods = form.nr_of_periods.data

            fig1, fig2, fig3 = plot_model_finte2_opt_values(r_max, r_min, bailout_cost, deadweight_cost, discount_rate, nr_of_periods)

            # Return HTML View with results
            return render_template("view_model_finite2.html", form=form, fig1=fig1, fig2=fig2, fig3=fig3)

      # Check if one of the download buttons is pressed. If yes, download pdf file on local machine
      elif request.form['btn'] == 'Download 1':
         return send_file('modelfinite2/graphics/Profit_Loss_Opt.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 2':
         return send_file('modelfinite2/graphics/PI_Opt.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 3':
         return send_file('modelfinite2/graphics/Thetas.pdf', as_attachment=True)

   # Return HTML View file without the results
   return render_template("view_model_finite2_wor.html", form=form)

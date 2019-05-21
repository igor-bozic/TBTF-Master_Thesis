from flask import Blueprint, render_template, request, send_file
from tbtf.modelfinitebounded.compute_model_finite_bounded import model_finite_bounded
from tbtf.modelfinitebounded.model_model_finite_bounded import InputForm

modelfinitebounded = Blueprint('modelfinitebounded', __name__, template_folder='templates', static_folder='static')

@modelfinitebounded.route('/', methods=['GET', 'POST'])
def index():
   form = InputForm(request.form)

   # Check if button is pressed
   if request.method == 'POST':
      if request.form['btn'] == 'Calculate':

         # Check if entered values are valid
         if form.validate() == False:
            info_init = "Format not valid. Provide correct inputs an press: Start Game..."
            out_r_max = form.r_max.errors
            out_r_min = form.r_min.errors
            out_bailout_cost = form.bailout_cost.errors
            out_deadweight_cost = form.deadweight_cost.errors
            out_discount_rate = form.discount_rate.errors
            out_nr_of_periods = form.nr_of_periods.errors

            # Return HTML View with error messages
            return render_template("view_model_finite_bounded_wor.html", form=form, info_init=info_init,
                                output_r_max=out_r_max, output_r_min=out_r_min, output_bailout_cost=out_bailout_cost,
                                output_deadweight_cost=out_deadweight_cost, output_discount_rate=out_discount_rate,
                                output_nr_of_periods=out_nr_of_periods)

         else:
            nr_to_round = 5
            r_max = form.r_max.data
            r_min = form.r_min.data
            bailout_cost = form.bailout_cost.data
            deadweight_cost = form.deadweight_cost.data
            discount_rate = form.discount_rate.data
            nr_of_periods = form.nr_of_periods.data

            fig1, fig2, fig3, fig4, fig5, fig6, fig7, fig8, fig9 = model_finite_bounded(r_max, r_min, bailout_cost,
                                                                                        deadweight_cost, discount_rate,
                                                                                        nr_of_periods)

            # Return HTML View with results
            return render_template("view_model_finite_bounded.html", form=form, fig1=fig1, fig2=fig2, fig3=fig3, fig4=fig4,
                             fig5=fig5, fig6=fig6, fig7=fig7, fig8=fig8, fig9=fig9)

      # Check if a download button is pressed. If yes, download pdf file on local machine
      elif request.form['btn'] == 'Download 1':
         return send_file('modelfinitebounded/graphics/FB_Optimal_Probabilities_for_the_Bank.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 2':
         return send_file('modelfinitebounded/graphics/FB_Optimal_Probabilities.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 3':
         return send_file('modelfinitebounded/graphics/FB_State_Value.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 4':
         return send_file('modelfinitebounded/graphics/FB_Optimal_Probabilities_Change_Banks_PI.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 5':
         return send_file('modelfinitebounded/graphics/FB_State_Value_if_Bank_switches_to_State_PI.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 6':
         return send_file('modelfinitebounded/graphics/FB_Optimal_Probabilities_Banks_Prob_not_changed.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 7':
         return send_file('modelfinitebounded/graphics/FB_State_Value_if_choses_whether_to_save_the_Bank.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 8':
         return send_file('modelfinitebounded/graphics/FB_Optimal_Probabilities_in_Joint_Game.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 9':
         return send_file('modelfinitebounded/graphics/FB_State_Value_in_the_Joint_Game.pdf', as_attachment=True)

   # Return HTML View without results
   return render_template("view_model_finite_bounded_wor.html", form=form)


from flask import Blueprint, render_template, request, send_file
from tbtf.modelfinite.compute_model_finite import model_finite
from tbtf.modelfinite.model_model_finite import InputForm

modelfinite = Blueprint('modelfinite', __name__, template_folder='templates', static_folder='static')

@modelfinite.route('/', methods=['GET', 'POST'])
def index():
   form = InputForm(request.form)

   # Check if button has been pressed
   if request.method == 'POST':
      if request.form['btn'] == 'Calculate':

         # Check if entered values are valid. Otherwise return error message
         if form.validate() == False:
            info_init = "Format not valid. Provide correct inputs an press: Start Game..."
            out_r_max = form.r_max.errors
            out_r_min = form.r_min.errors
            out_bailout_cost = form.bailout_cost.errors
            out_deadweight_cost = form.deadweight_cost.errors
            out_accuracy = form.accuracy.errors
            out_discount_rate = form.discount_rate.errors
            out_r = form.r.errors
            out_nr_of_periods = form.nr_of_periods.errors

            # Return HTML View with error messages
            return render_template("view_model_finite_wor.html", form=form, info_init=info_init,
                                output_r_max=out_r_max, output_r_min=out_r_min, output_bailout_cost=out_bailout_cost,
                                output_deadweight_cost=out_deadweight_cost, output_accuracy=out_accuracy,
                                output_discount_rate=out_discount_rate, output_r=out_r, output_nr_of_periods=out_nr_of_periods)

         else:
            #nr_to_round = 5
            r_max = form.r_max.data
            r_min = form.r_min.data
            bailout_cost = form.bailout_cost.data
            deadweight_cost = form.deadweight_cost.data
            accuracy = form.accuracy.data
            discount_rate = form.discount_rate.data
            r = form.r.data
            nr_of_periods = form.nr_of_periods.data

            fig1, fig2, fig3, fig4, fig5, fig6, fig7, fig8, fig9, fig10, fig11 = model_finite(r_max, r_min, bailout_cost,
                                                                                              deadweight_cost, accuracy,
                                                                                              discount_rate, r, nr_of_periods)

            # Return HTML View with results
            return render_template("view_model_finite.html", form=form, fig1=fig1, fig2=fig2, fig3=fig3, fig4=fig4, fig5=fig5,
                             fig6=fig6, fig7=fig7, fig8=fig8, fig9=fig9, fig10=fig10, fig11=fig11)

      # If one of the download buttons has been pressed, download pdf file locally
      elif request.form['btn'] == 'Download 1':
         return send_file('modelfinite/graphics/F_Value_for_the_Bank_Last_Period_No_Bailout.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 2':
         return send_file('modelfinite/graphics/F_Optimal_Probabilities_for_the_Bank.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 3':
         return send_file('modelfinite/graphics/F_Machine_Results.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 4':
         return send_file('modelfinite/graphics/F_Analytical_Results.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 5':
         return send_file('modelfinite/graphics/F_State_Value_Function.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 6':
         return send_file('modelfinite/graphics/F_Optimal_Probabilities.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 7':
         return send_file('modelfinite/graphics/F_State_Value_if_Bank_Switches_to_State_pi.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 8':
         return send_file('modelfinite/graphics/F_Optimal_Probabilities_State_Chooses_min(c_b_dv).pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 9':
         return send_file('modelfinite/graphics/F_State_Value_if_it_choses_whether_to_save_the_Bank.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 10':
         return send_file('modelfinite/graphics/F_Optimal_Probabilities_in_Joint_Game.pdf', as_attachment=True)
      elif request.form['btn'] == 'Download 11':
         return send_file('modelfinite/graphics/F_State_Value_in_Joint_Game.pdf', as_attachment=True)

   # Return HTML View file without the results
   return render_template("view_model_finite_wor.html", form=form)

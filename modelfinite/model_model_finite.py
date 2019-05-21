# Class for Edit fields. Input data from user

from wtforms import Form, FloatField, validators

class InputForm(Form):
   r_max = FloatField(
           label='Rmax', default=9.0,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=None, message="Rmax >= 0.0")])

   r_min = FloatField(
           label='Rmin', default=1.0,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=None, message="Rmin >= 0.0")])

   bailout_cost = FloatField(
           label='Bailout Cost', default=2.0,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=None, message="b >= 0.0")])

   deadweight_cost = FloatField(
           label='Deadweight Cost', default=6.0,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=None, message="c >= 0.0")])

   accuracy = FloatField(
           label='Accuracy', default=0.001,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=1.0, message="0.0 <= d <= 1.0")])

   discount_rate = FloatField(
           label='Discount Rate', default=(0.6667),
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=1.0, message="0.0 <= delta <= 1.0")])
   r = FloatField(
           label='R', default=1.0,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=None, message="r >= 0.0")])

   nr_of_periods = FloatField(
           label='Number of Periods', default=10,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=1.0, max=None, message="Periods >= 1.0")])

# Class for Edit fields. Input data from user

from wtforms import Form, FloatField, validators


class InputForm(Form):
   r_max = FloatField(
           label='Rmax', default=10.0,
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
           label='Deadweight Cost', default=3.0,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=None, message="c >= 0.0 ")])
   accuracy = FloatField(
           label='Accuracy', default=0.001,
           validators=[validators.InputRequired(),
                       validators.NumberRange(min=0.0, max=1.0, message="0.0 <= a <= 1.0")])
   step_size = FloatField(
           label='Step Size', default=0.5,
           validators=[validators.NumberRange(min=0.0, max=1.0, message="0.0 <= s <= 1.0")])
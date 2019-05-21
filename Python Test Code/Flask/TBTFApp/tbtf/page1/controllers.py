from flask import Blueprint, render_template, request
from tbtf.page1.compute import compute
from tbtf.page1.model import InputForm

page1 = Blueprint('page1', __name__, template_folder='templates')

@page1.route('/', methods=['GET', 'POST'])

def index():
    form = InputForm(request.form)
    
    if request.method == 'POST' and form.validate() and request.form['submit'] == 'equals':
        r = form.r.data
        s = compute(r)
    else:
        s = None

    return render_template("view.html", form=form, s=s)
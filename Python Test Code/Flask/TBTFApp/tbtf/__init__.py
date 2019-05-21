from flask import Flask
from tbtf.main.controllers import main
from tbtf.page1.controllers import page1

app = Flask(__name__)

app.register_blueprint(main, url_prefix='/')
app.register_blueprint(page1, url_prefix='/page1')
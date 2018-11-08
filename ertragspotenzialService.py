from flask import Flask
import pandas as pd

app = Flask(__name__)
XL_FILE = "Unternehmensdaten_neu.xlsx"

@app.route("/")
def hello():
    return df.to_json()

df = pd.read_excel(XL_FILE)
app.run(port=4711)

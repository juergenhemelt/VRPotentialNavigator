import geocoder
import json
import time
import pandas as pd
import math

XL_FILE = 'Unternehmensdaten_neu.xlsx'
XL_FILE_OUT = "Unternehmensdaten_mit_Adresse.xlsx"
BING_API_KEY = 'AmTsup5iQajE8jOD_w_gs9BQtGMZz2zRpa2va1CwjghTR8UTMTJjl5JA1i0G1Qz3'
streets = []
housenumbers = []
cities = []
plz = []
weburls = []

df = pd.read_excel(XL_FILE)
writer = pd.ExcelWriter(XL_FILE_OUT)

for index, row in df.iterrows():
    if not (math.isnan(row.lat) or math.isnan(row.lng)):
        coords = []
        coords.append(row.lat)
        coords.append(row.lng)
        g = geocoder.bing(coords, key=BING_API_KEY, method='reverse' )
        print ("Straße: ", g.street)
        streets.append( g.street )
    else:
        streets.append( "" )

df.insert( 7, "Straße", streets)
df.to_excel( writer )
writer.save()
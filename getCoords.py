import geocoder
import json
import time
import pandas as pd
from googlesearch import search
from urllib.parse import urlparse

# XL_FILE = 'Unternehmen_GN.xlsx'
XL_FILE = 'Daten2.xlsx'
# XL_FILE_OUT = "Unternehmensdaten.xlsx"
XL_FILE_OUT = "Unternehmensdaten2.xlsx"
BING_API_KEY = 'AmTsup5iQajE8jOD_w_gs9BQtGMZz2zRpa2va1CwjghTR8UTMTJjl5JA1i0G1Qz3'
lat = []
lng = []
streets = []
housenumbers = []
cities = []
plz = []
weburls = []

df = pd.read_excel(XL_FILE)
writer = pd.ExcelWriter(XL_FILE_OUT)
# print( df )



for index, row in df.iterrows():
    searchEx = row[1] + ", " + str(row[2]) + " " + row[3]
    for searchResult in search(row[1], lang="de", num=1, stop=1):
        parsed_weburl = urlparse(searchResult)
        weburl = parsed_weburl.scheme + "://" + parsed_weburl.hostname
    g = geocoder.bing(searchEx, key=BING_API_KEY, )
    print ("Suchausdruck:", searchEx)
    print ("Latitude: ", g.lat)
    print ("Longitude: ", g.lng)
    print ("Confidence: ", g.confidence)
    print ("Status: ", g.status)
    print ("Qualität: ", g.quality)
    lat.append( g.lat )
    lng.append( g.lng )
    weburls.append( weburl )
    streets.append( g.street )
    housenumbers.append( g.street_number )
    cities.append( g.city )
    plz.append( g.postal )


df.insert( 5, "lat", lat)
df.insert( 6, "lng", lng )
df.insert( 7, "Straße", streets)
df.insert( 8, "Hausnummer", housenumbers)
df.insert( 9, "Ort", cities)
df.insert( 10, "PLZ", plz)
df.insert( 11, "Web-URL", weburls)
df.to_excel( writer )
writer.save()
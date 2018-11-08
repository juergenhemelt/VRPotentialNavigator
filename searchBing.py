from googlesearch import search
from urllib import urlparse
for url in search('REWE ZENTRALFINANZ E G KÖLN', lang='de', num=1):
    print(url)
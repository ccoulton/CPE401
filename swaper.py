import urllib2
import re

def back_Up():
    index = open("index.html", 'r')
    backup = open("index_backup.html", 'w')
    for line in index:
        backup.write(line)
    index.close()
    backup.close()
    return

def xkcdFind(input):
    found = 0
    for line in input:
        if (found == 1):
            return(line)
        else:
            finder = re.compile('<div id="comic">')
            result = finder.match(line)
            if (result != None):
                found = 1

def xkcdReplace(input, file, output):
    found = 0
    for line in file:
        if (found == 1):
            output.write(input)
            found = 0
        else:
            finder = re.compile('<!--XKCD\sSTART-->', re.IGNORECASE)
            result = finder.match(line)
            output.write(line)
            if (result != None):
                found =1
                
xkcdWebPage ="http://www.xkcd.com"
back_Up()
index = open("index_backup.html",'r')
outfile = open("index.html", 'w')
xkcd = urllib2.urlopen(xkcdWebPage)
xkcdComic = xkcdFind(xkcd)
xkcdReplace(xkcdComic, index, outfile)
index.close()
outfile.close()

import pandas as pd
import json
import re
import warnings
import sys

for source in ["eebo","ecco"]:
    sys.stderr.write("working on %s\n" %source)
    csv = pd.read_csv("generated/" + source + "-headers.csv")
    for row in csv.iterrows():
        data = dict(row[1])
        #Create a second date field that wildly guesses at the year
        try:
            data['date'] = re.sub(r".*(\d\d\d\d).*",r"\1",data['pubdate'])
        except TypeError:
            warnings.warn("empty date field")
            pass
        #Filenames in the other file are as xml; correct for this.
        data['filename'] = re.sub(r"hdr$",r"xml",data['filename'])
        #Put in the title, and link to Michigan.
        data['searchstring'] = str(data['title']) + ' ' + str(data['author'])
        data['searchstring'] = "<a href=http://quod.lib.umich.edu/e/%s/%s?view=toc>" % (source,data['dlps']) + data['searchstring'] + "</a>"
        #Also note whether it's eebo or ecco
        data['source'] =  source
        print json.dumps(data)


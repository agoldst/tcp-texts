import pandas as pd
import json
import re

csv = pd.read_csv("generated/ecco-headers.csv")

for row in csv.iterrows():
    data = dict(row[1])
    data['date'] = re.sub(r".*(\d\d\d\d).*",r"\1",data['pubdate'])
    data['filename'] = re.sub(r"hdr$",r"xml",data['filename'])
    print json.dumps(data)

#!/usr/bin/env python

from bs4 import BeautifulSoup
import re
import csv
import codecs

author_dates_pat = re.compile(r", ([-\d]+)\.$")
filenames = []

out_rows = ["dlps", "estc", "docno", "tcp", "title", "author", "dates",
        "pubplace", "pub", "pubdate"]


def process_file(f, out):
    doc = BeautifulSoup(f, "xml")

    row = dict()
    fdesc = doc.find("FILEDESC")

    row["dlps"] = fdesc.find("IDNO", TYPE="DLPS").string
    row["estc"] = fdesc.find("IDNO", TYPE="ESTC").string
    row["docno"] = fdesc.find("IDNO", TYPE="DocNo").string
    row["tcp"] = fdesc.find("IDNO", TYPE="TCP").string

    src = doc.find("BIBLFULL")
    try:
        row["title"] = src.TITLESTMT.TITLE.string
    except AttributeError:
        pass

    try:
        a_str = src.TITLESTMT.AUTHOR.string
        row["author"] = author_dates_pat.sub("", a_str)
        row["dates"] = author_dates_pat.match(a_str).group(1)
    except AttributeError:
        pass

    try:
        row["pubplace"] = src.PUBLICATIONSTMT.PUBPLACE.string
    except AttributeError:
        pass

    try:
        row["pub"] = src.PUBLICATIONSTMT.PUBLISHER.string
    except AttributeError:
        pass

    try:
        row["pubdate"] = src.PUBLICATIONSTMT.DATE.string
    except AttributeError:
        pass

    # unicode-ify
    out.writerow({ k: v.encode('utf8') for k, v in row.items() }) 

if __name__ == "__main__":
    import sys

    out = csv.DictWriter(sys.stdout, out_rows, quoting=csv.QUOTE_ALL)
    out.writeheader()

    for fn in sys.argv[1:]:
        with codecs.open(fn, "r", encoding="utf-8") as f:
            process_file(f, out)


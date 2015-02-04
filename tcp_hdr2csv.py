#!/usr/bin/env python

from bs4 import BeautifulSoup
import re
import csv
import codecs
import os
from os.path import basename

author_dates_pat = re.compile(r", ([-\d]+)\.$")
filenames = []

out_rows = ["filename", "dlps", "title", "author", "dates",
        "pubplace", "pub", "pubdate"]


def process_file(f, out):
    doc = BeautifulSoup(f, "xml")

    row = dict()
    fdesc = doc.find("FILEDESC")

    row["filename"] = basename(f.name)

    # TODO fails on EEBO, headers are lc and different
    # ECCO entries have IDNO types: TCP, DLPS, ESTC, DocNo
    # EEBO entries have IDNO types: DLPS, stc, estc, eebo citation, proquest, vid
    try:
        row["dlps"] = fdesc.find("IDNO", TYPE="DLPS").string
    except AttributeError:
        pass

    src = doc.find("BIBLFULL")
    try:
        row["title"] = src.TITLESTMT.TITLE.string
    except AttributeError:
        pass

    try:
        a_str = src.TITLESTMT.AUTHOR.string
        row["author"] = author_dates_pat.sub("", a_str)
        row["dates"] = author_dates_pat.search(a_str).group(1)
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

    if sys.argv[1] == "-h":
        out.writeheader()
        filenames = sys.argv[2:]
    else:
        filenames = sys.argv[1:]

    def proc(fn):
        with codecs.open(fn, "r", encoding="utf-8") as f:
            process_file(f, out)

    for fn in filenames:
        if os.path.isdir(fn):
            for f in os.listdir(fn):
                proc(os.path.join(fn, f))
        else:
            proc(fn)


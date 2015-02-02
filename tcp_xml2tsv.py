#!/usr/bin/env python

from bs4 import BeautifulSoup
import codecs
import os
from os.path import basename

def file2row(f):
    doc = BeautifulSoup(f, "xml")

    txt = doc.find("TEXT")
    if txt == None:
        txt = doc.find("text")
        if txt == None:
            raise Exception("Couldn't find <text> element")

    return basename(f.name) + "\t" + txt.get_text().replace("\n", " ")


if __name__ == "__main__":
    import sys

    if sys.argv[1] == "-h":
        print("id\ttext")
        filenames = sys.argv[2:]
    else:
        filenames = sys.argv[1:]

    def proc(fn):
        with codecs.open(fn, "r", encoding="utf-8") as f:
            line = file2row(f)
            print(line.encode("utf-8"))

    for fn in filenames:
        if os.path.isdir(fn):
            for f in os.listdir(fn):
                proc(os.path.join(fn, f))
        else:
            proc(fn)


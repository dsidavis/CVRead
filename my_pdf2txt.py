#!/usr/bin/env python

import sys
import os
#sys.path.append(os.path.abspath("/Users/duncan/DSIProjects/KimShauman/PythonTools/pdfminer/pdfminer"))
#sys.path.insert(0, "/Users/duncan/DSIProjects/KimShauman/PythonTools/pdfminer")
sys.path.insert(0, "/Users/duncan/DSIProjects/pdfminer")
#from pprint import pprint
#pprint(sys.path)

from pdfminer.pdfdocument import PDFDocument
from pdfminer.layout import LAParams
from pdfminer.converter import XMLConverter
from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer.pdfpage import PDFPage

laparams = LAParams()
imagewriter = None
codec = 'utf-8'
outfp = sys.stdout
stripcontrol = True
pagenos = set()

fname = sys.argv[1]

rsrcmgr = PDFResourceManager(caching=True)
device = XMLConverter(rsrcmgr, outfp, codec=codec, laparams=laparams,
                      imagewriter=imagewriter,
                      stripcontrol=stripcontrol)

fp = file(fname, 'rb')
interpreter = PDFPageInterpreter(rsrcmgr, device)
interpreter.debug = 1
for page in PDFPage.get_pages(fp, pagenos,
                              maxpages=0, password='',
                              caching=True, check_extractable=True):
    interpreter.process_page(page)
fp.close()
device.close()
outfp.close()


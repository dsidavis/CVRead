TIKA_JAR=/Users/duncan/tika-app-1.10.jar

USE_PDFMINER=1

ifndef USE_PDFMINER 
ifndef USE_PDFQUERY
USE_TIKA=1
endif
endif

ifdef USE_TIKA
%.html: %.pdf
	java -jar $(TIKA_JAR) --html $<  > $@

%.xml: %.pdf
	java -jar $(TIKA_JAR) --xml $<  > $@

%.txt: %.pdf
	java -jar $(TIKA_JAR) --text $<  > $@
endif

ifdef USE_PDFMINER
%.html: %.pdf
	../pdfminer/tools/pdf2txt.py -t html $<  > $@

%.xml: %.pdf
	../pdfminer/tools/pdf2txt.py -t xml $<  > $@

endif


ifdef USE_PDFQUERY
%.xml: %.pdf
	./pdfq2xml $<  $@
endif


%_tika.xml: %.pdf
	java -jar $(TIKA_JAR) --xml $<  > $@

%_miner.xml: %.pdf
	../pdfminer/tools/pdf2txt.py -t xml $<  > $@

%_query.xml: %.pdf
	../pdfq2xml $<  $@



PDFS=$(wildcard *.pdf)
TXT=$(patsubst %.pdf, %.txt, $(PDFS))
HTML=$(patsubst %.pdf, %.html, $(PDFS))
XML=$(patsubst %.pdf, %.xml, $(PDFS))

# make -f ../GNUmakefile USE_TIKA=1 allText
allText: $(TXT)
allHTML: $(HTML)
allXML: $(XML)

ALL_XML=$(patsubst %.pdf, %_miner.xml, $(PDFS)) $(patsubst %.pdf, %_query.xml, $(PDFS))  $(patsubst %.pdf, %_tika.xml, $(PDFS))
toutXML: $(ALL_XML)
	@echo "$(ALL_XML)"





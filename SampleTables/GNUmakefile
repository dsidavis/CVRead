
%.pdf: %.tex
	pdflatex $<

uncompressed_%.pdf: %.pdf
	qpdf --qdf --object-streams=disable $< $@

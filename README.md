This is a package that explores reading PDF files for curricula vitae or resume 
and to extract information from these.


We are currently using the Python module pdfminer to read the PDF and emit
information about its content in XML. This contains the font and bounding
box information.  From these, we can recover a lot of the information
and guess the nature of different text.

The package uses new features (October 2015) in the XML package.
You can install it (from source) via 
```R
    install.packages("XML", repos = "http://www.omegahat.org/R")
```

The initial version of the package provides a variety of different ways
to get at the information we want in the PDFs. These represent different
strategies for identifying that information. It is unlikely that one
of these strategies will work for all PDFs. Instead, we will have to 
learn which order to apply them, how to determine if they are wrong
and move to another, and to add new strategies as we encounter new patterns.
This extensibility is very important, as is the ability to determine
whether a set of results is correct for a given PDF.



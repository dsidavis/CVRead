amir = pdfMinerDoc("SampleCVs/cv_amir.pdf")

ss = getSections(amir)
names(ss)

# Note still working on document, not the sections.
# Slightly strange!
sect = getWithinSection(amir)

journals = getSectionElements(sect[[8]])  # journal publications

# 49 of them, but actually, the last one has the remaining 11
# and also a slightly broke final one.
# These are together in a textgroup


if(FALSE) {
 doc = fixPages(htmlParse("SampleCVs/KimS.xml", replaceEntities = TRUE))
 ps = getNodeSet(doc, "//body/p")
 txt = gsub("\\t\\r  ", " ", xmlValue(ps[[46]]))

 crossRef(txt)
}


if(FALSE) {
u = "http://search.crossref.org/dois"

ans = getForm(u, q = "XML and Web Technologies")

ans = getForm(u, q = "XML and Web Technologies Temple Lang")

txt = "Mary R. Jackman and Kimberlee A. Shauman. “The Toll of Inequality: Racial Inequality and Death in the United States, 1900-2000.” Revise and resubmit at American Journal of Sociology."
ans = getForm(u, q = txt)
els = fromJSON(ans)

d = do.call(rbind, els)
}




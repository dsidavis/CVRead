library(XML)

# call fixPages() first.

getReferences =
function(doc)
{
   if(is.character(doc)) {
       doc = fixPages(htmlParse(doc, replaceEntities = TRUE))
   }
browser()   
   nodes = getNodeSet(doc, "//p[contains(lower-case(.), 'publication')]/following-sibling::p")
   txt = sapply(nodes, xmlValue)
}

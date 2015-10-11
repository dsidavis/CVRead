# THis is for tika output.

# Replace <div> for pages with the actual nodes so all at same level
# Find running headers (with the page number increasing possibly)

library(XML)

fixPages =
    #
    # assumes all content in <body> is within <div class="page">, i.e. no other material as children of <body>
    #
function(doc)
{
   if(is.character(doc))
       doc = htmlParse(doc)

   removePageRunner(doc)
   removePageRunner(doc, header = FALSE)
   
   pageNodes = getNodeSet(doc, "//div[@class = 'page']")

   # see if there is a header and/or a footer on each page
   first = sapply(pageNodes, function(x) xmlValue(x[[ 1 ]]))
   

   lapply(pageNodes, replaceNodeWithChildren)  # need new version of XML package.

     # Previously, if we don't reparse this, getNodeSet seems to get the nodes out of order in some cases.
     # I think this is fixed now in the XML package (by setting the appropriate parent to the newly moved children)
     # But otherwise, we can reparse the document
     # htmlParse(saveXML(doc), asText = TRUE)
   doc
}

removePageRunner =
function(doc, header = TRUE)
{
   firsts = getNodeSet(doc, sprintf("//div[@class = 'page']/p[text() or *][%s]",  if(header) "1" else "last()"))
   trimmed = gsub("(^[0-9]+ | [0-9]+$)", "", trim(sapply(firsts, xmlValue)))
   if(any(d <- duplicated(trimmed))) {
          # this would leave the first one.
       tt = table(trimmed)
       w = names(tt)[tt > 2]
       removeNodes(firsts[ trimmed %in% w ])
   }
}

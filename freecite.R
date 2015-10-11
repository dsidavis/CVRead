library(RCurl)

freecite =
function(text, url = "http://freecite.library.brown.edu/citations/create")
{
   if(length(text) > 1) {
       p = structure(text, names = rep("citation[]", length(text)))
   } else
       p = list(citation = text)

   ans = postForm(url, .params = p, .opts = list(httpheader = c(Accept = "text/xml")))
   
   doc = xmlParse(ans)
   doc
}

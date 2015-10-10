cleanText =
    #
    # This is for removing non-printing characters and other such text in
    # XML nodes. Kim's document is an example of this.
    #
function(x)
     # Not quite right yet.
 gsub("\\t\\r", " ", gsub("", "", x))   



pdfMinerDoc =
    #
    # read a PDF or already converted XML document and "tidy" it up
    # by collapsing the character nodes into text nodes,
    # removing the <page> nodes
    # and any running header content
    #
function(doc, removePageNodes = TRUE, removeHeader = TRUE, sub = cleanText)
{
   if(is.character(doc)) {
       if(grepl("\\.pdf$", doc))
          doc = convertPDF(doc)
       
       doc = xmlParse(doc)
   }

   xpathApply(doc, "//textline", collapseTextLine, sub)

   xpathApply(doc, "//layout | //line[@linewidth = 0]", removeNodes)

   pages = getNodeSet(doc, "//page")
   root = xmlRoot(doc)
   xmlAttrs(root) = c(numPages = length(pages))

   
   #XXX before we do this,
   # a) do we even need to do it?, and
   # b) can we get the header and footer at this time.
   # c) renumber the top-level <textbox> within a page to contain
   #  the page number


     # The text may contain page numbers, or these may be in a separate node.
   if(removeHeader) 
       removeHeaderFooter(pages, doc)

# Was thinking we may have to recognized and use different margin values on alternating pages   
#   margins = sapply(pages, function(x) getMargins(xmlChildren(x)))
#   if(!all(apply(margins, 1, function(x) length(unique(x)) ) == 1)) {
#       browser()
#   }   
   
   if(removePageNodes)
       lapply(pages, replaceNodeWithChildren)
   
browser()   
   
   doc
}

removeHeaderFooter =
function(pages, doc)
{
    header = lapply(pages, `[[`, 1)
    htext = sapply(header, xmlValue)

    bbox = getBBox(header)
    bottom = max(bbox[,2])

    removeNodes(header[ duplicated(htext) ])
    
    others = getNodeSet(doc, sprintf("//textbox[@bbox and  get-bottom(@bbox) >= %f]", bottom),
                          xpathFuns = list('get-bottom' = getBottom))

    removeNodes(others)
    


}


convertPDF =
    #
    # If given a pdf, call pdfminer's pdf2txt to create the XML file.
    #
    #XXX Need to locate the pdfminer/tools/pdf2txt.py script
    #
function(filename, pdfminer = "pdfminer/tools/pdf2txt.py")
{
    cmd = sprintf("%s -t xml %s", pdfminer, filename)
    system(cmd, intern = TRUE)
}


getMargins =
function(doc, m = getIndentations(doc))    
{
  structure(c(apply(m[, c(1, 2)], 2, min), apply(m[, c(3, 4)], 2, max)) , names = c("left", "bottom", "right", "top"))
}

getSections =
    #
    #XXX Needs to get much smarter
    #  Not just bold, but font size different from next lines, indentation
    #  underlines of text  (not getting this in the XML)
    #
    #
    #
    #
function(doc, setClass = TRUE, asNodes = TRUE)
{
   if(is.character(doc))
      doc = pdfMinerDoc(doc)

   ans  = getSectionsByIndent(doc, getMargins(doc)["left"], asNodes)
   if(!length(ans)) 
      ans = getNodeSet(doc, "//text[contains(@font, 'Bold')]")

   if(setClass)
       markSection(ans)

   txt = sapply(ans, xmlValue)   
   if(asNodes)
       structure(ans, names = txt)
   else
       txt
}

getSectionsByIndent =
    #
function(doc, margin = NA, asNodes = TRUE)
{
   xpquery = "//textbox[ not(ancestor::layout) and %s get-indent(following-sibling::textbox[1]/@bbox) > get-indent(@bbox) ]"
   if(!is.na(margin))
      margin = sprintf("get-indent(@bbox) = %f and", margin)
   else
      margin = ""
   
   xpquery = sprintf(xpquery, margin)

#   if(is(doc, "XMLInternalNode"))
#      xpquery = paste0(".", xpquery)
   
   getNodeSet(doc, xpquery,  xpathFuns = list('get-indent' = getIndent))
}


groupByIndent =
    #
    #  We run into a problem here with cv_amir
    #  The publications numbered from 9. to 1. have a different indentation than left.
    #  So we add the condition that if a node has multiple <textline>, then it is self-contained
    #  regardless of its indentation. But then we end up with 2 publications that
    #  are split across two groups because the second part of each has multiple <textline>
    #  If we had the pages, we could do this by page and we wouldn't have the problem.
    #  However, if a publication spanned 2 pages, we had have an entirely different problem.

    #
    #  If the publications are ordered as a list (with numbers or bullets), we can use that
    #  to detect errors and regroup.
    #
function(nodes, bbox = getIndentations(nodes))
{
   left = min(bbox[,1])
   hasMultipleLines = sapply(nodes, function(x) sum(names(x) == "textline") > 1)
   atLeft = (bbox[,1] == left)
#   prevStartsAtLeft = c(TRUE, atLeft[- length(atLeft)])
   w = cumsum(  atLeft | hasMultipleLines)   #  & prevStartsAtLeft) )
   ans = split(nodes, w)

   txt = sapply(ans, getAllText)
   firstWord = sapply(strsplit(txt, "[[:space:]]"), `[[`, 1)
   isNum = grepl("^[0-9]+[[:punct:]]?$", firstWord)
   if(sum(isNum)/length(txt) > .9) {
       # we have numbers
       if(any(!isNum)) {
           i = which(!isNum)
browser()           
           ans[i - 1L] = mapply(c, ans[i-1L], ans[i], SIMPLIFY = FALSE)
           ans = ans[-i]
       }
   } else {
       tt = table(first)
       if(max(tt)/length(txt) > .9 && length(tt) > 1) {
           # we have a common identifier
           browser()
       }
   }
   
   ans
}

getAllText =
function(nodes, collapse = "\n")
{
  paste(sapply(nodes, xmlValue), collapse = collapse)
} 

getSectionElements =
function(nodes, convert = getAllText, ...)
{
  e = groupByIndent(nodes)
  sapply(e, convert, ...) 
}


markSection =
function(nodes)
{
  invisible(mapply(function(x, idx) xmlAttrs(x) = c(class = "sectionTitle", sectionNum = idx),
                      nodes, seq(along = nodes)))
}


getWithinSection =
function(doc, sectionNodes = getNodeSet(doc, "//textbox[@class = 'sectionTitle']"))
{
  ans = lapply(sectionNodes, function(x) {
                                 idx = as.integer(xmlGetAttr(x, "sectionNum"))
                                 getNodeSet(x, sprintf("./following-sibling::textbox[ following-sibling::textbox[@sectionNum = %d]]", idx + 1L))
                              })

  names(ans) = sapply(sectionNodes, xmlValue)
  ans
}


getIndent =
    # This is an R function that we use as a function in an XPath query.
    # It is passed a list with one element which is the bbox attribute.
    # This could be an empty list so we return -1 for this case.
function(bbox)    
{
  if(length(bbox))
     as.numeric(strsplit(bbox[[1]], ",")[[1]][1])
  else
      -1
}

getBottom =
    # Also called from XPath.
function(bbox)
{
    as.numeric(strsplit(bbox[[1]], ",")[[1]][2])
}



getFontSizes =
    #
    # return a table of the counts for different font sizes
    # If name = TRUE, then we get a  2-way table of the font size and description
    #
    # Font sizes are complicated. The font name may have the size (e.g. mulhearn's CV)
    # Otherwise, we use the size attribute which is not the font size, but the box size
    # but can be a proxy, but not always a good one.
    # The size can be larger for text within a section eventhough the section title/header
    # is physically larger. It depends on the content of the box.
    # This is where we may want to keep the size of the individual characters.
function(doc, name = FALSE)
{
    fonts = getFonts(doc)
    if(all(grepl("[0-9]+$$", names(fonts)))) {
        vals = unlist(getNodeSet(doc, "//text/@font"))
        return( table( gsub(".*[^0-9]", "", vals) ) )
    }
        
    if(!name)
       table(as.numeric(unlist(getNodeSet(doc, "//text/@size"))))
    else {
       nodes = getNodeSet(doc, "//text")
       info = sapply(nodes, function(x) xmlAttrs(x)[c("font", "size")])
       table(info["size",], info[ "font", ])
    }
}

getFonts =
    #
    # Get the table of counts of the font names/descriptions used in the documents
function(doc)
{
    table(unlist(getNodeSet(doc, "//text/@font")))
}


getBBox = getIndentations =
    #
    # a matrix of bboxes for the <textline> nodes
    #
function(doc, bbox = getNodeSet(doc, "//textline/@bbox"))
{
  if(missing(bbox) && is.list(doc) && all(sapply(doc, inherits, "XMLInternalElementNode")))
     bbox = lapply(doc, xmlGetAttr, "bbox")
      
  m = do.call(rbind, strsplit(unlist(bbox), ","))
  mode(m) = "numeric"
  colnames(m) = c("left", "bottom", "right", "top")
  m
}



collapseTextLine =
    #
    # Combine the individual nodes containing a single character into a single node within a <textline> node
    # and put the resulting text into the first <text> node of that <textline> node, and delete the remaining
    # <text> nodes.
    #
    # If the font changes across characters, we lose that information currently.
    # 
function(node, sub = NULL)
{
    txt = xmlValue(node)
    if(!is.null(sub))
        txt = sub(txt)
    
    xmlValue(node[[1]]) = txt

    sizes = sapply(xmlChildren(node), xmlGetAttr, "size", "")
    xmlAttrs(node) = c(charcterSizes = paste(sizes, collapse = ","))
    
    removeNodes(xmlChildren(node)[-1])
    node
}


showBoxes =
    #
    # showBoxes(pdfMinerDoc("SampleCVs/cv_amir.pdf")))
    #
    # pamir = pdfMinerDoc("SampleCVs/cv_amir.pdf", FALSE)
    # showBoxes(getNodeSet(pamir, "/*/page[2]//*[not(ancestor::layout)]"))
    # par(mfrow = c(5, 5), mar = c(0, 0, 0, 0))
    # invisible(lapply(1:25, function(i) showBoxes(getNodeSet(pamir, sprintf("/*/page[%d]//*[not(ancestor::layout)]", i)), axes = FALSE)))
function(doc, bbox = getIndentations(doc), margins = getMargins(, bbox), ...)
{
    if(!missing(doc)) {
      if(is.character(doc)) 
         doc = pdfMinerDoc(doc, removePageNodes = FALSE, removeHeader = FALSE)

      if(is(doc, "XMLInternalDocument")) {
          pages = getNodeSet(doc, "//page")
          if(length(pages)) {
                 # Show all the pages separately
              r = ceiling(sqrt(length(pages)))
              par(mfrow = c(r, ceiling(length(pages)/r)), mar = c(0, 0, 0, 0))
              lapply(pages, function(p) showBoxes(getNodeSet(p, ".//*[not(ancestor::layout) and @bbox]"), axes = FALSE))
              return(NULL)
          }
      }
    }


    plot(0, xlim = margins[c("left", "right")], ylim = margins[c("bottom", "top")], type = "n", xlab = "", ylab = "", ...)
    rect(bbox[, 1], bbox[, 2], bbox[, 3], bbox[, 4])
}


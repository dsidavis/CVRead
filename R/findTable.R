# Given the bboxes, see if we can identify tables
# We'll use different heuristics.
# Looking for text that starts at the same X position

#
# If we know the margin, we can find text that starts at several rows
# just slightly in from that.
#
#
#
#
# Right aligned numbers
#
#
# Within a page, how to find a table.
# We can look for the word Table that introduces a table via a numbering system.
#
#
#

readTables =
function(page, atMargins = FALSE, margins = getMargins(page),
         boxes = getBBox(page, addNames = TRUE), ...)
{
   cols = getColPositions(page, boxes, margins)

   getCells(boxes, cols$columns, cols$height, ...)
}

getCells =
function(boxes, columns, heights, commonHeights = TRUE)
{
   if(commonHeights)
         # we assume all columns are the same height, i.e. the cells in each column
         # are in the same vertical bounding box, even if we have lines that are not
         # the same height.  For example, in the argentina vote document,
         # the 4th line's top is 566 rather than 588 and a cell is at 568, so would
         # be excluded.
       heights = replicate(length(heights), range(heights), simplify = FALSE)

   
   ans = mapply(getColCells, columns, c(columns[-1], Inf), heights, MoreArgs = list(boxes = boxes), SIMPLIFY = FALSE)
   if(length(ans[[length(ans)]]) == 0)
      ans = ans[ -length(ans) ]

   if(!all( sapply(ans, length) == length(ans[[1]])))
      warning("missing values in columns")
      
   ans$stringsAsFactors = FALSE
   do.call(data.frame, ans)
}

getColCells =
    #XXX  need to fill in missing cells so that items are aligned in the appropriate rows
    # We need to explicitly identify the rows.
function(start, end, heights, boxes)    
{
  i = boxes[, "left"] >= start & boxes[, "right"] <= end & boxes[, "top"] <= heights[2] & boxes[, "bottom"] >= heights[1]
  rownames(boxes)[i]
}

getColPositions =
function(page, boxes, margins)
{
    lines = findLines(page, TRUE)
    if(length(lines)) {
       tt = table(lines[, "left"])
       if(any(tt > 1)) {
          cols = as.numeric(names(tt)[tt > 1])
          ll = lines[ lines[, "left"] %in% cols, ]
          h = by(as.data.frame(ll), ll[, "left"], function(x) range(c(x$top, x$bottom)))
          return(list(columns = cols, height = h))
       }
    }
    
    pos = as.numeric(boxes[, c("left", "right")])
    pos = pos[ !(pos %in% margins[c("left", "right")])]
    pos = sort(table(pos), decreasing = TRUE)
}


findLines =
function(page, vertical = TRUE, threshold = 1)
{
   objs = getNodeSet(page, ".//line | .//rect")
   box = getBBox(objs)
   types = sapply(objs, xmlName)
   lines = types == "line"
   w = rep(FALSE, length(objs))

   if(vertical) {
       w[lines] = (box[lines, "left"] == box[lines, "right"] & box[lines, "bottom"] != box[lines, "top"])
       w[!lines] = ( abs(box[!lines, "left"] - box[!lines, "right"]) < threshold & abs(box[!lines, "bottom"] - box[!lines, "top"]) > threshold)
   } else {
       w[lines] = (box[lines, "left"] != box[lines, "right"] & box[lines, "bottom"] == box[lines, "top"])
       w[!lines] = ( abs(box[!lines, "top"] - box[!lines, "bottom"]) < threshold & abs(box[!lines, "left"] - box[!lines, "right"]) > threshold)
   }
   box[w,]
}

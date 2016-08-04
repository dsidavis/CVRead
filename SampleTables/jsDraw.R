showPage = 
function(page, width = 38.25, height = page$Height)
{
    plot(c(0, width), c(0, height), type = "n", xlab = "", ylab = "")
    showLines(page, height)
}

showLines =
function(page, height, horiz = page$HLines, vert = p6$VLines)
{
    h = mkDf(horiz, c("x", "y", "w", "l", "oc"))
    h$x1 = h$x + h$l
    h$y = height - h$y
    segments(h$x, h$y, h$x1, h$y, col = as.character(h$oc))

    v = mkDf(vert, c("x", "y", "w", "l", "oc"))
    v$y = height - v$y
    v$y1 = v$y - v$l
    segments(v$x, v$y, v$x, v$y1, col = as.character(h$oc))    

    
#    mapply(function(x, y, w, col)  lines(c(x, x + w), c(y, y), col = col),  h$x, height - h$y, h$w, col = as.character(h$oc))

    TRUE
}

mkDf = 
function(els, vars = getCommonNames(els))
{    
  do.call(rbind, lapply(els, function(x) as.data.frame(x[vars])))
}

getCommonNames =
function(els, all = FALSE)
{
    ids = unlist(lapply(els, names))
    if(all)
        unique(ids)
    else {
        tt = table(ids)
        names(tt)[tt == length(els)]
    }
}

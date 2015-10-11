library(RCurl)
library(RJSONIO)
library(rcrossref)

crossRef =
function(text, url = "http://search.crossref.org/dois")
{
    ans = getForm(url, q = text)
    els = fromJSON(ans)
    d = do.call(rbind, els)
}

removeDOIPrefix =
function(str)
{
  gsub("^http://dx.doi.org/", "", str)
}


if(FALSE) {
    # This one crossref gets wrong
tmp = crossRef("AghaKouchakA.,AMultivariateMulti-IndexDroughtMonitoringandPredictionFrame- work, NOAA Drought Task Force, Webinar Series Drought I (Understanding and Moni- toring), February 12, 2013, USA.")
tmp[1, "doi"]
#"10.1111/j.1741-3737.2010.00706.x"
cr_cn(removeDOIPrefix(tmp[1, "doi"]$doi), format = "rdf-xml")
}


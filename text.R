
SectionNames =
  list(pubs = c("PUBLICATIONS", "JOURNAL PUBLICATIONS", "PAPERS", "BOOKS", "THESIS", "PEER-REVIEWED", "CONFERENCE PROCEEDINGS"),
       software = c("Software"),
       edu = c("EDUCATION", "ACADEMIC EXPERIENCE", "RESEARCH and PROFESSIONAL EXPERIENCE"),
       grants = c("RESEARCH FUNDING", "GRANTS"),
       talks = c("INVITED TALKS", "TALKS", "PRESENTATIONS", "SEMINARS"),
       reviewer = c("REVIEWER", "EDITORIAL"))

findSections =
function(f, lines = readLines(f), sectionNames = SectionNames)
{
   sectionNames = mkSectionNamesDF(sectionNames)
   i = match(tolower(sectionNames$phrase), trim(lines), 0)
   lines[i]
}


mkSectionNamesDF =
function(topics)
{
  data.frame(phrases = unlist(topics), topics =  rep(names(topics), sapply(topics, length)), stringsAsFactors = FALSE)
}

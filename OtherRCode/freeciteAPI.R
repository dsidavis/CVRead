library(RCurl)
u = "http://freecite.library.brown.edu/citations/create"

txt = "Tsoukias, N. M., A. F. Wilson and S. C. George. Effect of Alveolar Volume and Sequential Filling on the Diffusing Capacity of the Lung: I Theory. Respiration Physiology 120(3):231-250, 2000. [11 citations]"

ans = postForm(u, citation = txt, .opts = list(httpheader = c(Accept = "text/xml")))


mtxt = c("A1 Tsoukias, N. M., Z. Tannous, A. F. Wilson and S. C. George. Single Exhalation Profiles of NO and CO2 in Humans: Effect of Dynamically Changing Flow Rate. Journal of Applied Physiology 85(2):642-652, 1998. [42 citations]",
"A2 Tsoukias, N. M. and S. C. George. A Two-Compartment Model of Pulmonary Nitric Oxide Exchange Dynamics. Journal of Applied Physiology 85(2):653-666, 1998. [102 citations]",
"A3 Tsoukias, N. M., A. F. Wilson and S. C. George. Effect of Alveolar Volume and Sequential Filling on the Diffusing Capacity of the Lung: I Theory. Respiration Physiology 120(3):231-250, 2000. [11 citations]",
"A4 Tsoukias, N. M., D. Dabdub, A. F. Wilson and S. C. George. Effect of Alveolar Volume and Sequential Filling on the Diffusing Capacity of the Lung: II Experiment. Respiration Physiology 120(3):251-271, 2000. [14 citations]")

doc = xmlParse(ans)



p = structure(mtxt, names = rep("citation[]", length(mtxt)))
ans = postForm(u, .params = p, .opts = list(httpheader = c(Accept = "text/xml")))
doc = xmlParse(ans)

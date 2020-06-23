#3.4.1 Simpson’s paradox p53 BRML
j = JPD("R<G>D>R")
setDomain!(j,:D,[:drug, :nodrug])
setDomain!(j,:R,[:recovered, :ill])
setDomain!(j,:G,[:m, :f])
assignTable!(j,:G,[0.49;0.51])
assignTable!(j,(@q D|G),[30/40 10/40; 10/40 30/40])

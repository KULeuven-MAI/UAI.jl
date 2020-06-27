# A very simple example.
using UAI
j = JPD("gotDrug>health")

# setAllInteractive!(j) would error because no domain is set yet.

# So always set the domains first
setDomain!(j,:gotDrug,[:drug, :noDrug])
setDomain!(j,:health,[:healthy, :ill])

setAllInteractive!(j)
j

# UAI.jl

Documentation for UAI.jl as educational library for the course [Uncertainty in Artificial Intelligence](https://onderwijsaanbod.kuleuven.be/syllabi/e/H02D2AE.htm#activetab=doelstellingen_idp1620896) at the [KUleuven](https://stijl.kuleuven.be/2016/img/svg/logo.svg). The main goal of this library is educational. While I'm still working on implementing (more efficient) inference algorithms their are already useful things you can do with it.


# Graph notation

You can make a graph by using the following notation, a combination of `julia '-', '<', '>', ';' ` and regular (node-name) symbols. Some examples:

## Bayesian Networks

## Markov Networks

## Chain Graphs

#

```@docs
getAllAncestors
isPerfectMap
selectdim
parseGraph
moralize
disorient
getBayesianFactor
convert
convert
getAllDescendants
getAllDescendants
marryAll!
disorient!
getDiNodeNames
getNamedTable
moralize!
marryAll
getChainComponents
```

# UAI.jl

Documentation for UAI.jl as educational library for the course [Uncertainty in Artificial Intelligence](https://onderwijsaanbod.kuleuven.be/syllabi/e/H02D2AE.htm#activetab=doelstellingen_idp1620896) at the [KUleuven](https://stijl.kuleuven.be/2016/img/svg/logo.svg). The main goal of this library is educational. While I'm still working on implementing (more efficient) inference algorithms their are already useful things you can do with it.


# Graph notation

You can make a graph by using the following notation, a combination of `julia '-', '<', '>', ';' ` and regular (node-name) symbols. Some examples:

## Bayesian Network - Collider

`plotFromStr("a>c<b", "plots/collider.png")`

![](assets/collider.png)

## Bayesian Network - Fork
`plotFromStr("a<f>b", "plots/fork.png")`

![](assets/fork.png)

## Bayesian Network - Chain
`plotFromStr("a>b>c", "plots/chain.png")`

![](assets/chain.png)

## Markov Network - A grid with a loop 
`plotFromStr("a-b-c-d-a", "plots/grid.png")`

![](assets/grid.png)

## Chain Graphs

# Bucket Elimination

```julia-repl
julia> j = JPD("a>d<b")
JPD("a>d<b", p(a)p(b)p(d|a,b), [:a, :b, :d], Dict{Symbol,Union{Nothing, Array{T,1} where T}}(:a => nothing,:b => nothing,:d => nothing), Dict{AbstractFactor,Array{Float64,N} where N}())

julia> bucks = bucketEliminate(j,makeOrder("a,b,d"))
AbstractFactor[p(a), p(d|a,b)]
γ_a(d,b)=∑_a p(a)p(d|a,b)
a   :  
b   :  p(b)γ_a(d,b)
d   :  
---------------------------------------------------
AbstractFactor[p(b), γ_a(d,b)]
γ_b(d)=∑_b p(b)γ_a(d,b)
a   :  
b   :  
d   :  γ_b(d)
---------------------------------------------------
AbstractFactor[γ_b(d)]
γ_b(d)=∑_b p(b)γ_a(d,b)
Dict{Tuple{Int64,Symbol},Array{AbstractFactor,N} where N} with 3 entries:
  (2, :b) => AbstractFactor[]
  (1, :a) => AbstractFactor[]
  (3, :d) => AbstractFactor[γ_b(d)]
```

```@autodocs
Modules = [UAI]
```

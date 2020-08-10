using UAI
import Base.show
import UAI.BayesianFactor
 
Buckets = Dict{Tuple{Int,Var},Array{AbstractFactor}}

"""
makerOrder(str::String)

Makes an ordering of a comma sperated string useful for running the bucket elimination algorithm.

```julia
makeOrder("a,b,c")
```
"""
function makeOrder(str::String)
	map(x->Var(x), split(str,","))
end

"""
bucketInitialise(j::JPD, order::Array{Var})

Initialises buckets for the bucket elimination algorithm of the given JPD as a dictionary from a (Int,Var) tuple to an Array of AbstractFactors.
The order indicating Int is determined by the index of the Var in the given order.
"""
function bucketInitialise(j::JPD, order::Array{Var})
	@assert all(map(x-> x ∈ order, j.variables))
	allfactors = copy(j.factorization.factors)
	# Buckets = Dict{Tuple{Int,Var},Array{AbstractFactor}}
	buckets = Buckets([]) 
	for (i,bucketName) in enumerate(order)
		bucketval = filter(x->bucketName ∈ getVariables(x), allfactors)
		buckets[(i,bucketName)] = bucketval
		allfactors = filter!(x-> x ∉ bucketval, allfactors)
	end
	return buckets
end

"""
"""
function printSorted(buckets)
	for b in sort(collect(buckets), by=x->x[1][1])
		println(b[1][2],"   :  ",Factorization(b[2]))
	end
end

function getVariable(f::BayesianFactor)
	return f.variable
end

struct MessageFactor <: AbstractFactor 
	variable::Var # Variable bound to the sum
	arguments::Array{Var} # Unbound variables
	factorization::Factorization 
end

function Base.show(io::IO,m::MessageFactor)
	var = m.variable
	remainingStr = join(m.arguments,",")
	factoriz = m.factorization
	print(io,"γ_$var($remainingStr)")
	#print(io,"∑_$var $factoriz")
	#print(io,"γ_$var($remainingStr)=∑_$var $factoriz")
end

function printFinalMessage(m::MessageFactor)
	var = m.variable
	remainingStr = join(m.arguments,",")
	factoriz = m.factorization
	println("γ_$var($remainingStr)=∑_$var $factoriz")
end

function getArguments(mf::MessageFactor)
	return mf.arguments
end

function getVariable(mf::MessageFactor)
	return mf.variable
end

import UAI.getVariables
function getVariables(mf::MessageFactor)
	return mf.arguments
end

"""
	message(var::Var, factors::Array{AbstractFactor})::MessageFactor

Computes message γ_{var}
"""
function message(var::Var, factors::Array{AbstractFactor})::MessageFactor
	allvars = map(x->getVariables(x),factors)
	remainingVars = mapreduce(x->filter(y->y != var,x),append!,allvars)
	remainingStr = join(remainingVars,",")
	factoriz = Factorization(factors)
	str = "γ_$var($remainingStr)=∑_$var$factoriz"
	println(str)
	return MessageFactor(var,remainingVars,factoriz)
end 

"""
	firstBucket(remainingVars::Array{Var},orderedVars::Array{Var})

Returns the first bucket (`(Int,Var)`-tuple ) of the given remaining variables.
"""
function firstBucket(remainingVars::Array{Var},orderedVars::Array{Var})
	indices = map(rv->findfirst(x->x==rv,orderedVars),remainingVars)
	foundmin = minimum(indices)
	return foundmin,orderedVars[foundmin]
end

function eliminate(orderedVars,buckets)
	for (i,currentVar) in enumerate(orderedVars)
		println(buckets[(i,currentVar)])
		if i != length(orderedVars)
			if length(buckets[(i,currentVar)]) == 1 && getVariable(buckets[(i,currentVar)][1]) == currentVar
				# Sums to one so empty the bucket and no need to add anything.
				buckets[(i,currentVar)] = []
			else
				mf = message(currentVar,buckets[(i,currentVar)])
				destBucket = firstBucket(getArguments(mf),orderedVars)
				push!(buckets[destBucket], mf)
				buckets[(i,currentVar)] = []
			end
			printSorted(buckets)
			println("---------------------------------------------------")
		else
			printFinalMessage(buckets[(i,currentVar)][1])
		end
	end
	return buckets
end

#TODO :visualize keyword?
"""
bucketEliminate(j::JPD,order::Array{Var})

Runs the bucket elimination on the given Joint Probability Distribution with the given order of variables.
The final variable determines the marginal probability distribution to be computed.
"""
function bucketEliminate(j::JPD,order::Array{Var})
		eliminate(bucketInitialise(j,order))
end

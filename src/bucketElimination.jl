using UAI
 
function makeOrder(str)
    map(x->Var(x), split(str,""))
end
 
function bucketInitialise(j::JPD, order::String)
    orderedVars = makeOrder(order)
    @assert all(map(x-> x ∈ orderedVars, j.variables))
    allfactors = copy(j.factorization.factors)
    buckets = Dict{Tuple{Int,Var},Array{AbstractFactor}}([])
    for (i,bucketName) in enumerate(orderedVars)
        bucketval = filter(x->bucketName ∈ getVariables(x), allfactors)
        buckets[(i,bucketName)] = bucketval
        allfactors = filter!(x-> x ∉ bucketval, allfactors)
    end
    return orderedVars,buckets
end
 
function printSorted(buckets)
    for b in sort(collect(buckets), by=x->x[1][1])
        println(b[1][2],"   :  ",Factorization(b[2]))
    end
end
 
import UAI.BayesianFactor
function getVariable(f::BayesianFactor)
    return f.variable
end
 
struct MessageFactor <: AbstractFactor 
    variable::Var # Variable bound to the sum
    arguments::Array{Var} # Unbound variables
    factorization::Factorization 
end
 
import Base.show
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
 
function message(var::Var, factors::Array{AbstractFactor})
    allvars = map(x->getVariables(x),factors)
    remainingVars = mapreduce(x->filter(y->y != var,x),append!,allvars)
    remainingStr = join(remainingVars,",")
    factoriz = Factorization(factors)
    str = "γ_$var($remainingStr)=∑_$var$factoriz"
    println(str)
    return MessageFactor(var,remainingVars,factoriz)
end 
function firstBucket(remainingVars,orderedVars)
    indices = map(rv->findfirst(x->x==rv,orderedVars),remainingVars)
    foundmin = minimum(indices)
    return foundmin,orderedVars[foundmin]
end
 
function printSorted(buckets)
    for b in sort(collect(buckets), by=x->x[1][1]) 
        println(b[1][2],Factorization(b[2]))
    end
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
 

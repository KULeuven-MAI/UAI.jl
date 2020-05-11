using LightGraphs
using UAI
import Base.show

struct DiscreteVar
	domain::Array{Any}
	assignment::Any
	name::String
end

abstract type AbstractFactor end

# Factorization because the version with an s is taken already.
struct Factorization
	factors::Array{AbstractFactor}
end

struct MarginalFactor <: AbstractFactor
	variable::DiscreteVar
end

struct ConditionalFactor <: AbstractFactor
	variable::DiscreteVar
	conditioningSet::Array{DiscreteVar}
end

struct JoinedFactor <: AbstractFactor
	variables::Array{DiscreteVar}
	factors::Factorization
end

function p(str)
	return string("p(",str,")")
end

Base.show(io::IO, v::DiscreteVar) = v.assignment == nothing ? print(io, v.name) : print(io, v.name, "=", v.assignment)
Base.show(io::IO, v::MarginalFactor) = print(io,p(v.variable)) 
Base.show(io::IO, v::JoinedFactor) = print(io,p(join(v.variables,",")))
Base.show(io::IO, v::ConditionalFactor) = print(io,p(string(v.variable,"|",join(v.conditioningSet,","))))
Base.show(io::IO, v::Factorization) = print(io,join(v.factors))

function assign(v::DiscreteVar, value)
	if value in v.domain
		return DiscreteVar(v.domain, value, v.name)
	else
		throws(error("A variable can only be assigned a value in it's domain."))
	end
end

function getName(v::DiscreteVar)
	return v.name
end

function hasAssignment(v::DiscreteVar)
	return !isnothing(v.assignment)
end

function hasDomain(v::DiscreteVar)
	return !isempty(v.domain)
end

function setDomain(v::DiscreteVar, domain)
	return DiscreteVar(domain,v.assignment,v.name)  
end

function getDomain(v::DiscreteVar)
	return v.domain
end


function getFactor(graph,vertex,names)::AbstractFactor
	inneighbors = LightGraphs.inneighbors(graph,vertex)
	if isempty(inneighbors)
		return MarginalFactor(DiscreteVar([],nothing,names[vertex]))
	else
		nbrs = map(x->DiscreteVar([],nothing,names[x]),inneighbors)
		return ConditionalFactor(DiscreteVar([],nothing,names[vertex]),nbrs)
	end
end

function getVariables(names::Array{String})
	return map(x->DiscreteVar([],nothing,x),names)
end

# TODO split out getVariables(str)?
function getFactorization(str)
	(sg, allnodes) = parseGraph(str)
	if is_directed(sg)
		variables = getVariables(allNodes) 
		println(string("p(",join(allnodes,","),") ="))
		factors = Factorization(map(v->getFactor(sg,v,allnodes),vertices(sg)))
		return (factors, variables)
	else
		throw(error("Only directed graphs supported as of now."))
	end
end

#TODO getVariables(factoriz::Factorization)

function getGraph(factoriz::Factorization)
	return parseFactorization(string(factoriz))
end

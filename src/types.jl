using LightGraphs
using UAI
import Base.show

struct DiscreteVar
	domain::Array{Any}
	assignment::Any
	name::String
end

abstract type AbstractFactor end
abstract type BayesianFactor <: AbstractFactor end
abstract type MarkovFactor <: AbstractFactor end

# Factorization because the version with an s is taken already.
struct Factorization
	factors::Array{AbstractFactor}
end

struct MarginalFactor <: BayesianFactor 
	variable::DiscreteVar
end

struct ConditionalFactor <: BayesianFactor 
	variable::DiscreteVar
	conditioningSet::Array{DiscreteVar}
end

struct JoinedFactor <: AbstractFactor
	variables::Array{DiscreteVar}
	factors::Factorization
end

struct PotentialFactor <: MarkovFactor 
	variables::Array{DiscreteVar}
end

function p(str)
	return string("p(",str,")")
end

function phi(str)
	return string("ϕ(",str,")")
end


Base.show(io::IO, v::DiscreteVar) = v.assignment == nothing ? print(io, v.name) : print(io, v.name, "=", v.assignment)
Base.show(io::IO, v::MarginalFactor) = print(io,p(v.variable)) 
Base.show(io::IO, v::JoinedFactor) = print(io,p(join(v.variables,",")))
Base.show(io::IO, v::ConditionalFactor) = print(io,p(string(v.variable,"|",join(v.conditioningSet,","))))
Base.show(io::IO, v::PotentialFactor) = print(io,phi(join(v.variables,",")))
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

"""
	Returns the corresponding factor of vertex v of the given graph with the given names.
"""
function getBayesianFactor(graph,vertex,names)::AbstractFactor
	inneighbors = LightGraphs.inneighbors(graph,vertex)
	if isempty(inneighbors)
		return MarginalFactor(DiscreteVar([],nothing,names[vertex]))
	else
		nbrs = map(x->DiscreteVar([],nothing,names[x]),inneighbors)
		return ConditionalFactor(DiscreteVar([],nothing,names[vertex]),nbrs)
	end
end

function getPotentialFactor(graph,clique,names)
	vars = map(x->DiscreteVar([],nothing,names[x]), sort(clique))
	return PotentialFactor(vars)	
end

function getVariables(names)
	return map(x->DiscreteVar([],nothing,x),names)
end

function getFactorization(str)
	(sg, nodeNames) = parseGraph(str)
	variables = getVariables(nodeNames) 
	if is_directed(sg)
		#println(string("p(",join(nodeNames,","),") ="))
		factors = Factorization(map(v->getBayesianFactor(sg,v,nodeNames),vertices(sg)))
		return (factors, variables)
	else
		factors = Factorization(map(cl->getPotentialFactor(sg,cl,nodeNames),maximal_cliques(sg)))
		return (factors,variables)
	end
end

function getGraph(factoriz::Factorization)
	return parseFactorization(string(factoriz))
end

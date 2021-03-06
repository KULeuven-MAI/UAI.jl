using LightGraphs
using UAI
import Base.show
import Base.write

const Var = Symbol
# Query is a representation of a probability query e.g.
# p(a,b|c,d) == ([:a, :b], [:c, :d])
# Can be constructed with @q or @query
const Query = Tuple{Array{Var,1},Array{Var,1}}

function hasConditioningSet(query)
	return length(query[2]) > 0 
end

abstract type AbstractFactor end
abstract type BayesianFactor <: AbstractFactor end
abstract type MarkovFactor <: AbstractFactor end

# Factorization because the version with an s is taken already.
struct Factorization
	factors::Array{AbstractFactor}
end

struct MarginalFactor <: BayesianFactor 
	variable::Var
end

struct ConditionalFactor <: BayesianFactor 
	variable::Var
	conditioningSet::Array{Var}
end

struct PotentialFactor <: MarkovFactor 
	variables::Array{Var}
end

function p(str)
	return string("p(",str,")")
end

function phi(str)
	return string("ϕ(",str,")")
end

Base.show(io::IO, v::MarginalFactor) = print(io,p(v.variable)) 
Base.show(io::IO, v::ConditionalFactor) = print(io,p(string(v.variable,"|",join(v.conditioningSet,","))))
Base.show(io::IO, v::PotentialFactor) = print(io,phi(join(v.variables,",")))
Base.show(io::IO, v::Factorization) = print(io,join(v.factors))
Base.show(io::IO, q::Query) = if hasConditioningSet(q)
		print(io,string(join(q[1],","),"|",join(q[2],",")))
	else
		print(io,string(join(q[1],",")))
	end

mutable struct JPD
	graphNW :: String
	factorization::Factorization
	variables::Array{Var}
	domains::Dict{Symbol,Union{Vector,Nothing}}
	#= domains::Dict{Symbol,Array{Any,1}}  =#
	probTables::Dict{F,S} where {F<:AbstractFactor, T<:Real, S<:Array{T,N} where N}
	function JPD(str::String) 
		graphNW = str
		fact, vars = getFactorization(str)
		domains = Dict(map(x->(Var(x),nothing), vars)) 
		#domains = Dict(map(x->(Var(x),convert(Vector,[])), vars)) 
		tables = Dict{AbstractFactor,Array{Float64}}()
		new(graphNW, fact, vars, domains, tables)
	end
end


function writtenDomain(d::Pair)
	domName, domVals = d
	type = eltype(domVals)
	typedVals = type <: Number ? domVals : map(x->"$type(\"$x\")",domVals)
	valsStr = string("[",join(typedVals,","),"]")
	return "setTable!(j, :$domName, $valsStr )\n"
end

function writtenDomains(jpd::JPD)
	doms = collect(j.domains)
	result = string("#Setting domains:\n",join(map(x->writtenDomain(x),doms)))
	return result 
end

function writtenGraphNW(jpd::JPD)
	gn = jpd.graphNW
	return "j = JPD(\"$gn\")\n"
end

function writtenTable(factTable::Pair)
	factor, table = factTable
	serialize("$factor.sjl",factTable)
	deserializeStr = "tmp = deserialize(\"$factor.sjl\")\n"
	return join(deserializeStr,"setTable!(j, tmp[1], tmp[2])\n")
end

function writtenTables(jpd::JPD)

end

function write(io, jpd::JPD) 
	resultstring = string(writtenGraphNW, writtenDomains(jpd))
	write(io, resultstring)
end

function setAllDomains!(jpd::JPD,domain)
	for (k,v) in jpd.domains
		jpd.domains[k] = domain
	end
	#= setAllDomains(jpd.factorization,domain) =#
end

function setDomain!(jpd::JPD,var::Symbol,domain)
	jpd.domains[var] = domain
end

function getDomain(jpd::JPD,var::Symbol)
	return jpd.domains[var]
end

function getFactor(jpd, query::Query)
	getFactor(jpd,query[1][1],query[2])
end

function getFactor(jpd, query::Var)
	getFactor(jpd,query,Var[])
end

function getFactor(jpd::JPD, query::Var, condSet::Array{Var})
	marginal = false
	if condSet == [] 
		marginal = true	
	end
	for f in jpd.factorization.factors
		if marginal && typeof(f) == MarginalFactor
			if query == f.variable 
				return f
			end
		else
			if typeof(f) == ConditionalFactor
				if query == f.variable && all(map(e-> e in f.conditioningSet,condSet))
					return f
				end
			end
		end
	end
	return nothing
end

function hasFactor(jpd::JPD, queryTuple)
	return getFactor(jpd, queryTuple[1][1],queryTuple[2]) !== nothing
end

function setTable!(jpd::JPD,query::Query,table)
	return setTable!(jpd,query[1][1],query[2],table)
end

function setTable!(jpd::JPD,query::Var,table)
	# TODO: check matching names?
	table = table isa NamedArray ? convert(Array,table) : table
	f = getFactor(jpd,query,Var[])
	domain = jpd.domains[query]
	# TODO: check for existing domains?
	if length(domain) !== length(table)
		throws(error("table length must match domain $domain"))
	end
	jpd.probTables[f] = table 
end


function setTable!(jpd::JPD,query::Var,condSet,table)
	# TODO: check matching names?
	table = table isa NamedArray ? convert(Array,table) : table
	f = getFactor(jpd,query,condSet)
	setTable!(jpd,f,table)
end


function setTable!(jpd::JPD,factor::AbstractFactor,table)
	nt = getNamedTable(jpd,factor,empty=true)
	println("Setting table for $factor")
	requiredSize = size(nt) 
	if requiredSize != size(table)
		throws(error("Table sizes mismatch, should be $requiredSize. Run getNamedTable with empty=true as example."))
	end
	jpd.probTables[factor] = table 
end

#= mutable struct DiscreteVar =#
#= 	domain::Array{Any} =#
#= 	assignment::Any =#
#= 	name::String =#
#= end =#
#Base.show(io::IO, v::Var) = v.assignment == nothing ? print(io, v.name) : print(io, v.name, "=", v.assignment)
#= function assign(v::Var, value) =#
#= 	#TODO =#
#= 	throws(error("UNiplemented")) =#
#= 	if value in v.domain =#
#= 		return Var(v.domain, value, v.name) =#
#= 	else =#
#= 		throws(error("A variable can only be assigned a value in it's domain.")) =#
#= 	end =#
#= end =#

#= function getName(v::Var) =#
#= 	return v.name =#
#= end =#

#= function hasAssignment(v::Var) =#
#= 	return !isnothing(v.assignment) =#
#= end =#
#=  =#
function hasDomain(jpd::JPD, v::Var)
	return getDomain(jpd,v) != nothing
end

function hasDomains(jpd::JPD, f::AbstractFactor)
	return all(map(x->hasDomain(jpd,x),getVariables(f)))
end

function getTable(jpd, factor::AbstractFactor)
	return jpd.probTables[factor]
end

function getTable(jpd::JPD, q::Query)
	factor = getFactor(jpd,q)
	if factor === nothing
		throw(error("The query provided is not defined in the JPD: $JPD"))
	end
	return getTable(jpd,factor)
end


"""
Returns an empty NamedArray with all the names set if all domains of the factor are specified.

Errors when some of the required domains are still not specified.
"""
function getNamedTable(jpd, factor::AbstractFactor; empty=false)
	vars = getVariables(factor)
	if !hasDomains(jpd,factor)	
		throw(error("The domains of $vars should all be set first!"))
	end
	domains = map(v->getDomain(jpd,v),vars) 
	lengths = map(d->length(d), domains)
	if empty == true
		values = zeros(lengths...)
	else
		try 
			values = getTable(jpd,factor)	
		catch e # KeyError
			values = zeros(lengths...)
		end
	end
	if factor isa MarginalFactor
		# Fix this upstream?
		return NamedArray(values,domains..., vars...)
	else
		return NamedArray(values,domains, vars)
	end
end

function getNamedTable(jpd::JPD, q::Query)
	factor = getFactor(jpd,q)
	if factor === nothing
		throw(error("The query provided is not defined in the JPD: $JPD"))
	end
	return getNamedTable(jpd,factor)
end

function setDomain!(v::Var, domain)
	v.domain = domain
end

"""
	Returns the corresponding factor of vertex v of the given graph with the given names.
"""
function getBayesianFactor(graph,vertex,names)::AbstractFactor
	inneighbors = LightGraphs.inneighbors(graph,vertex)
	if isempty(inneighbors)
		return MarginalFactor(Var(names[vertex]))
	else
		nbrs = map(x->Var(names[x]),inneighbors)
		return ConditionalFactor(Var(names[vertex]),nbrs)
	end
end

function getPotentialFactor(graph,clique,names)
	vars = map(x->Var(names[x]), sort(clique))
	return PotentialFactor(vars)	
end

function mapVar(names)
	return map(x->Var(x),names)
end

function getVariables(f::AbstractFactor)
	throw(error("Doesn't work for abstract type."))
end

function getVariables(f::BayesianFactor)
	result = [f.variable]
	if f isa ConditionalFactor
		result = vcat(result,f.conditioningSet)
	end
	return result
end

function getVariables(f::MarkovFactor)
	return f.variables
end

function getFactorization(str)
	(sg, nodeNames) = parseGraph(str)
	variables = mapVar(nodeNames) 
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

"""
Gets the chain components of a graph with the given nodeNames.
"""
function getChainComponents(graph::SimpleDiGraph)
	newG = SimpleDiGraph(nv(graph))
	graphEdges = collect(edges(graph))
	for e in edges(graph)
		if reverse(e) in graphEdges 
			add_edge!(newG,src(e),dst(e))		
		end		
	end
	result = connected_components(newG)
	return result
end



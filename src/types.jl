using LightGraphs
using UAI

struct DiscreteVar
	domain::Array{Any}
	assignment::Any
	name::String
end


Base.show(io::IO, v::DiscreteVar) = v.assignment == nothing ? print(io, v.name) : print(io, v.name, "=", v.assignment)

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


function getFactor(graph,vertex,names)
	inneighbors = inneighbors(graph,vertex)
	if isempty(inneighbors)
		return string("P(",names[v],")")
	else
		nbrs = join(map(x->names[x],inneighbors),",")
		return string("P(",names[v],"|",nbrs,")")
	end
end

function getFactorisation(str)
	(sg, allnodes) = parseGraph(str)
	if is_directed(sg)
		variables = map(x->DiscreteVar([],nothing,x),allnodes)
		#end
		for v in vertices(sg)
					
			end
		end
		factorisation = string("P(",join(allnodes,","),") = FACTORIZED")
		return (factorisation, variables)
	else
		throw(error("Only directed graphs supported as of now."))
	end
end

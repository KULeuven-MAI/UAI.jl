using UAI
using LightGraphs
using Base.Iterators
using GraphPlot
using Combinatorics
idpSym = '⫫'
notIdpSym = "⫫\u20E5"

# independence a ⫫ b holds if 
#P(a,b) = p(a)*p(b) for all values in domA, domB
#Conditional independence a⫫b|z holds if 
# P(a,b|z) = P(a|z)P(b|z) for all values of z

function idp(jpd,dim1,dim2)
	pA = marginalize(jpd)
	pB = marginalize(jpd,mdim=1) 
	return jpd
end


#TODO: generalise to higher dims
function idpValue(jpd,idx)
	setprecision(150)
	println("________")
	println(idx)
	pA = marginalize(jpd)
	pB = marginalize(jpd,mdim=1) 
	pAB = jpd
	margAIdx = idx[1]
	margBIdx = idx[2]
	prod = pA[margAIdx]*pB[margBIdx] 
	println(jpd[idx...])
	println(prod)
	return isapprox(jpd[idx...],prod)
end




"""
Returns all ancestors of a node in a non-cyclic graph.
"""
function getAllAncestors(g::DiGraph, node::Integer)
	@assert is_cyclic(g) == false
	innb = inneighbors(g,node) 
	all = vcat(innb, map(x->getAllAncestors(g,x),innb)...)
	return unique(all)
end

"""
Returns all ancestors of a list of nodes in a non-cyclic graph.
"""
function getAllAncestors(g::DiGraph, nodes::Array{T}) where T<:Integer
	return unique(vcat(map(n->getAllAncestors(g,n),nodes)...))
end

"""
Returns all descendants of a node in a non-cyclic graph.
"""
function getAllDescendants(g::DiGraph, node::Integer)
	@assert is_cyclic(g) == false
	outnb = outneighbors(g,node) 
	all = vcat(outnb, map(x->getAllDescendants(g,x),outnb)...)
	return unique(all)
end

"""
Returns all descendants of a list of nodes in a non-cyclic graph.
"""
function getAllDescendants(g::DiGraph, nodes::Array{T}) where T<:Integer
	return unique(vcat(map(n->getAllDescendants(g,n),nodes)...))
end

"""
Addes bi-directional edges between all given nodes in place.
"""
function marryAll!(g::DiGraph,nodes::Array)
	cartProduct = Iterators.product(nodes,nodes)
	filtered = Iterators.filter(x-> x[1] !== x[2],cartProduct)
	for (src,dst) in filtered
		#println("adding $src, $dst")
		add_edge!(g,src,dst)
	end
end

"""
Returns a new graph with bi-directional edges between all given nodes.
"""
function marryAll(g::DiGraph,nodes::Array)
	newG = deepcopy(g)
	marryAll!(newG,nodes)
	return newG
end


"""
Doubles each directed edge of a directed graph in place.
"""
function disorient!(g)
	for e in edges(g)
		add_edge!(g,dst(e),src(e))
	end
end

"""
Doubles each directed edge of a directed graph.
"""
function disorient(g)
	newG = deepcopy(g)
	disorient!(newG)
	return newG
end

"""
Marries all the direct parents of each node in place.
"""
function moralize!(g::DiGraph)
	for v in vertices(g)
		marryAll!(g,inneighbors(g,v))
	end
end

"""
Marries all the direct parents of each node.
"""
function moralize(g::DiGraph)
	newG = deepcopy(g)
	moralize!(newG)
	return newG
end


# Returns whether the two given vertices are separated when 
# ignoring all edges passing throughthe nodes in the conditioning Set.
function isSeparated(g::AbstractGraph, firstVertex::Int, secondVertex::Int; condSet=[])
	return !has_path(g, firstVertex, secondVertex, exclude_vertices=condSet)
end

function isGraphIdp(g::AbstractGraph, tuple::Tuple)
	fv = tuple[1]
	sv = tuple[2]
	cs = length(tuple) >2 ? collect(tuple[3:end]) : Int[]
	return isGraphIdp(g, fv, sv, condSet=cs)
end

function isGraphIdp(g::Graph, firstVertex::Int, secondVertex::Int;
										condSet::Array{T,1}=Int[],
										nodeNames = collect(1:nv(g))) where T <: Integer
	#In case of a Markov Model, simple separation test.
	return isSeparated(g,firstVertex,secondVertex,condSet=condSet)
end


# Returns a function mapping the old index i of a node in g to the new index where vertices toDelete are removed from g.
function getNewIdx(g::DiGraph,toDelete::Array{T,1}) where T<:Integer
	return i -> findfirst(x->x==i, deleteat!(collect(vertices(g)),toDelete))
end

function isGraphIdp(g::DiGraph, firstVertex::Int, secondVertex::Int;
										condSet::Array{T,1}=Int[],
										nodeNames = collect(1:nv(g))) where T <: Integer
	plot2FileCG(g,nodeNames,joinpath("plots","original.png"))
	# make a copy
	newG = deepcopy(g) 
	startNodes = vcat([firstVertex, secondVertex],condSet...)
	# 1) Get all the ancestors
	ancestors = getAllAncestors(g,startNodes)
	allNodes = unique(vcat(startNodes,ancestors))
	#println(allNodes)
	# remove non relevant nodes from copy newG

	toDelete = [ !(x in allNodes) for x in vertices(g)]
	remainingNodes = deleteat!(deepcopy(nodeNames),toDelete)
	#local newIdx(i) = findfirst(x->x==i, deleteat!(collect(vertices(g)),toDelete))
	newIdx = getNewIdx(g,toDelete)
	#println(remainingNodes)

	numOfRemovals = 0
	for v in vertices(g)
		if !(v in allNodes)
			#println("RMING $v")
			rem_vertex!(newG,v-numOfRemovals)
			numOfRemovals += 1
		end
	end

	plot2FileCG(newG,remainingNodes,joinpath("plots","relevant.png"))

	# 2) Moralize 
	moralize!(newG)

	plot2FileCG(newG,remainingNodes,joinpath("plots","moralized.png"))
	# 3) Disorient
	disorient!(newG)
	plot2FileCG(newG,remainingNodes,joinpath("plots","disoriented.png"))

	# 4) remove the elements in the condition set 
	# 5) first & second are graph-idp if NOT connected
	excluded = map(x->newIdx(x),condSet)
	newFV = newIdx(firstVertex)
	newSV = newIdx(secondVertex)
	#println(excluded)
	return isSeparated(newG, newFV, newSV, condSet=excluded)
end

function isGraphIdp(graphToParse::String, firstName::String, secondName::String; condSet::Array{String,1}=String[])
	(g,n) = parseGraph(graphToParse)
	firstVertex = getNodeId(firstName,n)
	secondVertex = getNodeId(secondName,n)
	idcondSet = isempty(condSet) ? Int[] : map(x->getNodeId(x,n),condSet)
	println(condSet)
	#= println(g) =#
	#= println(firstVertex) =#
	#= println(secondVertex) =#
	#= println(idcondSet) =#
	isGidp = isGraphIdp(g,firstVertex,secondVertex,condSet=idcondSet,nodeNames=n)
	resSymbol = isGidp ? idpSym : notIdpSym
	println("$firstName $resSymbol $secondName | ", join(condSet, ","))
	return isGidp
end

function mapAll(fn::Function, x)
	return Tuple(map(fn, [x...]))
end

function mapAllNames(arr, nodeNames)
	map(x->mapAll(n->nodeNames[n],x), arr)
end

# Generates a list of all 3-tuples that can be queried for a (conditional) independence statement
function getIdpCandidates(g)
	allv = 1:nv(g)
	pairs = collect(combinations(allv,2))
	result = Tuple[]
	for p in pairs
		push!(result,Tuple(p))
		for c in filter(x->!(x in p),allv)
			push!(result,(p[1],p[2],c))
		end
	end
	return result
end

function formatIdpStatement(t)
	startStr = string(t[1],idpSym,t[2])
	if length(t) > 2
		return string(startStr,"|",join(t[3:end],","))
	else
		return startStr
	end
end

function formatDepStatement(t)
	startStr = string(t[1],notIdpSym,t[2])
	if length(t) > 2
		return string(startStr,"|",join(t[3:end],","))
	else
		return startStr
	end
end

function getIdpStatements(graphString::String)
	(g,n)	= parseGraph(graphString)
	Lg = getIdpStatements(g)
	namedLg = mapAllNames(Lg,n)
	formatedLg = map(x->formatIdpStatement(x),namedLg)
	return formatedLg 
end

function getIdpStatements(g)
	 cand = getIdpCandidates(g)
	 f = filter(x->isGraphIdp(g,x),cand)
end

function getDepStatements(g)
	 cand = getIdpCandidates(g)
	 f = filter(x->!isGraphIdp(g,x),cand)
end

function getDepStatements(graphString::String)
	(g,n)	= parseGraph(graphString)
	Lg = getDepStatements(g)
	namedLg = mapAllNames(Lg,n)
	formatedLg = map(x->formatDepStatement(x),namedLg)
	return formatedLg 
end

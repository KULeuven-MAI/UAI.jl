using UAI
using LightGraphs
using Base.Iterators
using GraphPlot
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
		println("adding $src, $dst")
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


function isGraphIdp(g::DiGraph, firstVertex::Int, secondVertex::Int;
										givens::Array{T,1}=Int[],
										nodeNames = collect(1:nv(g))) where T <: Integer
	# make a copy
	newG = deepcopy(g) 
	startNodes = vcat([firstVertex, secondVertex],givens...)
	# 1) Get all the ancestors
	ancestors = getAllAncestors(g,startNodes)
	allNodes = unique(vcat(startNodes,ancestors))
	println(allNodes)
	# remove non relevant nodes from copy newG

	toDelete = [ !(x in allNodes) for x in vertices(g)]
	remainingNodes = deleteat!(deepcopy(nodeNames),toDelete)
	newIdx(i) = findfirst(x->x==i, deleteat!(collect(vertices(g)),toDelete))
	#println(remainingNodes)

	numOfRemovals = 0
	for v in vertices(g)
		if !(v in allNodes)
			#println("RMING $v")
			rem_vertex!(newG,v-numOfRemovals)
			numOfRemovals += 1
		end
	end

	plot2FileCG(newG,remainingNodes,"relevant.png")

	# 2) Moralize 
	moralize!(newG)

	plot2FileCG(newG,remainingNodes,"moralized.png")
	# 3) Disorient
	disorient!(newG)
	plot2FileCG(newG,remainingNodes,"disoriented.png")

	# 4) remove the elements in the condition set 
	# 5) first & second are graph-idp if NOT connected
	excluded = map(x->newIdx(x),givens)
	#println(excluded)
	return !has_path(newG,newIdx(firstVertex), newIdx(secondVertex), exclude_vertices=excluded)
end

function isGraphIdp(graphToParse::String, firstName::String, secondName::String; givens::Array{String,1}=String[])
	(g,n) = parseGraph(graphToParse)
	firstVertex = getNodeId(firstName,n)
	secondVertex = getNodeId(secondName,n)
	idGivens = isempty(givens) ? Int[] : map(x->getNodeId(x,n),givens)
	println(g)
	println(firstVertex)
	println(secondVertex)
	println(idGivens)
	isGidp = isGraphIdp(g,firstVertex,secondVertex,givens=idGivens,nodeNames=n)
	resSymbol = isGidp ? idpSym : notIdpSym
	println("$firstName $resSymbol $secondName | ", join(givens, ","))
	return isGidp
end

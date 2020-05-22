using UAI
using LightGraphs
using Base.Iterators
idpSym = '⫫'

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
Returns all ancestors of a list of nodes in a non-cyclic graph.
"""
function getAllAncestors(g::DiGraph, nodes::Array{T}) where T<:Integer
	return unique(vcat(map(n->getAllAncestors(g,n),nodes)...))
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
Addes bi-directional edges between all given nodes.
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
Doubles each directed edge of a directed graph.
"""
function disorient!(g)
	for e in edges(g)
		add_edge!(g,dst(e),src(e))
	end
end

"""
Marries all the direct parents of each node.
"""
function moralize!(g::DiGraph)
	for v in vertices(g)
		marryAll!(g,inneighbors(g,v))
	end
end


function isGraphIdp(g, firstVertex, secondVertex; givens=[])
	newG = deepcopy(g) 
	startNodes = vcat([firstVertex, secondVertex],givens...)
	ancestors = getAllAncestors(g,startNodes)
	allNodes = unique(vcat(startNodes,ancestors))
	println(allNodes)
	for v in vertices(g)
		if !(v in allNodes)
			rem_vertex!(newG,v)
		end
	end

	moralize!(newG)
	disorient!(newG)

	return !has_path(g,firstVertex, secondVertex, exclude_vertices=givens)
end

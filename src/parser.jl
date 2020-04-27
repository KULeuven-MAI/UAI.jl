using LightGraphs
# For flatten()
using Base.Iterators 

# Parser for converting ascii graphs into computational and visual graphs.
# Supported:
#	- Bayesian Networks (Results in LightGraphs SimpleDiGraph)
#	- Markov Networks (Results in LightGraphs SimpleGraph)
#	- Factor Graphs (Results in either)
# TODO:
#	- Chain Graphs



# Utility functions
function removeSpaces(str)
	return join(split(str))
end

function getNodeId(node, allnodes)
   return findfirst(x->x==node,allnodes)   
end

# Parsing and evaluating single digit addition/multiplication in subscripts.
function parseSubScripts(str)
    #println(str)
    for m in eachmatch(r"(\d\*\d\+\d)",str)
        #println(m.match)
        evaled = eval(Meta.parse(m.match))
        str = replace(str, m.match => evaled)
    end
    #println(str)
    for m in eachmatch(r"(\d\*\d)",str)
        evaled = eval(Meta.parse(m.match))
        str = replace(str, m.match => evaled)
    end
    #println(str)
    for m in eachmatch(r"(\d\+\d)",str)
        #println(m.match)
        evaled = eval(Meta.parse(m.match))
        str = replace(str, m.match => evaled)
    end
    #println(str)
    return str
end

# From the given subParts array create an undirected graph and a nodename list.
function makeUndiGraph(subParts)
    #println(subParts)
	allnodes = sort(unique(collect(flatten(map(x->split(x,'-'),subParts)))))
    #println(allnodes)
    nodesNum = length(allnodes)
    #println(nodesNum)
	sg = SimpleGraph(nodesNum)
    #println(subParts)
    for s in subParts
        nodes = split(s,'-')
        nodesLen = length(nodes)
        #println(nodes)
        for (i,n) in enumerate(nodes)
            #println(i)
            #println(n)
            #Get neighbor to the right
            rightNb = i+1
            if rightNb <= nodesLen
                nodeId = getNodeId(n,allnodes)
                rightNode = nodes[rightNb]
                rightNodeId = getNodeId(rightNode,allnodes)
                if !(has_edge(sg,nodeId,rightNodeId))
                    #println("Adding $nodeId and $rightNodeId")
                    add_edge!(sg,nodeId,rightNodeId)
                end
            end
        end
    end
    return (sg,allnodes)
end


# From the given subParts array create a directed graph and a nodename list.
# TODO testing
function makeDiGraph(subParts)
	regex = r"<|>"
	toRight = ">"
	toLeft = "<"
	allnodes = unique(collect(flatten(map(x->split(x,regex),subParts))))
    nodesNum = length(allnodes)
    #println(nodesNum)
	sg = SimpleDiGraph(nodesNum)
	#println(allnodes)
	totalNodes = length(allnodes)
	for p in subParts
		nodes = split(p,regex) 
		directions = collect(eachmatch(regex,p))
        nodesLen = length(nodes)
        #println(nodes)
		dirIdx = 1
        for (i,n) in enumerate(nodes)
            #println(i)
            #println(n)
            #Get neighbor to the right
            rightNb = i+1
            if rightNb <= nodesLen
                nodeId = getNodeId(n,allnodes)
                rightNode = nodes[rightNb]
                rightNodeId = getNodeId(rightNode,allnodes)
				if directions[dirIdx].match == toRight
					if !(has_edge(sg,nodeId,rightNodeId))
						#println("Adding $nodeId > $rightNodeId")
						add_edge!(sg,nodeId,rightNodeId)
					end
				else #left case
					if !(has_edge(sg,rightNodeId,nodeId))
						#println("Adding $nodeId < $rightNodeId")
						add_edge!(sg,rightNodeId,nodeId)
					end
				end
				dirIdx += 1
            end
        end
	end
    return (sg,allnodes)
end

# Function parses the given string as a graph depending on the type of string
# Returns a tuple of type (Graph,[NodeNameStr])
# TODO: add a strict ordering (e.g. alphabetically)
function parseGraph(str)
	if str[end] == ';'
		str = str[1:end-1]
	end
	str = removeSpaces(str)
	str = parseSubScripts(str)
	subParts = split(str, ';')
	undi = false
	di = false
	if in('-', str)
		undi = true	
		return makeUndiGraph(subParts)
	end
	if in('>',str) | in('<',str)
		di = true
		return makeDiGraph(subParts)
	end
	# TODO support for Chain Graphs with both types of edges
end


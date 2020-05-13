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


directedRegex = r"<|>"

#TODO finish
function getChainComponents(subParts)
	nodeNames = getDiNodeNames(subParts)
	println("Directed:")	
	println(nodeNames)
	(g,names) = makeUndiGraph(nodeNames)
	println(names)
	nameDict = Dict(zip(1:nv(g),names))
	for connVec in connected_components(g)  
		#Chain components here:
		println(map(x->nameDict[x],connVec))
		println(connVec)
	end
	println("UnDirected:")	
	undiNodeNames = getUndiNodeNames(subParts)
	# dnames are the same but order can be different, account for that when merging the graphs.	
	(dg, dnames) = makeDiGraph(undiNodeNames)
	# Make edges in g double directed?
	for e in edges(g)
		add_edge!(dg, src(e),dst(e))
		add_edge!(dg, dst(e),src(e))
	end
	# for debugging
	draw(PNG("testParser.png", 16cm, 16cm), gplot(dg))
	return (dg,dnames) 
end

function getDiNodeNames(subParts)
	nodeNames = unique(collect(flatten(map(x->split(x,directedRegex),subParts))))
	return nodeNames
end

function getUndiNodeNames(subParts)
	nodeNames = unique(collect(flatten(map(x->split(x,'-'),subParts))))
	return nodeNames
end

# From the given subParts array create a directed graph and a nodename list.
# TODO testing
function makeDiGraph(subParts)
	toRight = ">"
	toLeft = "<"
	allnodes = sort(getDiNodeNames(subParts))
    nodesNum = length(allnodes)
    #println(nodesNum)
	sg = SimpleDiGraph(nodesNum)
	#println(allnodes)
	totalNodes = length(allnodes)
	for p in subParts
		nodes = split(p,directedRegex) 
		directions = collect(eachmatch(directedRegex,p))
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
"""
Function parses the given string as a graph depending on the type of string
Returns a tuple of type (Graph,[NodeNameStr])
"""
function parseGraph(str)
	if str[end] == ';'
		str = str[1:end-1]
	end
	str = removeSpaces(str)
	str = parseSubScripts(str)
	subParts = split(str, ';')
	graphMakingFunction = getGraphStyleFunction(str)
	return graphMakingFunction(subParts)
	# TODO support for Chain Graphs with both types of edges
end

function makeChainGraph(subParts)
	return getChainComponents(subParts)	
end

function getGraphStyleFunction(str)
	chainGraphFunc = makeChainGraph
	discriminators = Dict(['<'=>makeDiGraph,'>'=>makeDiGraph,'-'=>makeUndiGraph])
	flags = filter(x->in(x[1],str)==true,discriminators)
	valLen = length(unique(values(flags)))
	if valLen == 2
		return chainGraphFunc	
	else
		return collect(flags)[1][2]
	end
end


# Converts the simple 'given' ('a|b') notation into simple graph notation.
function graphify(s)
	println(s)
	if '|' in s 
		return replace(s, '|' => '<')
	else
		return s 
	end
end

# Converts multiple 'given' notation ("a|b,c,d") into a subpart of simple graph notation
function splitUp(s)
	println("splitting $s")
	sp = split(s,'|')		
	conditionSet = split(sp[2],',')	
	return map(x-> string(sp[1],'<',x), conditionSet)
end

# Parse a factorisation of the form p(a|b,c)p(x|a)p(x)
# into a digraph
function parseFactorization(str)
	str = removeSpaces(str)		
	str = join(split(str,'p'))
	splits = split(str,')')
	splits = map(x->x[2:end],splits[1:end-1])
	#println(collect(splits))
	mapped = map(s-> ',' in s ? splitUp(s) : graphify(s),splits)
	subParts = vcat(mapped...)
	#println(collect(subParts))
	return makeDiGraph(subParts) 
end


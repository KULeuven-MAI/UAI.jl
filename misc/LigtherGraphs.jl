using LightGraphs
using GraphPlot
using Base.Iterators
using Compose

# TODO:
# Extract into seperate package.
# Add testing
# Extend


tst1 = "a>b;b<a"
tst2 = "a>b>c"
col = "a>b<c"
cola = "a>b<c;c<e"
colb = "z<a;a>b<c;c"
spaceCola= "a > b < c ; c < e"


function removeSpaces(str)
	return join(split(str))
end

function parseSyntax(str)
	str = removeSpaces(str)	
	undir = false
	dir = false
	if in('-', str)
		undir = true	
	end
	if in('>',str) | in('<',str)
		dir = true
	end
	subParts = split(str, ';')
	allnodes = unique(collect(flatten(map(x->split(x,r"<|>"),subParts))))
	println(allnodes)
	totalNodes = length(allnodes)
	if dir
		sg = SimpleDiGraph(totalNodes)
		println(sg)
		gplot(sg)
		draw(SVG("test.svg", 16cm, 16cm), gplot(sg))
	end
	for p in subParts
		pairs = makePairs(p)
		# Sliding window to iterate over each pair?
		#println(p)
	end
end


function makePairs(all)
	a = split(all,r"<|>")
end

println(removeSpaces(spaceCola))
parseSyntax(colb)

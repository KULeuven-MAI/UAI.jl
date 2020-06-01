using GraphPlot
using IterTools
using Compose
using Colors
using UnicodeFun
using Cairo
using UAI
using LightGraphs

# Visualisation code
function getColor(nodeName)
    if startswith(nodeName,"f")
        return 2
    end
    return 1
end

# Returns a dictionary to convert the Simple Graph names to numbers.
function getNames2Num()
    return Dict(zip(["a","b","c","d","x"],[0,1,2,3,3]))
end

# Returns a dictionary for mapping numbers to the Simple Graph names.
function getNum2Names()
   return Dict(value => key for (key, value) in getNames2Num()[1:end-1])
end

# Converts
function numToNames(str)
    num2nam = getNum2Names()
    k = keys(getNum2Names())
    for i in k
        for m in eachmatch(Regex("n$i"),str)
            str = replace(str, m.match => num2nam[i])
        end
    end
    return str
end

# Returns the (subscript) number of a node string.
function getNum(str)
    names = getNames2Num()
    if str in keys(names)
        return names[str]
    else
        r = match(r"\d+",str)
        return parse(Int,r.match)
    end
end

function getX(nodeName)
    step = 40
    halfstep =step/2
    if startswith(nodeName, "x")
        n = getNum(nodeName)
        return n*step
    end
    if startswith(nodeName, "h") | (nodeName in keys(getNames2Num()))
        n = getNum(nodeName)
        return n*step
    end
    if startswith(nodeName, "f")
        n = getNum(nodeName)
        if isodd(n)
            return n/2 * step
        else
            return n/2*step
        end
    end
end

function getY(nodeName)
    step = 10
    halfstep=step/2
    if startswith(nodeName, "x")
        return step
    end
    if startswith(nodeName, "h") | (nodeName in keys(getNames2Num()))
        return 0
    end
    if startswith(nodeName, "f")
        n = getNum(nodeName)
        if isodd(n)
            return 0
        else
            return halfstep
        end
    end
end

# Surrounds a string with dollars for LaTeX rendering in Compose.
function latexHug(str)
    #return string("\$",str,"\$")
    return to_latex(str)
end

#stripChar = (s, r) -> replace(s, Regex("[$r]") => "")

# Plots factor graphs with factors starting with letter "f"
#
function plotFG2File(sg, nodes, filename; sizes = [1, 0.6], edgelabel=repeat([""],ne(sg)))
    nodecolor = [colorant"lightseagreen", colorant"orange"]
    membership = map(x->getColor(x),nodes)
    locs_x = convert(Vector{Float64},map(x->getX(x),nodes))
    locs_y = convert(Vector{Float64},map(x->getY(x),nodes))
    nodefillc = nodecolor[membership]
    nodesize = sizes[membership]
    #println(length(locs_x))
    #println(locs_x)
    #println(typeof(locs_x))
    #println(length(locs_y))
    #println(locs_y)
    #println(typeof(locs_y))
    #println(length(nodefillc))
    #println(length(nodes))
    #println(length(nodesize))
    #tweakedLabels = map(x-> stripChar(x, "}{"),nodes)
    latexedLabels = map(x->latexHug(x),nodes)
    plot = gplot(sg,locs_x,locs_y,nodefillc=nodefillc,nodelabel=latexedLabels,nodesize=nodesize,edgelabel=edgelabel)
    #LaTeX can't handle SVGs ;_;
    draw(PNG(filename, 18cm, 9cm), plot)
end


function plot2File(sg, nodes, filename; sizes = [1, 0.6], edgelabel=repeat([""],ne(sg)))
    nodecolor = [colorant"lightseagreen", colorant"orange"]
	# TODO: generic way for passing params.
    #membership = map(x->getColor(x),nodes)
    #locs_x = convert(Vector{Float64},map(x->getX(x),nodes))
    #locs_y = convert(Vector{Float64},map(x->getY(x),nodes))
    #nodefillc = nodecolor[membership]
    #nodesize = sizes[membership]
    plot = gplot(sg,nodelabel=nodes)
    #LaTeX can't handle SVGs ;_;
    draw(PNG(filename, 18cm, 9cm), plot)
	#TODO: auto plotting in Jupyter notebook:
	#Like:
	#https://github.com/JuliaGraphics/Luxor.jl/blob/4f1166407042e307f2c0df701fcdca9777aa393d/src/drawings.jl#L78
end

function drawFullGraph(filename,n; edgelabel=[])
    str0 = "f_{0}-h_{0}-f_{1}-h_{1};"
    str1 = join(map(x->replace("h_{i} - f_{2*i} - x_{i};", r"i" => string(x)), 1:n))
    str2 = join(map(x->replace("h_{i} - f_{2*i+1} - h_{i+1};", r"i" => string(x)), 1:(n-1)))
    str = string(str0,str1,str2[1:end-1]) #omit last ;
    (sg,nodes) = parseGraph(str)
    if isempty(edgelabel)
        edgelabel=repeat([""],ne(sg))
    end
    #println(str)
    #println(nodes)
    plotFG2File(sg, nodes, filename, sizes=[1.3, 0.9], edgelabel=edgelabel)
end


function drawLinearGraph(filename)
    n = 3
    str0 = "f_{0}-h_{0}-f_{1}-h_{1};"
    str1 = join(map(x->replace("h_{i} - f_{2*i} - x_{i};", r"i" => string(x)), [n]))
    str2 = join(map(x->replace("h_{i} - f_{2*i+1} - h_{i+1};", r"i" => string(x)), 1:(n-1)))
    str = string(str0,str1,str2[1:end-1]) #omit last ;
    (sg,nodes) = parseGraph(str)
    plotFG2File(sg, nodes, filename)
end

function drawSimpleLinear(filename)
    n = 3
    str = "f_0-a-f_1-b;b-f_3-c;c-f_5-d;d-f_6-x"
    (sg,nodes) = parseGraph(str)
    plotFG2File(sg, nodes, filename)
end

function SP1Labels()
    lab  = collect(1:21)
    lab[1] = 1
    lab[7] = 2
    lab[11] = 3
    lab[15] = 4
    lab[19] = 5
    lab[3] = 6
    lab[4] = 7
    lab[6] = 8
    lab[10] = 9
    lab[14] = 10
    lab[18] = 11
    lab[2] = 12
    lab[21] = 13
    lab[20] = 14
    lab[17] = 15
    lab[16] = 16
    lab[5] = 17
    lab[13] = 18
    lab[12] = 19
    lab[8] = 20
    lab[9] = 21
    return map(x->string(x),lab)
end

function SP2Labels()
    lab  = map(x -> "",1:21)
    lab[7] = "4"
    lab[6] = "3"
    lab[8] = "2"
    lab[9] = "1"
    lab[12] = "5"
    lab[13] = "6"
    lab[16] = "7"
    lab[17] = "8"
    lab[20] = "9"
    lab[21] = "10"
    lab[2] = "11"
    lab[3] = "12"
    return lab
end

function drawGraph(whichOne,filename)
    if whichOne == "full3"
        drawFullGraph(filename,3,edgelabel=[])
    elseif whichOne == "linear"
        drawLinearGraph(filename)
    elseif whichOne == "simpleLinear"
        drawSimpleLinear(filename)
    elseif whichOne == "full"
        drawFullGraph(filename,5,edgelabel=[])
    elseif whichOne == "SP1"
        drawFullGraph(filename,5,edgelabel=SP1Labels())
    elseif whichOne == "SP2"
        drawFullGraph(filename,5,edgelabel=SP2Labels())
    end
end

function drawFromStr(str, filename)
    (sg,nodes) = parseGraph(str)
    #println(str)
    #println(nodes)
	#println("test1")
	for e in collect(edges(sg))
		#println(e)
	end
	#println("test2")
    plot2File(sg, nodes, filename)
end

function plot2FileCG(graph, nodeNames, filename)
	plot = gplot(graph,nodelabel=nodeNames,chainGraph=true,arrowlengthfrac=0.2)
	draw(PNG(filename, 18cm, 9cm), plot)
end

using UAI
using LightGraphs
using MetaGraphs 
using Colors
using GraphRecipes
using Plots

function hasParents(g,node::Int)
	length(inneighbors(g,node)) != 0 
end

function getOrphans(g)
	return filter(v->!hasParents(g,v),vertices(g))
end

# TODO: refactor into smaller functions
"""
	getFactorGraph(str::String)::MetaGraph

Reads a graph-string and returns a factor-graph.
"""
function getFactorGraph(str::String)::MetaGraph
	sg, nodes = parseGraph(str)
	orphans = getOrphans(sg)
	fg = MetaGraph(sg)
	for v in vertices(sg) 
		set_prop!(fg, v, :name, string("____",nodes[v],"____"))
		set_prop!(fg, v, :type, :variable)
		set_prop!(fg, v, :nodeshape, :circle)
		set_prop!(fg, v, :nodecolor, :green)
		#set_prop!(fg, v, :nodesize, 1.8)
	end
	factorCount = 1
	for v in orphans 
		add_vertex!(fg)
		set_prop!(fg, nv(fg), :name, "f_$factorCount")
		set_prop!(fg, nv(fg), :type, :factor)
		set_prop!(fg, nv(fg), :nodeshape, :rect)
		set_prop!(fg, nv(fg), :nodecolor, :white)
		#set_prop!(fg, nv(fg), :nodesize, 1.5)
		add_edge!(fg, nv(fg), v)
		factorCount += 1
	end
	for v in vertices(sg)
		if v ∉ orphans 
			inn = inneighbors(sg,v)
			add_vertex!(fg)
			set_prop!(fg, nv(fg), :name, "f_$factorCount")
			set_prop!(fg, nv(fg), :type, :factor)
			set_prop!(fg, nv(fg), :nodeshape, :rect)
			set_prop!(fg, nv(fg), :nodecolor, :white)
			for nb in inn
				rem_edge!(fg,nb,v)
				add_edge!(fg,nb,nv(fg))
			end
			add_edge!(fg,v,nv(fg))
			factorCount +=1
		end
	end
	return fg
end

function getFactorDiGraph(str::String)
	#TODO
	@assert false
end

"""
	plotFG(g::MetaGraph)

Plots the given MetaGraph as a Factor Graph. 
"""
function plotFG(g::MetaGraph)
	#TODO: refactor to visualizer?
	graphplot(g, curves = false, 
		   names = [get_prop(g, v, :name) for v in vertices(g)],
		   nodeshape = [get_prop(g, v, :nodeshape) for v in vertices(g)],
		   nodecolor = [get_prop(g, v, :nodecolor) for v in vertices(g)])
end

f = getFactorGraph("a>c<b;c>d"); plotFG(f)

# Possible bug in GraphRecipes, only scalar supported for nodesize.
#function plotFG(g)
	#graphplot(g, curves = false, 
		   #nodeshape = [get_prop(g, v, :nodeshape) for v in vertices(g)],
		   #nodesize = [get_prop(g, v, :nodesize) for v in vertices(g)],
		   #nodecolor = [get_prop(g, v, :nodecolor) for v in vertices(g)])
#end

# using GraphPlot
#= function plotMG(mg::MetaGraph, ilename) =#
#=            plot = gplot(sg) =#
#=            draw(PNG(filename, 18cm, 9cm), plot) =#
#= end =#

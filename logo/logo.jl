using GraphRecipes
using Plots
using UAI

g,n = parseGraph("U>A>I");
println(g)
println(n)

p = graphplot(g,
          x=[0.9,1.8,0], y=[0,0,0],
          nodeshape=:circle, 
	  nodesize=0.7,
	  nodestrokewidth=1.4,
          axis_buffer=0.6,
          curves=false,
	  curvature_scalar=0, # bug curvature scalar
          color=:black,
	  arrow=:simple,
	  #arrow=:head,
          nodecolor=[colorant"#389826",colorant"#CB3C33",colorant"#9558B2"],
          linewidth=8)

savefig(p,"baselogo.png")

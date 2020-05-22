using UAI
using LightGraphs
using Test
using Random

#= using SymEngine =#
#= @vars x y =#
#= tab= [0.2 0.1 0.3; 0.133 x y] =#
#= solvedTab = [0.2 0.1 0.3; 133/1000 66/1000 0.2] =#
#=  =#
#= @testset "Testing independence of 2x3 jpd" begin =#
#= 	setprecision(150) =#
#= 	domA = 1:2 =#
#= 	domB = 1:3 =#
#= 	for a in domA  =#
#= 		for b in domB  =#
#= 			@test idpValue(solvedTab,[a,b]) =#
#= 		end =#
#= 	end =#
#= end =#

@testset "disorient! (make undirected)" begin
	g = SimpleDiGraph([ 0 0 0 ; 1 0 0 ; 1 0 0 ])
	disorient!(g)
	@test size(collect(edges(g))) == (4,)
	add_edge!(g,2,3)
	disorient!(g)
	@test size(collect(edges(g))) == (6,)
end

@testset "getAllAncestors" begin
	g,n = parseGraph("1<2<3;2<4<5;5<6")
	allAnc = collect(2:6)
	@test all([i in getAllAncestors(g,1) for i in allAnc])
	@test all([i in getAllAncestors(g,2) for i in allAnc[2:end]])
	@test all([i in getAllAncestors(g,[1,3,4]) for i in allAnc])
end

@testset "d-seperation MIT example" begin
# from http://web.mit.edu/jmn/www/6.034/d-separation.pdf 
	(originalGraph,names) = parseGraph("a>c<b;d<c>e;d>f>g")	
	@test isGraphIdp(originalGraph,1,2,givens=[2]) == true
	@test isGraphIdp(originalGraph,1,2,givens=[3]) == true
end

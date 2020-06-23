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
	mitGraphStr = "a>c<b; d<c>e ; d>f>g"
	(originalGraph,names) = parseGraph(mitGraphStr)	
	@test isGraphIdp(originalGraph,1,2,condSet=[2]) == true
	@test isGraphIdp(originalGraph,1,2,condSet=[3]) == false 
	@test (@gidp mitGraphStr a b|d,f) == false # 1 
	@test (@gidp mitGraphStr a b|a) == true # 2 
	@test (@gidp mitGraphStr b a|b) == true # 2'
	@test (@gidp mitGraphStr a b) == true  # 2''
	@test (@gidp mitGraphStr a b|c) == false# 3  
	@test (@gidp mitGraphStr d e|c) == true # 4  
	@test (@gidp mitGraphStr d e) == false # 5 
	@test (@gidp mitGraphStr d e|a,b) == false # 6
	# first part of 7 is 4
	@test (@gidp mitGraphStr d g|c) == false# 7'
end


@testset "Exc 3.2.2 Markov Net" begin
	markovNet = "a-b-d-a; a-c"
	(markovGraph,names) = parseGraph(markovNet)	
	@test (@gidp markovNet a b|d) == false
	@test isGraphIdp(markovGraph,1,2,condSet=[4]) == false # non-macro test.
	@test (@gidp markovNet b a|d) == false # commutative test
	@test (@gidp markovNet a b|c) == false
	@test (@gidp markovNet b a|c) == false # commutative test
	@test (@gidp markovNet a d|b) == false
	@test (@gidp markovNet a d|c) == false
	@test (@gidp markovNet a c|b) == false
	@test (@gidp markovNet a c|d) == false
	@test (@gidp markovNet c d|a) == true
	@test isGraphIdp(markovGraph,3,4,condSet=[1]) == true # non-macro test.
	@test (@gidp markovNet c b|a) == true
end


@testset "Example 4.4. BRML" begin
	BN = "t1>y2<y1; y2<t2; y1<t1;"
	# TODO: verify.
	# barber says:
	# L_G = {y1 ⊥t2|t1, t2 ⊥t1}
	# BUT i find:
#= b = getIdpStatements(BN) =#
#  "t1⫫t2" OK 
#  "t1⫫t2|y1" NOK  since y2 blocks all paths
#  "t2⫫y1" NOK Yet all paths blocked  by y2 again
#=  "t2⫫y1|t1 OK =# 
# Checked with both moralizing and def 3.4
end


@testset "Imap and Dmap Exc 3.2.1" begin
	lp = [(@isIdp c a) (@isIdp a d) (@isIdp c b|a)]
	graphstring = "c>a>b<d>a"
	@test isIMap(graphstring,lp) == false
	@test isDMap(graphstring,lp) == false
	@test isPerfectMap(graphstring,lp) == false
end

@testset "Imap and Dmap Exc 3.2.2" begin
	lp = [(@isIdp c d|a) (@isIdp c b|a)]
	graphstring = "c-a-b-d-a"
	@test isIMap(graphstring,lp) == true 
	@test isDMap(graphstring,lp) == true 
	@test isPerfectMap(graphstring,lp) == true 
end

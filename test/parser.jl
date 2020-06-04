using UAI
using Test
using LightGraphs


# Examples of directed graphs/BN
tst1 = "a>b;b<a"
tst2 = "a>b>c"

colb = "z<a;a>b<c;c"
strA = "BP>t_1>t_2<BP"
strB = "BP>t_1>t_2<BP; t_2 > m_2; m_1;"
strC = "BP>t_1>t_2<BP; t_1 > m_2; m_1;"

# Examples of undirected graphs/Markov Networks
n=3
fgs = string("f0 - h_0 - f_01 - h_i;","h_i - f_i - h_i+1; h_i - f_2*i - x_i;")
str0 = "f_{0}-h_{0}-f_{1}-h_{1};"
str1 = join(map(x->replace("h_{i} - f_{2*i} - x_{i};", r"i" => string(x)), 1:n))
str2 = join(map(x->replace("h_{i} - f_{2*i+1} - h_{i+1};", r"i" => string(x)), 1:(n-1)))
mystr = string(str0,str1,str2)
str = "f_0-a-f_1-b;b-f_3-c;c-f_5-d;d-f_6-x"

# Examples of chain graphs

#parseSubScripts


# parseSubScripts(str)
@testset "Test subscript parsing" begin
	#TODO
end

collider = "a>c<b"
colliderGraph = SimpleDiGraph(3)
add_edge!(colliderGraph,1,3)
add_edge!(colliderGraph,2,3)

collider2 = "e>a>c<b<d"
collider3 = "e>a>c; c<b<d"
fork = "a<f>b"
forkGraph = SimpleDiGraph([0 0 0 ; 0 0 0 ; 1 1 0])
chain = "a>b>c"
chainGraph = SimpleDiGraph([0 1 0 ; 0 0 1; 0 0 0])
chain2 = "a<b<c"
chain2Graph = SimpleDiGraph([0 0 0 ; 1 0 0; 0 1 0])

cola = "a>b<c;c<e"
colaGraph = SimpleDiGraph([0 1 0 0; 0 0 0 0; 0 1 0 0 ; 0 0 1 0 ])
spaceCola= "a > b < c ; c < e"
spaceColaGraph = SimpleDiGraph([0 1 0 0; 0 0 0 0; 0 1 0 0 ; 0 0 1 0 ])

@testset "Testing directed graph parsing" begin
	testset = ["collider" "chain" "chain2" "fork" "cola" "spaceCola"]
	for t in testset
		(sg,nodes) = parseGraph(eval(Symbol(t)))
		@test eval(Symbol(string(t,"Graph"))) == sg
	end
	#= (sg,nodes) = parseGraph(collider) =#
	#= @test typeof(sg) == SimpleDiGraph{Int64}  =#
	#= @test nodes == ["a","b","c"] =#
	#= @test colliderGraph == sg =#
	#= for e in edges(colG) =#
	#=    @test has_edge(g,e) =#
	#= end =#
end

circle3 = "a-b-c-a"
circle3Graph = SimpleGraph([0 1 1; 1 0 1; 1 1 0])
circle4 = "a-b-c-d-a"
circle4Graph = SimpleGraph([0 1 0 1; 1 0 1 0; 0 1 0 1; 1 0 1 0])

@testset "Testing undirected graph parsing" begin
	testset = ["circle3" "circle4"]
	for t in testset
		(sg,nodes) = parseGraph(eval(Symbol(t)))
		@test eval(Symbol(string(t,"Graph"))) == sg
	end
end

cg1 = "a>b-c"
cg1Graph = SimpleDiGraph([0 1 0; 0 0 1; 0 1 0])
cg2 = "a>b; c-b"
cg2Graph = SimpleDiGraph([0 1 0; 0 0 1; 0 1 0])
cg3 = "c-e-a>b; c-b"
cg3Graph = SimpleDiGraph([0 1 0 1; 0 0 1 0; 0 1 0 1; 1 0 1 0])
cg4 = "a_1-a_2-a_3-a_4-a_1;
a_1 > b_1;
a_2 > b_2; 
a_3 > b_3;
a_4 > b_4;"
cg4Graph = SimpleDiGraph([0 1 0 1 1 0 0 0; 
						  1 0 1 0 0 1 0 0;
						  0 1 0 1 0 0 1 0;
						  1 0 1 0 0 0 0 1;
						  0 0 0 0 0 0 0 0;
						  0 0 0 0 0 0 0 0;
						  0 0 0 0 0 0 0 0;
						  0 0 0 0 0 0 0 0])

@testset "Testing chain graph parsing" begin
	testset = ["cg1" "cg2" "cg3" "cg4"]
	for t in testset
		(sg,nodes) = parseGraph(eval(Symbol(t)))
		@test eval(Symbol(string(t,"Graph"))) == sg
	end
end

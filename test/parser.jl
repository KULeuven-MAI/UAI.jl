using UAI
using Test


# Examples of directed graphs/BN
tst1 = "a>b;b<a"
tst2 = "a>b>c"

collider = "a>c<b"
colG = SimpleDiGraph(3)
add_edge!(colG,1,2)
add_edge!(colG,3,2)



collider2 = "e>a>c<b<d"
collider3 = "e>a>c; c<b<d"
fork = "a<f>b"
chain = "a>b>c"
chain2 = "a<b<c"

cola = "a>b<c;c<e"
colb = "z<a;a>b<c;c"
spaceCola= "a > b < c ; c < e"
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


parseSubScripts


# parseSubScripts(str)
@testset "Test subscript parsing" begin
end

@testset "Testing undirected graph parsing" begin
	#parseGraph("")
end

@testset "Testing directed graph parsing" begin
	(sg,nodes) = parseGraph(collider)
	@test typeof(sg) == SimpleDiGraph{Int64} 
	@test sort(nodes) == ["a","b","c"]
	for e in edges(colG)
	   @test has_edge(g,e)
	end
end

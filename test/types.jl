using UAI
using Test
using Random

chain = "a>b>c"
chain2 = "a<b<c"
collider = "a>c<b"
fork = "a<f>b"

@testset "Bayesian Network Factorization" begin
	@test string(getFactorization(chain)[1]) == "p(a)p(b|a)p(c|b)"
	@test string(getFactorization(chain2)[1]) == "p(a|b)p(b|c)p(c)"
	@test string(getFactorization(collider)[1]) == "p(a)p(b)p(c|a,b)"
	@test string(getFactorization(fork)[1]) == "p(a|f)p(b|f)p(f)"
	@test getGraph(getFactorization(chain)[1]) == parseGraph(chain) 
	@test getGraph(getFactorization(fork)[1]) == parseGraph(fork) 
	@test getGraph(getFactorization(collider)[1]) == parseGraph(collider) 
	@test getGraph(getFactorization(fork)[1]) == parseGraph(fork) 
end

twoClique = "a-b-c-d"
twoCliqueFactors = ["ϕ(a,b)","ϕ(b,c)","ϕ(c,d)"]
threeClique = "1-2-3-1; 2-3-4-2; 6-4-5-6; 5-6-7-5;"
threeCliqueFactors = ["ϕ(1,2,3)","ϕ(2,3,4)","ϕ(4,5,6)","ϕ(5,6,7)"]

@testset "Markov Network Factorization" begin
	factoredThreeC = string(getFactorization(threeClique))
	factoredTwoC = string(getFactorization(twoClique))
	@test all(x->occursin(x,factoredThreeC),threeCliqueFactors)
	@test all(x->occursin(x,factoredTwoC),twoCliqueFactors)
end

@testset "hasFactor and query macro" begin
	str = "c<a>d;d<b;f<d>g<e"
	jpd = JPD(str)
	@test hasFactor(jpd,@q a)
	@test hasFactor(jpd,@q b)
	@test hasFactor(jpd,@q e)
	@test hasFactor(jpd,@q c|a)
	@test hasFactor(jpd,@q d|a,b)
	@test hasFactor(jpd,@q f|d)
	@test hasFactor(jpd,@q g|d,e)
end

using UAI
using Random

chain = "a>b>c"
chain2 = "a<b<c"
collider = "a>c<b"
fork = "a<f>b"

@testset "factorisation" begin
	@test string(getFactorization(chain)[1]) == "P(a)P(b|a)P(c|b)"
	@test string(getFactorization(chain2)[1]) == "P(a|b)P(b|c)P(c)"
	@test string(getFactorization(collider)[1]) == "P(a)P(c|a,b)P(b)"
	@test string(getFactorization(fork)[1]) == "P(a|f)P(f)P(b|f)"
	@test getGraph(getFactorization(chain)[1]) == parseGraph(chain) 
	@test getGraph(getFactorization(chain2)[1]) == parseGraph(fork) 
	@test getGraph(getFactorization(collider)[1]) == parseGraph(collider) 
	@test getGraph(getFactorization(fork)[1]) == parseGraph(fork) 
end

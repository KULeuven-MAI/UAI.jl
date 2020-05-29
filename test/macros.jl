using UAI
using Test

marginal = @query b
marginalP = ([:b],[])
joined = @query b,a
joinedP = ([:b,:a],[])
cond1 = @query a|b
cond1P = ([:a],[:b])
cond2 = @query b|c,a
cond2P = ([:b],[:c,:a])
cond3 = @query b,a|c,a
cond3P = ([:b,:a],[:c,:a])
cond4 = @query b,a|c
cond4P = ([:b,:a],[:c])

@testset "Testing query parser" begin
	@test marginal == marginalP
	@test joined == joinedP
	@test cond1[1] == cond1P[1]
	@test cond2[1] == cond2P[1]
	@test cond3 == cond3P
	@test cond4 == cond4P
end

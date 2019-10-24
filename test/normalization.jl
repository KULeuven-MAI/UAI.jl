using UAI
using Random
# Define testing variables.
# strictPos is strictly positive.
strictPos = [[1 2 3] ; [0.1 000.1 0.00000000001]]
# hasZero contains a zero
hasZero = vcat([1.0e-15 1.0e-20 0],strictPos)
# hasNeg cotains a negative number
hasNeg = vcat([1.0e-15 1.0e-20 -0.0000001],strictPos)
# notNorm cotains a both 
notNorm = vcat([1.0e-15 0 -0.0000001],strictPos)
# n is nicely normalized
n = [[0.2 0.3 0.1] ; [0.2 0.05 0.15]]

# Exc 1.1 a)
toNormA = [ [0.1 0.5 0.3]; [0.5 0.2 0.3]]
normA = [ [0.053 0.263 0.158]; [0.263 0.105 0.158] ] 
toNormB = cat([ [0.3 0.5]; [0.2 0.3] ], [ [0.2 0.1]; [0.2 0.1] ], dims=3)
# Exc 1.1 b)
normB = cat([[ 0.158 0.263]; [0.105 0.158] ], [ [ 0.105 0.053 ]; [ 0.105 0.053 ] ], dims=3) 
# Exc 3.3 a)
toCondNormC = toNormA
condNormC = [ [0.167  0.714  0.5] ; [0.833 0.286  0.5] ]
# Exc 3.3 b)
toCondNormD = toNormB
condNormD = cat([ [0.231  0.385]; [0.154  0.231] ], [ [0.333 0.167]; [ 0.333 0.167] ], dims=3)
# Reshapes necessary to fit the actual (singleton) dimensions
margNormA = reshape([0.316,0.368,0.316],(1,3))
margNormB = reshape([ 0.421 0.158; 0.263 0.158 ], (2, 1, 2))
condA = condA = reshape([0.168  0.715  0.5;  0.832  0.285  0.5],(2,3))
condB =	cat([[0.375  0.625]; [0.399  0.601]], [[0.665  0.335]; [0.665  0.335]], dims=3)

@testset "Testing conditional probablity from Joint" begin
	@test_throws ArgumentError conditional(normA, 1, cset=[1,2])
	@test isapprox(condA, conditional(normA, 1, cset=[2]), atol=1e-3)
	@test_throws ArgumentError conditional(normB, 1, cset=[2])
	# A weird bug makes this test fail
	# https://discourse.julialang.org/t/bug-isapprox-different-results-elementwise-julia-1-1-0/30271?u=dcastel
	#@test isapprox(condB, conditional(normB, 2, cset=[1,3]), atol=1e-3)
end

@testset "Testing marginalisation" begin
	@test isapprox(margNormA, marginal(normA,[2]), atol=1e-3)
	@test isapprox(margNormA, marginalize(normA, mdim=1), atol=1e-3)
	@test isapprox(margNormB, marginal(normB,[1,3]), atol=1e-3)
	@test isapprox(margNormB, marginalize(normB, mdim=2), atol=1e-3)
end

@testset "Testing the conditional normalization" begin
	@test_throws ArgumentError condNormalize(toCondNormC, cdim=4)
	@test_throws ArgumentError condNormalize(toCondNormC, cdim=-1)
	@test !isCondNorm(strictPos)
	@test !isCondNorm(notNorm)
	@test isCondNorm(condNormC, cdim=2)
	@test isCondNorm(condNormC)
	# TODO: improve handling of approx atol
	#= @test isCondNorm(condNormD, cdim=3)  =#
	#= @test isCondNorm(condNormD)  =#
	@test isapprox(condNormC, condNormalize(toCondNormC, cdim=2), atol=1e-3) 
	@test isapprox(condNormC, condNormalize(toCondNormC), atol=1e-3) 
	@test isapprox(condNormD, condNormalize(toCondNormD, cdim=3), atol=1e-3) 
	@test isapprox(condNormD, condNormalize(toCondNormD), atol=1e-3) 
end

@testset "Testing the slicing function" begin
	@test_throws ArgumentError sliceOverDim(toNormB, 3, dim=1) ≈ toNormB[1,:,:]
	@test_throws ArgumentError sliceOverDim(toNormB, -1, dim=1) ≈ toNormB[1,:,:]
	@test sliceOverDim(toNormB, 1, dim=1) ≈ toNormB[1,:,:]
	@test sliceOverDim(toNormB, 2, dim=1) ≈ toNormB[2,:,:]
	@test sliceOverDim(toNormB, 1, dim=2) ≈ toNormB[:,1,:]
	@test sliceOverDim(toNormB, 2, dim=2) ≈ toNormB[:,2,:]
	@test sliceOverDim(toNormB, 1, dim=3) ≈ toNormB[:,:,1]
	@test sliceOverDim(toNormB, 2, dim=3) ≈ toNormB[:,:,2]
	@test sliceOverDim(toCondNormC, 1, dim=2) ≈ toCondNormC[:,1]
	@test sliceOverDim(toCondNormC, 2, dim=2) ≈ toCondNormC[:,2]
end


@testset "Testing the normalisation of non-normalized tensors" begin
	@test isNorm(normalize(strictPos))
	@test_throws DomainError normalize(hasZero)
	@test_throws DomainError normalize(hasNeg)
	@test_throws DomainError normalize(notNorm)
	@test isNorm(normalize(n))
	@test isNorm(normalize(toNormA))
	@test isapprox(normA, normalize(toNormA), atol=1e-3) 
	@test isNorm(normalize(toNormB)) 
	@test isapprox(normB, normalize(toNormB), atol=1e-3) 
end

@testset "Strictly positive check" begin
	@test isStrictPos(strictPos)
	@test !(isStrictPos(hasZero))
	@test !(isStrictPos(hasNeg))
	@test !(isStrictPos(notNorm))
end

@testset "Normalisation check" begin
	@test !(isNorm(strictPos))
	@test !(isNorm(hasZero))
	@test !(isNorm(hasNeg))
	@test !(isNorm(notNorm))
	@test isNorm(n)
end 

r = normRands(20)
@testset "Normalized random generation check" begin
	@test isNorm(r)
	@test isNorm(shuffle(r))
	# Usage of isapprox here as well
	@test sum(genRandTot(10,2)) ≈ 2
	@test isNorm(genRandTot(20,1)) 
	@test isNorm(normRands(1)) 
	@test isNorm(normRands(2)) 
	@test isNorm(normRands(3)) 
	@test isNorm(normRands(10)) 
	@test isNorm(normRands(15)) 
	@test isNorm(normRands(20)) 
	@test isNorm(shuffle(normRands(20)))
	#@test isNorm(normRandsShuf(20))
end 

@testset "Normalized random tensor generation check" begin
	@test isNorm(normRandsTensor((1)))
	@test isNorm(normRandsTensor((1,2)))
	@test isNorm(normRandsTensor((1,3)))
	@test isNorm(normRandsTensor((2,3,4)))
	@test isNorm(normRandsTensor((1,2,3,4)))
	@test isNorm(normRandsTensor((1,2,3,4,5)))
	@test isNorm(normRandsTensor((2,2,2,2,2,2,2,2)))
end

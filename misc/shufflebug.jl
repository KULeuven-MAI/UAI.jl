#!/usr/local/bin/julia
# Author: Dieter Castel
#
using Match
using Random
using Distributions
using Test

# Recursive function generating random numbers that sum to value t.
function genRandTot(n,t)
  @match (n,t) begin
  	(1, t) => [t]
  	(n, t) => begin r = rand(Uniform(0.0,t),1); 
					newn = n-1;
					newt = t-r[1];
					vcat(genRandTot(newn,newt), r) end
  end
end

# Generates an array of n random but normalized numbers. 
function normRands(n)
	genRandTot(n,1)
	# Should be shuffled for an actual random list, but shuffling fails some tests? :thinkingface:
	# shuffle(genRandTot(n,1))
end

# Generates an array of n random but normalized numbers and shuffled
function normRandsShuf(n)
	# Should be shuffled for an actual random list, but shuffling fails some tests? :thinkingface:
	shuffle(genRandTot(n,1))
end

# Tests whether the tensor is strictly positive
function isStrictPos(tensor)
    mapreduce(x -> x > 0, &, tensor)
end

# Tests whether the tensor is normalized.
function isNorm(tensor)
	isStrictPos(tensor) & (sum(tensor) ≈ 1)
end

r = normRands(20)
@testset "Normalized random generation check" begin
  @test isNorm(r) #True
  @test isNorm(shuffle(r)) # True here but False in other test script??
  @test isNorm(normRands(20))  # True
  @test isNorm(shuffle(normRands(20))) # False ?????
  @test isNorm(normRandsShuf(20)) # True
end

# On my machine this gives this result:
# Normalized random generation check: Test Failed at REPL[11]:5
#  Expression: isNorm(shuffle(normRands(20)))
# Stacktrace:
# [1] top-level scope at REPL[11]:5
# [2] top-level scope at /Users/osx/buildbot/slave/package_osx64/build/usr/share/julia/stdlib/v1.1/Test/src/Test.jl:1083
# [3] top-level scope at REPL[11]:2
# Test Summary:                      | Pass  Fail  Total
# Normalized random generation check |    4     1      5
# ERROR: Some tests did not pass: 4 passed, 1 failed, 0 errored, 0 broken.

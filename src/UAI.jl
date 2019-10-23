#!/usr/local/bin/julia
# Author: Dieter Castel
#
module UAI
	using Match
	using Random
	using Distributions
	export genRandTot, normRands, normRandsTensor, isStrictPos, isNorm, normalize, sliceOverDim
	export isCondNorm, condNormalize, marginalize, marginal

	include("normalization.jl")

# TODO:
# Make data structure for conditional, marginal prob, JPD, ...

# Lesson 2 
# Make Noisy OR/AND
end

#!/usr/local/bin/julia
# Author: Dieter Castel
#
module UAI
	using Match
	using Random
	using Distributions

	include("normalization.jl")
	export genRandTot, normRands, normRandsTensor, isStrictPos, isJPD, normalize, sliceOverDim
	export isCondNorm, condNormalize, margOver, marginal, conditional, oneComplement

	include("independence.jl")
	export idpValue


# TODO:
# Make data structure for conditional, marginal prob, JPD, ...

# Lesson 2 
# Make Noisy OR/AND
end

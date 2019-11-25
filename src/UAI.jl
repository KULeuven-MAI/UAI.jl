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

	include("parser.jl")
	export parseGraph, parseUndiGraph, parseDiGraph

	include("visualizer.jl")
	export drawGraph, drawFromStr

# TODO:
# Make data structure for conditional, marginal prob, JPD, ...
# Use DataFrames for datasets

# Lesson 2 
# Make Noisy OR/AND
end

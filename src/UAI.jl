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
	export idpValue,getAllAncestors,getAllDescendants,marryAll!,disorient,disorient!,moralize,moralize!,isGraphIdp

	include("parser.jl")
	export parseGraph, parseUndiGraph, parseDiGraph, parseFactorization

	include("visualizer.jl")
	export drawGraph, drawFromStr

	include("types.jl")
	export DiscreteVar, getDomain, assign, hasAssignment, hasDomain, setDomain
	export AbstractFactor, MarginalFactor, ConditionalFactor, JoinedFactor, Factorization
	export getFactorization, getFactor, getGraph
	export getChainComponents
	export JPD, setAllDomains!, setDomain!, assignTable!
	export Var, getFactor

	include("macros.jl")
	export @p, @q, @query, @gidp


# TODO:
# Make data structure for conditional, marginal prob, JPD, ...
# Use DataFrames for datasets

# Lesson 2 
# Make Noisy OR/AND
end

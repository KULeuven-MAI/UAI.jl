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
	export getDepStatements, getIdpStatements
	export formatIdpStatement,formatDepStatement
	export isPerfectMap, isDMap, isIMap

	include("parser.jl")
	export parseGraph, parseUndiGraph, parseDiGraph, parseFactorization

	include("visualizer.jl")
	export drawGraph, drawFromStr, saveToFile, plotFromStr

	include("types.jl")
	export DiscreteVar, getDomain, hasDomain, setDomain
	export AbstractFactor, MarginalFactor, ConditionalFactor, JoinedFactor, Factorization
	export getFactorization, getFactor, getGraph, hasFactor, getVariables
	export getChainComponents
	export JPD, setAllDomains!, setDomain!, setTable!, getTable, hasDomains, getNamedTable
	export Var, getFactor
	export Query, hasConditioningSet

	include("macros.jl")
	export @p, @q, @query, @gidp, @isDep, @isIdp

	include("interactive.jl")
	export setTableInteractive!,setAllInteractive!

	include("bucketElimination.jl")
	export bucketEliminate, bucketInitialise, eliminate, MessageFactor, makeOrder, firstBucket 

	include("factorGraphs.jl")
	export getFactorGraph, plotFG 

# Use DataFrames for datasets?

# Lesson 2 
# Make Noisy OR/AND
end

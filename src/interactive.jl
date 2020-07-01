using NamedArrays
using CSV
using InvertedIndices
using UAI
using DataFrames
using CSV
using OrderedCollections


#TODO: switch out with implementation from NamedArrays
import Base.selectdim
"""
Returns a view with all the elements in dimension dimname with values of dimval selected.
"""
function selectdim(n::NamedArray, dimname, dimval)
	# calculate the dimension index
	dimidx = findfirst(x->x==dimname,dimnames(n))
	println(dimidx)
	viewVarargs = fill(:,length(names(n)))
	viewVarargs = convert(Array{Any},viewVarargs)
	viewVarargs[dimidx] = dimval 
	return view(n,viewVarargs...)
end

import Base.convert
function convert(t::Type{NamedArray}, dict::Dict{K,V}) where {K,V}
	allkeys = collect(keys(dict))
	allvalues = collect(values(dict))
	return NamedArray(allvalues, allkeys, (:keys))
end
using DataFrames
"""
Converts a NamedArray to a DataFrame.
"""
function convert(t::Type{DataFrame}, n::NamedArray{V}; valueCol = :Values) where {V}
	mydimnames = n.dimnames
	mytypes = map(dict->eltype(keys(dict)),n.dicts)
	dfArgs = map((d,t)-> d=>t[], mydimnames, mytypes)
	dfArgs = (dfArgs..., valueCol => V[])
	df = DataFrame(dfArgs...)
	map(tup -> push!(df,(tup[1]...,tup[2])),enamerate(n))
	return df
end

"""
Converts a DataFrame to a NamedArray.
"""
function convert(t::Type{NamedArray}, df::DataFrame; valueCol = :Values)
	newdimnames = propertynames(df)
	deleteat!(newdimnames,findfirst(x->x==:Values,newdimnames))
	names = map(dn->unique(df[!,dn]),newdimnames)
	lengths = map(length,names)
	println(names)
	newna = NamedArray( reshape(df[!,valueCol], lengths...), tuple(names...), tuple(newdimnames...))
	return newna
end

#= function formatAssignment(factor::AbstractFactor, asgTuples::Array{Tuple{X,Y},1}) where {X,Y} =#
function formatAssignment(factor::AbstractFactor, asgTuples)
	str = string(factor)
	result = str
	for (varName,varVal) in asgTuples
		result = replace(result, Regex("$(varName)") => "$varName=$varVal")
	end
	return result
end

function setTableInteractive!(jpd, queryOrFactor;autofill=nothing)
	# TODO:
	# Ideally the one-complement should be added after n-1 entries for fewer data entry steps.
	nt = getNamedTable(jpd,queryOrFactor)
	# if !(autofill in nt.dicts[1]) TODO
	for (name, val) in enamerate(nt)
		if autofill !== name[1] 
			asgTups = zip(dimnames(nt),name)
			f = queryOrFactor isa AbstractFactor ? queryOrFactor : getFactor(jpd,queryOrFactor)
			println("Enter floating point value for ")
			println(formatAssignment(f,asgTups))
			newval = parse(Float64,readline())
			nt[name...] = newval
		end
	end
	setTable!(jpd,queryOrFactor,nt)
	println(nt)
	if autofill != nothing 
		#TODO: key not found bug? 0_o
			firstdim = dimnames(nt)[1]
			println(firstdim)
			others = selectdim(nt,firstdim,Not(autofill))
			oneComp = oneComplement(sum(others,dims=1))
			selectdim(nt,firstdim,autofill) .= oneComp
			println(nt)
			setTable!(jpd,queryOrFactor,nt)
	end
end


function setAllInteractive!(jpd)
	for f in jpd.factorization.factors
		setTableInteractive!(jpd,f)
	end
end

import CSV.write

function write(file, na::NamedArray; kwargs...)
	table = convert(DataFrame,na)
	CSV.write(file, table; kwargs...)
end

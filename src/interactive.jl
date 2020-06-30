using NamedArrays
using CSV
using InvertedIndices
using UAI
using DataFrames
using CSV
using OrderedCollections


#TODO cleanup, refactor to NamedArrays
import Base.selectdim
#= #TODO =#
#= function selectdim(n::NamedArray, dimname, dimval) =#
#= 	dimidx = findfirst(x->x==dimname,dimnames(n)) =#
#= 	dimvalidx = findfirst(x->x==dimval,names(n)[dimidx]) =#
#= 	newdimnames = dimnames(n) =#
#= 	newnames = names(n) =#
#= 	newnames[dimidx] = [dimval] =#
#= 	newvals = selectdim(n.array, dimidx, dimvalidx) =#
#= 	size(newvals) =#
#= 	newsizeArr = collect(size(n)) =#
#= 	newsizeArr[dimidx] = 1 =#
#= 	reshapedVals = reshape(newvals, tuple(newsizeArr...)) =#
#= 	return NamedArray(reshapedVals, newnames, newdimnames) =#
#= end =#
#
# Proper view based implementation

#= function selectdim(n::NamedArray, dimname, dimvals::Array) =#
#=                dimidx = findfirst(x->x==dimname,n.dimnames) =#
#=                validxs =  map(x->n.dicts[dimidx][x],dimvals) =#
#=                viewvarargs = fill(:,length(names(n))) =#
#=                viewvarargs = convert(Array{Any},viewvarargs) =#
#=                viewvarargs[dimidx] = validxs  =#
#=                return view(n,viewvarargs...) =#
#= end =#


import Base.convert
function convert(t::Type{NamedArray}, dict::Dict{K,V}) where {K,V}
	allkeys = collect(keys(dict))
	allvalues = collect(values(dict))
	return NamedArray(allvalues, allkeys, (:keys))
end

getDimType(dict::OrderedCollections.OrderedDict{K,V}) where {K,V} = K

"""
Converts a NamedArray to a DataFrame.
"""
function convert(t::Type{DataFrame}, n::NamedArray{V}) where {V}
	mydimnames = n.dimnames
	mytypes = map(dict->getDimType(dict),n.dicts)
	println(mydimnames)
	println(mytypes)
	dfArgs = map((d,t)-> d=>t[], mydimnames, mytypes)
	#= dfArgs = map((d,t)-> d=>String[], mydimnames, mytypes) =#
	dfArgs = (dfArgs..., :Values => V[])
	df = DataFrame(dfArgs...)
	#= map((dn,v) -> push!(df,(dn...,v)),enamerate(n)) =#
	println(df)
	map(tup -> push!(df,(tup[1]...,tup[2])),enamerate(n))
	return df
end

function selectdiminv(n::NamedArray, dimname, dimvals) 
	dimidx = findfirst(x->x==dimname,n.dimnames)
	namedArr = convert(NamedArray,n.dicts[dimidx])
end

#= NamedArray([1 2 5], [[:a],[:d, :e, :f]], [:a, :b]) =#
function selectdim(n::NamedArray, dimname, dimvals::Union{Array,InvertedIndex})
	dimidx = findfirst(x->x==dimname,n.dimnames)
	namedArr = convert(NamedArray,n.dicts[dimidx])
	println(namedArr)
	validxs = map(x->x[2], namearray[validxs]) #Handles InvertedIndex
	viewvarargs = fill(:,length(names(n)))
	viewvarargs = convert(Array{Any},viewvarargs)
	viewvarargs[dimidx] = validxs 
	return view(n,viewvarargs...)
end

function selectdim(n::NamedArray, dimname, dimval)
	dimidx = findfirst(x->x==dimname,n.dimnames)
	dimvalidx =  n.dicts[dimidx][dimval]
	viewvarargs = fill(:,length(names(n)))
	viewvarargs = convert(Array{Any},viewvarargs)
	viewvarargs[dimidx] = dimval 
	return view(n,viewvarargs...)
end

function selectdimview(n::NamedArray, dimname, dimval)
	# calculate the dimension and value index
	dimidx = findfirst(x->x==dimname,dimnames(n))
	dimvalidx = findfirst(x->x==dimval,names(n)[dimidx])
	viewvarargs = fill(:,length(names(n)))
	viewvarargs = convert(Array{Any},viewvarargs)
	viewvarargs[dimidx] = dimval 
	return view(n,viewvarargs...)
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
	
	sum(nt[Not(autofill)])
	#TODO finish autofill
	#= sum = zeros(size(nt[autofill,])) =#
	#= for other in filter(x->x!=autofill,names) =#
	#= 	sum(nt[other,:]) =#
	#= end =#
	#= for (name, val) in enamerate(nt) =#
	#= 	if autofill == name[1] =#
	#= 		nt[name...] =  =#
	#= 	end =#
	#= end =#
	setTable!(jpd,queryOrFactor,nt)
	println(nt)
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

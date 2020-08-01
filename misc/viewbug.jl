using CSV,DataFrames,NamedArrays,Test, InvertedIndices

import Base.convert
function convert(t::Type{NamedArray}, dict::Dict{K,V}) where {K,V}
	allkeys = collect(keys(dict))
	allvalues = collect(values(dict))
	return NamedArray(allvalues, allkeys, (:keys))
end
using DataFrames
#
#= """ =#
#= Converts a NamedArray to a DataFrame. =#
#= """ =#
#= function convert(t::Type{DataFrame}, n::NamedArray{V}; valueCol = :Values) where {V} =#
#= 	mydimnames = n.dimnames =#
#= 	mytypes = map(dict->eltype(keys(dict)),n.dicts) =#
#= 	dfArgs = map((d,t)-> d=>t[], mydimnames, mytypes) =#
#= 	dfArgs = (dfArgs..., valueCol => V[]) =#
#= 	df = DataFrame(dfArgs...) =#
#= 	map(tup -> push!(df,(tup[1]...,tup[2])),enamerate(n)) =#
#= 	return df =#
#= end =#
#=  =#
#= """ =#
#= Converts a DataFrame to a NamedArray. =#
#= """ =#
#= function convert(t::Type{NamedArray}, df::DataFrame; valueCol = :Values) =#
#= 	newdimnames = propertynames(df) =#
#= 	deleteat!(newdimnames,findfirst(x->x==:Values,newdimnames)) =#
#= 	names = map(dn->unique(df[!,dn]),newdimnames) =#
#= 	lengths = map(length,names) =#
#= 	println(names) =#
#= 	newna = NamedArray( reshape(df[!,valueCol], lengths...), tuple(names...), tuple(newdimnames...)) =#
#= 	return newna =#
#= end =#
#= import CSV.write =#
#=  =#
#= function write(file, na::NamedArray; kwargs...) =#
#= 	table = convert(DataFrame,na) =#
#= 	CSV.write(file, table; kwargs...) =#
#= end =#

#= df = CSV.read("invidxbug.csv") =#
#= myna = convert(NamedArray,df) =#
#= @test myna[Not("f"),:,:] == myna[[1,2],:,:] =#

using UAI
j = JPD("a>b<c")
setAllDomains!(j,["t","f"])
setDomain!(j,:b,["t","m","f"])
nt = getNamedTable(j,(@q b|a,c))
@test view(nt,Not("f"),:,:) == view(nt,[1,2],:,:)

## RESOLVED:
# JPD.getDomain was casting to type Any
# Resulting in confusion in NamedArrays.

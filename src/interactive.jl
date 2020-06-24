using NamedArrays
using UAI
import Base.iterate

# From NamedArrays.jl
function flattenednames(n::NamedArray)
	L = length(n) # elements in array
	cols = Array[]
	factor = 1
	for d in 1:ndims(n)
		nlevels = size(n, d)
		nrep = L ÷ (nlevels * factor)
		data = repeat(vcat([fill(x, factor) for x in names(n, d)]...), nrep)
		push!(cols, data)
		factor *= nlevels
	end
	return collect(zip(cols...))
end

# Iterator for NamedArray
Base.iterate(na::NamedArray, state=1) = state > length(na) ? nothing : begin ( (flattenednames(na)[state],na[flattenednames(na)[state]...]), state +1) end

function setTableInteractive!(jpd, query::Query)
	nt = getNamedTable(jpd,query)
	for (name, val) in nt
		tup = zip(dimnames(nt),name)
		println(tup)
		newval = parse(Float64,readline())
		nt[name...] = newval
	end
	assignTable!(jpd,query,nt)
	println(nt)
end


#= function setAllInteractive!(jpd) =#
#= 	for f in jpd.factorization.factors =#
#= 		setTableInteractive(jpd,f) =#
#= 	end =#
#= end =#

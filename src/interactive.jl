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


#= function formatAssignment(factor::AbstractFactor, asgTuples::Array{Tuple{X,Y},1}) where {X,Y} =#
function formatAssignment(factor::AbstractFactor, asgTuples)
	str = string(factor)
	result = str
	for (varName,varVal) in asgTuples
		result = replace(result, Regex("$(varName)") => "$varName=$varVal")
	end
	return result
end

function setTableInteractive!(jpd, queryOrFactor)
	nt = getNamedTable(jpd,queryOrFactor)
	for (name, val) in nt
		asgTups = zip(dimnames(nt),name)
		f = queryOrFactor isa AbstractFactor ? queryOrFactor : getFactor(jpd,queryOrFactor)
		println("Enter floating point value for ")
		println(formatAssignment(f,asgTups))
		newval = parse(Float64,readline())
		nt[name...] = newval
	end
	assignTable!(jpd,queryOrFactor,nt)
	println(nt)
end


function setAllInteractive!(jpd)
	for f in jpd.factorization.factors
		setTableInteractive!(jpd,f)
	end
end


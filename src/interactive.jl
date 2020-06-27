using NamedArrays
using UAI

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
	for (name, val) in enamerate(nt)
		asgTups = zip(dimnames(nt),name)
		f = queryOrFactor isa AbstractFactor ? queryOrFactor : getFactor(jpd,queryOrFactor)
		println("Enter floating point value for ")
		println(formatAssignment(f,asgTups))
		newval = parse(Float64,readline())
		nt[name...] = newval
	end
	setTable!(jpd,queryOrFactor,nt)
	println(nt)
end


function setAllInteractive!(jpd)
	for f in jpd.factorization.factors
		setTableInteractive!(jpd,f)
	end
end

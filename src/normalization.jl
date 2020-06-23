#TODO: use overloading and refactor normRandsTensor 2 normRands.

# Recursive function generating random numbers that sum to value t.
function genRandTot(n,t)
	@match (n,t) begin
	(1, t) => [t]
	(n, t) => begin r = rand(Uniform(0.0,t),1); 
					newn = n-1;
					newt = t-r[1];
					vcat(genRandTot(newn,newt), r) end
	end
end

# Given a tensor returns the elementwise 1-complementing tensor.
function oneComplement(tensor)
	return map(x -> 1 - x, tensor)	
end

# Generates an array of n random but normalized numbers. 
function normRands(n::Int)
	return normRands((n,))
	#genRandTot(n,1)
	# Should be shuffled for an actual random list, but shuffling fails some tests? :thinkingface:
	# shuffle(genRandTot(n,1))
end

function normRands(shape::Tuple)
	return normalize(map(x->rand(), ones(shape)))
end

# Generates a random but normalized tensor of the given shape
function normRandsTensor(shape)
	return normalize(map(x->rand(), ones(shape)))
end

# Tests whether the tensor is strictly positive
function isStrictPos(tensor)
	mapreduce(x -> x > 0, &, tensor)
end

# Checks if the given tensor is a valid Joint Probablity Distribution
# Checks normalisation constraint for given tensor. 
# Note that \approx (a.k.a. isapprox()) is used due to numerical considerations.
function isJPD(tensor)
	return isStrictPos(tensor) & (sum(tensor) ≈ 1)
end

# If possible normalizes the tensor, errors otherwise.
function normalize(tensor)
	if !(isStrictPos(tensor))
		throw(DomainError("A tensor to be normalized should be strictly positive everywhere."))
	end
	if isJPD(tensor)
		return tensor
	else
		s = sum(tensor)
		return tensor ./ s
	end
end


# Checks the validity of the conditioning dimension.
function checkDim(tensor, cdim)
	if !(cdim in 1:ndims(tensor))
		e = ArgumentError("The following conditioning set dimension is invalid for the given tensor:", cdim)
		#= println(typeof(e)) =#
		throw(e)
	end
end

# Checks the validity of the conditioning set.
function checkCset(tensor, cset)
	if cset == nothing
		throw(ArgumentError("The conditioning set can't be empty."))
	end
	[checkDim(tensor,c) for c in cset]
end

# Returns whether the tensor is normalized w.r.t. the cdim conditioning set dimension.
# 
# tensor: a tensor 
# cdim: the dimension corresponding to the conditioning set. 
# Note that \approx (a.k.a. isapprox()) is used due to numerical considerations.
function isCondNorm(tensor; cdim::Int=ndims(tensor))
	checkDim(tensor, cdim)
	# Sum over all dimensions except the cdim.
	sumdims = filter(e-> e ≠ cdim, 1:ndims(tensor))
	s = sum(tensor, dims=sumdims)
	# println(s)
	return all(map(e->e ≈ 1,s))
end

#TODO: benchmark vs ^^^
function isCondNorm2(tensor; cdim::Int=ndims(tensor))
	checkDim(tensor, cdim)
	cdimRange = 1:size(tensor)[cdim]
	res = [ isJPD(sliceOverDim(tensor, i, dim=cdim)) for i in cdimRange]
	return all(res)
end


# Returns the i-th slice of tensor over dimension k
function sliceOverDim(tensor, i; dim=nothing)
	if dim == nothing
		throw(ArgumentError("A dimension to slice over must be set with the keyword 'dim'"))
	end
	if !(i in axes(tensor)[dim])
		throw(ArgumentError("Can't slice outside of the size of the dimension."))
	end
	# Conversion to array to use the setindex! function
	new = convert(Array{Any},collect(axes(tensor)))
	new[dim] = i 
	# convert back to tuple for passing to function
	newIndex = tuple(new...)
	return getindex(tensor, newIndex...)
end


# Normalisation for conditional probability tables 
function condNormalize(tensor; cdim::Int)
	try 
		checkDim(tensor, cdim)
	catch e ;
		# TODO: figure out why MethodError instead of argument Error.
		#= if isa(e,ArgumentError) =#
		#= 	println("ISA ARG ERROR") =#
		#= end =#
		#= println(e) =#
		#= println(typeof(e)) =#
		throw(e)
	end
	cdimRange = 1:size(tensor)[cdim]
	# println(cdimRange)
	res = [ normalize(sliceOverDim(tensor, i, dim=cdim)) for i in cdimRange ]
	# println(res)
	return cat(res..., dims=cdim)
end

#TODO with more than one cdim a cset
#function condNormalize(tensor; cset::AbstractArray)
#	checkCset(tensor, cset)	
#	cdimRange = 1:size(tensor)[cdim]
#	# println(cdimRange)
#	res = [ normalize(sliceOverDim(tensor, i, dim=cdim)) for i in cdimRange ]
#	# println(res)
#	return cat(res..., dims=cdim)
#end

# Returns the 
function marginal(tensor, dimlist)
	if length(dimlist) != ndims(tensor)-1
		throw(ArgumentError("Can only compute a marginal for ndim(tensor)-1 variables."))
	end
	mdim = filter(x-> x ∉ dimlist, 1:ndims(tensor))[1]
	return margOver(tensor, mdim=mdim)
end

# Marginalises the given tensor over the mdim dimension 
# By default uses the last dimension as dimension to marginalize over.
# Calculates P(x_0 ... x_{i-1} x_{i+1}) where mdim corresponsds to x_i
function margOver(jpd; mdim=ndims(tensor))
	isJPD(jpd)
	checkDim(jpd, mdim)
	return sum(jpd, dims=mdim)
end

# Calculates the probaility of var given a single cdim [P(a|cdim)]
# TODO: see whether var also has to be a list
# var is a
# P(a|b) = P(a,b) / P(b)
# TODO: testing & debugging
function conditional(tensor, var::Int; cdim::Int)
	if !isJPD(tensor)
		throw(ArgumentError("Can only compute a conditional probablity from a normalized JPD tensor."))
	end
	checkDim(tensor, cdim)
	if length(cset) + 1 != ndims(tensor)
		throw(ArgumentError("Can only compute a conditional probablity with matching dimension."))
	end
	if var in cset
		throw(ArgumentError("Can't compute a conditonal probabilty of a var that is also in the conditioning set."))
	end
	denom = marginal(tensor, cset)
	return broadcast(/, tensor, denom)
end

# TODO overloaded function with cset instead of one cdim
# Calculates the probaility of var given cset [P(a|c1,c2 ...)]

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

# Generates an array of n random but normalized numbers. 
function normRands(n::Int)
	genRandTot(n,1)
	# Should be shuffled for an actual random list, but shuffling fails some tests? :thinkingface:
	# shuffle(genRandTot(n,1))
end

# Generates an array of n random but normalized numbers and shuffled
function normRandsShuf(n)
	# Should be shuffled for an actual random list, but shuffling fails some tests? :thinkingface:
	shuffle(genRandTot(n,1))
end

# Generates a random but normalized tensor of the given shape
function normRandsTensor(shape)
	n = prod(shape)
	reshape(normRands(n),shape)
end

# Tests whether the tensor is strictly positive
function isStrictPos(tensor)
	mapreduce(x -> x > 0, &, tensor)
end

# Tests whether the tensor is normalized.
# Note that \approx (a.k.a. isapprox()) is used due to numerical considerations.
function isNorm(tensor)
	isStrictPos(tensor) & (sum(tensor) ≈ 1)
end

# If possible normalizes the tensor, errors otherwise.
function normalize(tensor)
	if !(isStrictPos(tensor))
		throw(DomainError("A tensor to be normalized should be strictly positive everywhere."))
	end
	if isNorm(tensor)
		return tensor
	else
		s = sum(tensor)
		return tensor ./ s
	end
end

# Checks the validity of the conditioning dimension.
function checkDim(tensor, cdim)
	if !(cdim in 1:ndims(tensor))
			throw(ArgumentError("The conditioning set dimension is invalid for the given tensor"))
	end
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
	res = [ isNorm(sliceOverDim(tensor, i, dim=cdim)) for i in cdimRange]
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


# Normalisation for conditional probability distributions
function condNormalize(tensor; cdim::Int=ndims(tensor))
	checkDim(tensor, cdim)
	cdimRange = 1:size(tensor)[cdim]
	# println(cdimRange)
	res = [ normalize(sliceOverDim(tensor, i, dim=cdim)) for i in cdimRange ]
	# println(res)
	return cat(res..., dims=cdim)
end

# Returns the 
function marginal(tensor, dimlist)
	if length(dimlist) != ndims(tensor)-1
		throw(ArgumentError("Can only compute a marginal for ndim(tensor)-1 variables."))
	end
	mdim = filter(x-> x ∉ dimlist, 1:ndims(tensor))[1]
	return marginalize(tensor, mdim=mdim)
end

# Marginalises the given tensor over the mdim dimension 
# By default uses the last dimension as dimension to marginalize over.
function marginalize(tensor; mdim=ndims(tensor))
	checkDim(tensor, mdim)
	return sum(tensor, dims=mdim)
end

# Calculates the probaility of var given cset [P(a|b)]
# TODO: see whether var also has to be a list
# var is a
# P(a|b) = P(a,b) / P(b)
# TODO: testing & debugging
function conditional(tensor, var::Int; cset=nothing)
	if cset==nothing
		throw(ArgumentError("Can only compute a conditonal when a conditioning set is given."))
	end
	if !isNorm(tensor)
		throw(ArgumentError("Can only compute a conditional probablity from a normalized JPD tensor."))
	end
	if length(cset) + 1 != ndims(tensor)
		throw(ArgumentError("Can only compute a conditional probablity with matching dimension."))
	end
	if var in cset
		throw(ArgumentError("Can't compute a conditonal probabilty of a var that is also in the conditioning set."))
	end
	denom = marginal(tensor, cset)
	return broadcast(/, tensor, denom)
end

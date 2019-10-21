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

# Returns whether the tensor is normalized w.r.t. the cdim conditioning set dimension.
# 
# tensor: a tensor 
# cdim: the dimension corresponding to the conditioning set. 
function isCondNorm(tensor; cdim::Int=nothing)
	if cdim == nothing
		# Infer the condition set dimension as the last dimension.
		cdim = ndims(tensor)
	else
		if ndims(tensor) < cdim | condSet < 0 
			throw(ArgumentError("The conditioning set dimension is invalid for the given tensor"))
		end
	end
	# Sum over all dimensions except the cdim.
	sumdims = filter(e-> e ≠ cdim, range(1,length=ndims(tensor)))
	s = sum(tensor, dims=sumdims)
	return all(filter(e->e ≈ 1,s))
end

#TODO: Write alternative reusing isNorm?

# TODO: debug
# returns the i-th slice of tensor over dimension k
function sliceOverDim(tensor, i; dim=nothing)
	if dim == nothing
			throw(ArgumentError("A dimension to slice over must be set with the keyword 'dim'"))
	end
	new = map(s->axes(tensor,s),size(tensor))
	#TODO
	return new
	#return getindex(tensor, new...)
end


# Normalisation for conditional probability distributions
# TODO: debug & test
function condNormalize(tensor; cdim::Int=nothing)
	if cdim == nothing
		# Infer the condition set dimension as the last dimension.
		cdim = ndims(tensor)
	else
		if ndims(tensor) < cdim | cdim < 0
			throw(ArgumentError("The conditioning set dimension is invalid for the given tensor"))
		end 
	end
	res = [] 
	for i in size(tensor)[cdim]
		for sa in sliceOverDim(tensor, i, dim=cdim)
			cat(res, normalize(sa), dims=cdim)
		end
	end
	return res
end


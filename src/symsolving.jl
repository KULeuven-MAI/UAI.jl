using SymEngine
 test = [1 nothing 3]
# If el is nothing returns the symbol indexed by iterators.
# else returns the el
# Iterators is vararg for indexing each symbol
function symIfNothing(el, iterators):
	if el=nothing:
		return symbols("x_$(iterators)") 
	else
		return el
end


r = map((idx,val)->symIfNothing(val,idx) for (idx,val) in test)

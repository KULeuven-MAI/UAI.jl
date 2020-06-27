using UAI


function parseQuery(sym::Symbol)
	return ([sym],[])
end

# Parses an expression of the form "x1,x2,x3|y1,y2,y3"
# returns tuple (query, condSet) 
# where the first part is the query and the second the conditioning set
function parseQuery(expr::Expr)
	query = Symbol[]
	condSet = Symbol[]
	#dump(expr)
	exprIdx = findfirst(x->typeof(x)===Expr,expr.args)
	if exprIdx == nothing
		barIdx = findfirst(x->x===:|,expr.args)
		if barIdx !==nothing
			push!(query,expr.args[2])
			push!(condSet,expr.args[3])
		else
			push!(query,expr.args[1])
			push!(query,expr.args[2])
		end
	else
		idx = exprIdx
		#println(idx)
		idx == 1 ? nothing : append!(query,expr.args[1:idx-1]) 
		push!(query,expr.args[idx].args[2])
		push!(condSet,expr.args[idx].args[3])
		append!(condSet,expr.args[idx+1:end])
	end
	(query,condSet)
end

macro p(jpd, queryExpr)
	#TODO: finalize.
	local ref = esc(quote $jpd end)
	local (query,condSet) = parseQuery(queryExpr)
	local q = QuoteNode(query[1])
	return quote
		# This should be replaced with the appropriate calculation.
		setTable!($ref,$q,[])
	end
end

macro query(queryExpr)
	local (query,condSet) = parseQuery(queryExpr)
	local qN = QuoteNode(query) 
	local eN = QuoteNode(condSet)
	return quote
		($qN,$eN)
	end
end

# shorthand for queries.
macro q(queryExpr)
	return :(Query(@query $(queryExpr)))
end

macro gidp(graphString, firstVar, queryExpr)
	local (query,condSet) = parseQuery(queryExpr)
	local ref = esc(quote $graphString end)
	local fV = QuoteNode(firstVar)
	local qN = QuoteNode(query[1]) 
	local eN = QuoteNode(condSet)
	return quote 
		isGraphIdp($ref, string($fV), string($qN),condSet=convert(Array{String},map(x->string(x),$eN)))
	end
end

macro isDep(firstVar, queryExpr)
	local (query,condSet) = parseQuery(queryExpr)
	local fV = QuoteNode(firstVar)
	local qN = QuoteNode(query[1]) 
	if condSet != []
		local eN = QuoteNode(condSet[1])
		return quote
			formatDepStatement((string($fV),string($qN),string($eN)))
		end
	else 
		return quote
			formatDepStatement((string($fV),string($qN)))
		end
	end
end

macro isIdp(firstVar, queryExpr)
	local (query,condSet) = parseQuery(queryExpr)
	local fV = QuoteNode(firstVar)
	local qN = QuoteNode(query[1]) 
	println(condSet)
	if condSet != []
		local eN = QuoteNode(condSet[1])
		return quote
			formatIdpStatement((string($fV),string($qN),string($eN)))
		end
	else
		return quote
			formatIdpStatement((string($fV),string($qN)))
		end
	end
end

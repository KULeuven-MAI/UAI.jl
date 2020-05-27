using UAI


function parseQueryExpr(sym::Symbol)
	return sym
end

# Parses an expression of the form "x1,x2,x3|y1,y2,y3"
function parseQueryExpr(expr::Expr)
	query = Symbol[]
	evidence = Symbol[]
	dump(expr)
	exprIdx = findfirst(x->typeof(x)===Expr,expr.args)
	if exprIdx == nothing
		idx = findfirst(x->x===:|,expr.args)
		push!(query,expr.args[2])
		push!(evidence,expr.args[3])
	else
		idx = exprIdx
		println(idx)
		idx == 1 ? nothing : append!(query,expr.args[1:idx-1]) 
		push!(query,expr.args[idx].args[2])
		append!(evidence,expr.args[idx+1:end])
		push!(evidence,expr.args[idx].args[3])
	end
	(query,evidence)
end

macro p(jpd, queryExpr)
	#TODO: finalize.
	local ref = esc(quote $jpd end)
	local (query,evidence) = parseQueryExpr(queryExpr)
	local q = QuoteNode(query[1])
	return quote
		# This should be replaced with the appropriate calculation.
		assignTable!($ref,$q,[])
	end
end

#TODO: marginal case
macro query(queryExpr)
	local (query,evidence) = parseQueryExpr(queryExpr)
	local qN = length(query) > 1 ? map(x->QuoteNode(x),query) : QuoteNode(query)
	local eN = evidence !== nothing ? map(x->QuoteNode(x),evidence) : nothing
	return quote
		($qN,$eN)
	end
end

#= macro q(queryExpr) =#
#= 	return :(@query $(esc(queryExpr))) =#
#= end =#

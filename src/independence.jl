
#idp holds if 
#P(a,b) = p(a)*p(b) for all values in domA, domB

function idp(jpd,dim1,dim2)
	pA = marginalize(jpd)
	pB = marginalize(jpd,mdim=1) 
	return jpd
end


#TODO: generalise to higher dims
function idpValue(jpd,idx)
	setprecision(150)
	println("________")
	println(idx)
	pA = marginalize(jpd)
	pB = marginalize(jpd,mdim=1) 
	pAB = jpd
	margAIdx = idx[1]
	margBIdx = idx[2]
	prod = pA[margAIdx]*pB[margBIdx] 
	println(jpd[idx...])
	println(prod)
	return isapprox(jpd[idx...],prod)
end

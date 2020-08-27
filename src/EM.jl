# Expectation Maximization
# 
#Algorithm 11.2 EM for Belief Networks. Input: a BN DAG and dataset on the visible variables V. Returns
#the maximum likelihood estimate of the tables p(x i |pa (x i )), i = 1, . . . , K.
 
"""


"""
# Copy pasted from pseudocode
function doEM(j::JPD,v::DataFrame,iter=100)
	# TODO: determine h^n v^n split for each sample (row) v_n once. 
	t =1
	#Set p_t (x_i |pa (x i )) to initial values.
	#TODO
	#while p (x_i |pa (x i )) not converged (or likelihood not converged) do
	while not(all(map((c,n)->isapprox(c,n)),zip(p_c,p_t))) 
		t = t + 1
		for n in 1:N
			q t n (x) = p t (h n |v n ) (v, v n )
		end for
		for i in 1:K 
			P N
			q t n (x i ,pa(x i ))
			p t+1 (x i |pa (x i )) = P n=1
			N
			n 0
		end 
	end
	return p t (x i |pa (x i ))
	# TODO update tables of j.
end

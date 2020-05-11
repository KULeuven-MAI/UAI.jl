using UAI
using Test
using Random

using SymEngine
@vars x y
tab= [0.2 0.1 0.3; 0.133 x y]
solvedTab = [0.2 0.1 0.3; 133/1000 66/1000 0.2]

@testset "Testing independence of 2x3 jpd" begin
	setprecision(150)
	domA = 1:2
	domB = 1:3
	for a in domA 
		for b in domB 
			@test idpValue(solvedTab,[a,b])
		end
	end
end

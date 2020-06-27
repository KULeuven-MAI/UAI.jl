gotDrug = [0.8; 0.2]
health_gotDrug = [0.99 0.1 ; 0.01 0.9]


printfcmd = `printf '0.8\n0.2\n0.99\n0.01\n0.1\n0.9\n'` 
juliacmd = `julia -e 'using Test; include("../examples/simple.jl"); getFactor(j, @q gotDrug ) '` 


f = run(pipeline(printfcmd,juliacmd))
println(f)



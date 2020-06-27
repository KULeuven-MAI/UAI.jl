printfcmd = `printf '0.3\n200\n'` 
juliacmd = `julia -e 'f = readline(); println(parse(Float64,f)); f2 = readline(); println(parse(Int,f2))'` 

run(pipeline(printfcmd,juliacmd))

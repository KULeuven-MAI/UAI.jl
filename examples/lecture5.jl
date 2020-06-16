# Example from lecture 5 slide 11
using UAI
str = "c<a>d;d<b;f<d>g<e"
jpd = JPD(str)
@assert hasFactor(jpd,@q a)
@assert hasFactor(jpd,@q b)
@assert hasFactor(jpd,@q e)
@assert hasFactor(jpd,@q c|a)
@assert hasFactor(jpd,@q d|a,b)
@assert hasFactor(jpd,@q f|d)
@assert hasFactor(jpd,@q g|d,e)
println(jpd)

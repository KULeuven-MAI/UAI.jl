using Primes
using Distributions
# TODO experiment with using Distributions.jl


# From Rosetta Code
fib(n) = ([1 1 ; 1 0]^n)[1,2]
twoPow(n) = 2^n
S = [64,55,34,21,64,8,1,8,34,55,64,1,2,34,1,8,21,5,3,2]
priors = repeat([1/7],7)
println(priors)

println(S)
function takeFuncUnder(func, startval, limit)
        i = startval
        value = func(i)
        result = convert(Array{Int64},[])
        while func(i) < limit
            push!(result,value)
            i +=1
            value = func(i)
        end
        return result
end

function listA()
    return takeFuncUnder(fib, 1, 100)
end

function listB()
    return takeFuncUnder(twoPow, 0, 100)
end

function listC()
    return primes(100)
end

function AB()
    return 
end

function BC()
    return 
end

function AC()
    return 
end

function ABC()
   return 
end
    
function dist(n)
    if n == 1
        len = length(listA())
        return DiscreteUniform(1,len)
    elseif n == 2
        len = length(listB())
        return DiscreteUniform(1,len)
    elseif n == 3
        len = length(listC())
        return DiscreteUniform(1,len)
    elseif n == 4
        return AB()
    elseif n == 5
        return BC()
    elseif n == 6
        return AC()
    elseif n == 7
        return ABC()
    end
end


listsDict = Dict(zip(['A','B','C'],[listA(), listB(), listC()]))
possiblilities = []
for s in S
    result = []
    for (k,l) in listsDict
        if s in l
            push!(result,1)
        else
            push!(result,0)
        end
    end
    push!(possiblilities,tuple(result...))
end

#!/usr/local/bin/julia
# Author: Dieter Castel
using UAI
using Test

tests = ["normalization"]
for t in tests
	include("$(t).jl")
end

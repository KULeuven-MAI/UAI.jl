#!/usr/local/bin/julia
# Author: Dieter Castel
using UAI
using Test

#tests = ["independence", "normalization"]
tests = ["normalization","parser","visualizer"]
for t in tests
	include("$(t).jl")
end
